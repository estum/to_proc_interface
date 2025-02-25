# frozen_string_literal: true

module ToProcInterface
  # The mixin to use when an instance-level {#call} method returns a monad.
  module CallToMaybe
    include ToProcInterface

    # All the arguments passed to initializer.
    # @see #initialize
    # @see #call
    # @return [Dry::Monad::Maybe]
    def call(...)
      new(...).call.to_maybe
    end
  end
end
