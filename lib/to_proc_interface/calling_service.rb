# frozen_string_literal: true

module ToProcInterface
  # @example Usage
  #   class Sum < Struct.new(:a, :b, keyword_init: true)
  #     extend ToProcInterface::CallingService
  #
  #     def call
  #       self.a + self.b
  #     end
  #   end
  #
  #   [
  #     { a: 1, b: 2 },
  #     { a: 3, b: 4 }
  #   ].map(&Sum) # => [3, 7]
  module CallingService
    include ToProcInterface

    # Initializes an object with the given args and invokes it's {#call} method without arguments.
    # @see #initializer
    # @see #call
    def call(...)
      new(...).call
    end
  end
end
