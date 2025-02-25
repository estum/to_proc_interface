# frozen_string_literal: true

module ToProcInterface
  # @example Usage
  #   class Sum < Struct.new(:a, :b, keyword_init: true)
  #     extend ToProcInterface::Initializer
  #   end
  #   [
  #     { a: 1, b: 2 },
  #     { a: 3, b: 4 }
  #   ].map(&Sum) # => [#<struct Sum a=1, b=2>, #<struct Sum a=3, b=4>]
  module Initializer
    include ToProcInterface

    # Initializes an object with the given args and invokes it's {#call} method without arguments.
    # @see #initializer
    def call(...)
      new(...)
    end
  end
end
