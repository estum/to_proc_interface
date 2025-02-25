# frozen_string_literal: true

require "singleton"

module ToProcInterface
  # Singleton variation. {#to_proc} & {#call} delegated to {ToProcInterface::Singleton::ClassMethods.instance}
  #
  # @example Usage
  #   require "to_proc_interface/singleton"
  #
  #   class Sum
  #     include ToProcInterface::Singleton
  #
  #     def call(a, b)
  #       a + b
  #     end
  #   end
  #
  #   Sum.(1, 2) # => 3
  module Singleton
    include ToProcInterface

    # @api private
    def self.included(base)
      super
      base.include ::Singleton
      base.extend ClassMethods
    end

    # @api private
    module ClassMethods
      include Delegations

      # @!attribute [r] instance
      #   @return [::Singleton]

      # @return [Proc]
      def to_proc
        instance.to_proc
      end

      def call(...)
        instance.call(...)
      end
    end
  end
end
