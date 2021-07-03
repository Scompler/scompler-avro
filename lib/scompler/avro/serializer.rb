# frozen_string_literal: true

module Scompler
  module Avro
    class Serializer
      attr_reader :avro, :schema_name, :version_number

      def initialize(avro:, schema_name: nil, version_number: nil)
        @avro = avro
        @schema_name = schema_name
        @version_number = version_number
      end

      def call(content, schema_name: nil, version_number: nil)
        return if content.blank?

        schema_name ||= self.schema_name
        version_number ||= self.version_number

        avro.encode(content, schema_name: schema_name, namespace: version_number)
      end
    end
  end
end
