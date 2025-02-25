# frozen_string_literal: true

module ToProcInterface
  # @example Usage
  #   class Sum < Struct.new(:a, :b, keyword_init: true)
  #     extend ToProcInterface::PerformingService
  #
  #     def perform
  #       self.a + self.b
  #     end
  #   end
  #
  #   [
  #     { a: 1, b: 2 },
  #     { a: 3, b: 4 }
  #   ].map(&Sum) # => [3, 7]
  module PerformingService
    include ToProcInterface

    # Initializes an object with the given args and invokes it's {#perform} method without arguments.
    # @see #initializer
    # @see #perform
    def call(...)
      new(...).perform
    end
  end
end
