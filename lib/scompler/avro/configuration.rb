# frozen_string_literal: true

require 'dry-configurable'

module Scompler
  module Avro
    class Configuration
      extend Dry::Configurable

      setting :cache, SchemaCache.new
      setting :logger, ActiveSupport::Logger.new(STDOUT)

      setting :cache_options do
        setting :force, false
        setting :skip_nil, true
        setting :compress, true
        setting :expires_in, 86400
        setting :version
        setting :race_condition_ttl
      end
    end
  end
end
