# frozen_string_literal: true

module ToProcInterface
  # @note
  #   Block passed to class-level {WrappingCall#call}
  #   will be yield to instance-level #call
  module WrappingCall
    include ToProcInterface

    # @!scope class

    def call(...)
      if block_given?
        call_safe(...)
      else
        call_unsafe(...)
      end
    end

    def call_safe(*args, **opts, &block)
      new(*args, **opts).call_safe(&block)
    end

    def call_unsafe(...)
      new(...).call_unsafe
    end
  end
end
