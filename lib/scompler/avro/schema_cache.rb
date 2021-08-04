# frozen_string_literal: true

module Scompler
  module Avro
    class SchemaCache
      def fetch(name, options = {}, &block)
        yield if block_given?
      end
    end
  end
end
