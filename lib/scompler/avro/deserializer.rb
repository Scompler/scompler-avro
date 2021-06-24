# frozen_string_literal: true

module Scompler
  module Avro
    class Deserializer
      attr_reader :avro, :schema_name, :version_number

      VERSION_HEADER = 'version'
      private_constant :VERSION_HEADER

      def initialize(avro:, schema_name: nil, version_number: nil)
        @avro = avro
        @schema_name = schema_name
        @version_number = version_number
      end

      def call(params)
        return if params.raw_payload.nil?

        schema_name = @schema_name || fetch_schema_name(params)
        namespace = @version_number || fetch_version(params)

        options = {
          schema_name: schema_name,
          namespace: namespace
        }

        avro.decode(params.raw_payload, **options)
      end

      protected

      def fetch_version(params)
        params.headers[VERSION_HEADER]
      end

      def fetch_schema_name(params)
        Karafka::App.config.topic_mapper.schema_name_from_topic(params.topic)
      end
    end
  end
end
