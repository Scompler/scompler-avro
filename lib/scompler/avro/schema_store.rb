# frozen_string_literal: true

require 'avro_turf'
require 'aws-sdk-glue'
require 'concurrent/hash'

module Scompler
  module Avro
    class SchemaStore
      attr_reader :registry_name

      DEFAULT_VERSION = 1
      SCHEMAS_RELATIVE_PATH = '../../../schemas/'
      SCHEMAS_CACHE_NAMESPACE = '/schemas/avro/'

      def initialize(registry_name: REGISTRY_NAME)
        @registry_name = registry_name
        @schemas = Concurrent::Hash.new
        @mutex = Mutex.new
      end

      def as_avro
        @as_avro ||= AvroTurf.new(schema_store: self, codec: :snappy)
      end

      def find(schema_name, version_number = nil)
        version_number = DEFAULT_VERSION if version_number.nil?

        fullname = ::Avro::Name.make_fullname(schema_name, version_number.to_s)
        return @schemas[fullname] if @schemas.key?(fullname)

        @mutex.synchronize do
          return @schemas[fullname] if @schemas.key?(fullname)

          cache_path = full_cache_path_for(fullname)
          begin
            @schemas[fullname] = Scompler::Avro.config.cache.fetch(cache_path, cache_options) do
              load_schema!(schema_name: schema_name, version_number: version_number)
            end
          rescue ::Avro::SchemaParseError => e
            @schemas.delete(fullname)
            raise e
          end
        end
      end

      private

      attr_reader :schemas

      def full_cache_path_for(key)
        File.join(SCHEMAS_CACHE_NAMESPACE, key)
      end

      def load_schema!(schema_name:, version_number: 1)
        schema_definition = begin
          load_glue_schema!(schema_name, version_number)
        rescue Aws::Errors::ServiceError
          load_local_schema!(schema_name, version_number)
        end

        schema = ::Avro::Schema.parse(schema_definition)
        if schema.respond_to?(:fullname) && schema.fullname != schema_name
          error_message = "expected schema `#{response.schema_arn}' " \
                          "of #{response.version_number} " \
                          "version to define type `#{schema_name}'"
          raise AvroTurf::SchemaError, error_message
        end

        schema
      end

      def load_local_schema!(schema_name, version_number = 1)
        file_path = File.join(
          SCHEMAS_RELATIVE_PATH,
          registry_name,
          "v#{version_number}",
          "#{schema_name}.json"
        )
        File.read(File.expand_path(file_path, __dir__))
      end

      def load_glue_schema!(schema_name, version_number = 1)
        response = client.get_schema_version(
          schema_id: { schema_name: schema_name, registry_name: registry_name },
          schema_version_number: { latest_version: false, version_number: version_number }
        )
        response.schema_definition
      end

      def cache_options
        Scompler::Avro.config.cache_options.to_h
      end

      def client
        @client ||= Aws::Glue::Client.new
      end
    end
  end
end
