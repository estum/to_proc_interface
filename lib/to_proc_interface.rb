# frozen_string_literal: true

require "to_proc_interface/hooks"
require "zeitwerk"

# @example Extended to a class
#   class Sum
#     extend ToProcInterface
#
#     def self.call(a, b)
#       a + b
#     end
#   end
#
#   Sum[1, 2] # => 3
#
# @example Included to a class
#   class Sum
#     include ToProcInterface
#
#     def call(a, b)
#       a + b
#     end
#   end
#
#   Sum.new[1, 2] # => 3
#
# @example Included to a module
#   module YieldToInstanceCall
#     # @!parse extend ToProcInterface::Hooks::Extended
#     # @!parse extend ToProcInterface::Hooks::Inherited
#     include ToProcInterface
#
#     def call(*args, **opts, &block)
#       new(*args, **opts).call(&block)
#     end
#   end
#
#   class BinaryOp
#     extend YieldToInstanceCall
#
#     def initialize(a, b)
#       @a, @b = a, b
#     end
#
#     def call
#       yield(@a, @b)
#     end
#   end
#
#   BinaryOp.(1, 2, &:+) # => 3
module ToProcInterface
  METHODS = [
    :parameters,
    :<<,
    :yield,
    :[],
    :>>,
    :arity,
    :lambda?,
    :binding,
    :curry,
    :source_location
  ].freeze

  # @abstract
  module Mixin
    # @!attribute [r] to_proc
    #   @return [Proc] built from the {#call} method
    def to_proc
      @to_proc ||= method(:call).to_proc
    end

    # @abstract
    def call
      raise NotImplementedError
    end
  end

  # The mixin brings all public methods of the {Proc} class to be delegated to the {Mixin#to_proc} method.
  # @api private
  module Delegations
    template, *loc = <<~RUBY, __FILE__, __LINE__ + 1
      # @see #to_proc
      # @see Proc#%<name>s
      def %<name>s(...)
        to_proc.%<name>s(...)
      end
    RUBY

    METHODS.each { module_eval(format(template, name: _1), *loc) }
  end

  include Mixin
  include Delegations

  # @!parse extend Hooks::Extended, Hooks::Included
  extend Hooks

  # rubocop:disable Metrics/MethodLength

  # @api private
  def self.loader
    @loader ||=
      Zeitwerk::Loader.for_gem.tap do |loader|
        root = __dir__
        loader.tag = "to_proc_interface"
        loader.push_dir root
        loader.ignore \
          "#{root}/to_proc_interface/call_to_maybe.rb",
          "#{root}/to_proc_interface/hooks.rb",
          "#{root}/to_proc_interface/performing_service.rb",
          "#{root}/to_proc_interface/singleton.rb",
          "#{root}/to_proc_interface/wrapping_call.rb"

        if defined?(Pry)
          loader.log!
          loader.enable_reloading
        end
      end
  end

  # rubocop:enable Metrics/MethodLength

  loader.setup
end
