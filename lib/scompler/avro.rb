# frozen_string_literal: true

require 'active_support/dependencies/autoload'
require 'active_support/logger'
require 'active_support/core_ext/module/delegation'

module Scompler
  module Avro
    extend ActiveSupport::Autoload

    autoload :Configuration
    autoload :Deserializer
    autoload :SchemaStore
    autoload :Serializer
    autoload :SchemaCache

    REGISTRY_NAME = 'scompler'

    class << self
      delegate :logger, :cache_options, :cache, to: :config

      def configure(&block)
        block.arity.zero? ? instance_eval(&block) : yield(config)
      end

      def config
        @config ||= Configuration.config
      end
    end
  end
end
