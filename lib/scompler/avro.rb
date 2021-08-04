# frozen_string_literal: true

require_relative 'avro/schema_store'
require_relative 'avro/deserializer'
require_relative 'avro/serializer'
require_relative 'avro/configuration'

module Scompler
  module Avro
    REGISTRY_NAME = 'scompler'

    class << self
      def configure(&block)
        block.arity.zero? ? instance_eval(&block) : yield(config)
      end

      def config
        @config ||= Avro::Configuration.config
      end
    end
  end
end
