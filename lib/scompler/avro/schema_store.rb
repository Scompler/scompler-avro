# frozen_string_literal: true

require 'avro_turf'
require 'aws-sdk-glue'
require 'concurrent/hash'

module Scompler
  module Avro
    class SchemaStore
      attr_reader :registry_name

      DEFAULT_VERSION = 1

      def initialize(registry_name: REGISTRY_NAME)
        @registry_name = registry_name
        @schemas = Concurrent::Hash.new
        @mutex = Mutex.new
      end

      def as_avro
        @as_avro ||= AvroTurf.new(schema_store: self, codec: :snappy)
      end

      def find(schema_name, version_number = nil)
        version_number = version_number.presence || DEFAULT_VERSION

        fullname = ::Avro::Name.make_fullname(schema_name, version_number.to_s)
        return @schemas[fullname] if @schemas.key?(fullname)

        @mutex.synchronize do
          return @schemas[fullname] if @schemas.key?(fullname)

          load_schema!(schema_name: schema_name, version_number: version_number, fullname: fullname)
        end
      end

      private

      attr_reader :schemas

      def load_schema!(schema_name:, version_number: 1, fullname: nil)
        response = client.get_schema_version(
          schema_id: { schema_name: schema_name, registry_name: registry_name },
          schema_version_number: { latest_version: false, version_number: version_number }
        )

        schema = ::Avro::Schema.parse(response.schema_definition)
        if schema.respond_to?(:fullname) && schema.fullname != schema_name
          error_message = "expected schema `#{response.schema_arn}' " \
                          "of #{response.version_number} " \
                          "version to define type `#{schema_name}'"
          raise AvroTurf::SchemaError, error_message
        end

        @schemas[fullname] = schema
      rescue ::Avro::SchemaParseError => e
        @schemas.delete(fullname)
        raise e
      end

      def client
        @client ||= Aws::Glue::Client.new
      end
    end
  end
end
