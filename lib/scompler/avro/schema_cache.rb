# frozen_string_literal: true

module Scompler
  module Avro
    class SchemaCache
      def fetch(_name, _options = {}, &_block)
        yield if block_given?
      end
    end
  end
end
