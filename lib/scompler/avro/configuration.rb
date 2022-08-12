# frozen_string_literal: true

require 'dry-configurable'

module Scompler
  module Avro
    class Configuration
      extend Dry::Configurable

      setting :cache, default: SchemaCache.new
      setting :logger, default: ActiveSupport::Logger.new($stdout)

      setting :cache_options do
        setting :force, default: false
        setting :skip_nil, default: true
        setting :compress, default: true
        setting :expires_in, default: 86_400
        setting :version
        setting :race_condition_ttl
      end
    end
  end
end
