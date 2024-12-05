# frozen_string_literal: true

require 'singleton'

# @example Usage
#   class SomeCallableClass
#     def self.call(*args)
#       # bla-bla
#     end
#
#     extend ToProcInterface
#   end
module ToProcInterface
  # @api private
  # Mixin module with delegations to {ToProcInterface#to_proc} method to mimic {Proc} behavior.
  module Delegations
    class << self
      @@proc_methods = []

      # @return [Array<Symbol>]
      def proc_methods
        @@proc_methods
      end

      @@args_by_arity = [
        "",
        "arg",
        "*args, **opts, &block"
      ].freeze

      # @!macro [new] delegate_to_proc
      #   @!method (...)
      #     @see Proc#
      #
      # @param name [Symbol, String]
      #   method name
      # @param arity [Integer]
      #   method arity
      # @return [Symbol]
      #   delegated method name
      #
      # @example Customize proc-delegated methods
      #   ToProcInterface::Delegations.delegate_to_proc :custom_proc_method, arity: 1
      def delegate_to_proc(name, arity: nil)
        name = name.to_sym
        arity ||= Proc.instance_method(name).arity
        args = @@args_by_arity[arity.clamp(-1, 1)]

        class_eval(<<~RUBY, __FILE__, __LINE__ + 1).tap { proc_methods << _1 }
          def #{name}(#{args})
            to_proc.#{name}(#{args})
          end
        RUBY
      end
    end

    delegate_to_proc :parameters, arity: 0
    delegate_to_proc :arity, arity: 0
    delegate_to_proc :lambda?, arity: 0
    delegate_to_proc :binding, arity: 0
    delegate_to_proc :curry, arity: -1
    delegate_to_proc :yield, arity: -1
    delegate_to_proc :[], arity: -1
    delegate_to_proc :<<, arity: 1
    delegate_to_proc :>>, arity: 1
    delegate_to_proc :source_location
    delegate_to_proc :ruby2_keywords if Proc.method_defined?(:ruby2_keywords)
  end

  # @api private
  module Hooks
    # @example Usage
    #   extend ToProcInterface::Hooks::Included
    module Included
      # @return [void]
      private def included(base)
        base.extend Extended if base.is_a?(Module) && !base.is_a?(Class)
        super if defined?(super)
      end
    end

    # @example Usage
    #   extend ToProcInterface::Hooks::Extended
    module Extended
      # Hooks an {Module#extended} callback method to mix in possible singleton class with {Inherited}.
      # @return [void]
      private def extended(base)
        base.extend Inherited if base.is_a?(Class)
        super if defined?(super)
      end
    end

    # @example Usage
    #   extend ToProcInterface::Hooks::Inherited
    module Inherited
      # Hooks an {Class#inherited} method to avoid reusing cached {#to_proc} on inherited classes.
      # @return [void]
      private def inherited(subclass)
        if subclass.instance_variable_defined?(:@to_proc)
          subclass.remove_instance_variable(:@to_proc)
          subclass.to_proc
        end
        super if defined?(super)
      end
    end
  end

  # @api private
  module Mixin
    extend Hooks::Included
    include Delegations

    # @return [Proc] built from the {#call} method
    def to_proc
      @to_proc ||= method(:call).to_proc
    end
  end

  include Mixin

  # Interface with predefined {#call} method which delegates all the given params into class' constructor
  # and invokes instance's {#call} method.
  #
  # @example Usage
  #   extend ToProcInterface::CallingService
  module CallingService
    include Mixin

    # @see #initialize
    # @see #call
    def call(*args, **opts, &block)
      instance = new(*args, **opts, &block)
      instance.call
    end
  end

  # Interface with predefined {#call} method which delegates all the given params into class' constructor
  # and invokes instance's {#call} method converting a result monad into maybe.
  #
  # @abstract
  #   The instance method `#call` should return a monad-like object responsible to `#to_maybe`.
  #
  # @example Usage
  #   extend ToProcInterface::CallToMaybe
  module CallToMaybe
    include Mixin

    # @see #initialize
    # @see #call
    # @return [Dry::Monads::Maybe]
    def call(*args, **opts, &block)
      instance = new(*args, **opts, &block)
      result = instance.call
      result.to_maybe
    end
  end

  # Interface with predefined {#call} method which delegates all the given params into class' constructor.
  #
  # @example Usage
  #   extend ToProcInterface::Initializer
  module Initializer
    include Mixin

    # @see #initialize
    # @return [self]
    def call(*args, **opts, &block)
      new(*args, **opts, &block)
    end
  end

  # Interface with predefined {#call} method which delegates all the given params into class' constructor
  # and invokes instance's {#perform} method.
  #
  # @example Usage
  #   extend ToProcInterface::PerformingService
  module PerformingService
    include Mixin

    # @see #initialize
    # @see #perform
    def call(*args, **opts, &block)
      new(*args, **opts, &block).perform
    end
  end

  # Singleton variation. {#to_proc} & {#call} delegated to {ToProcInterface::Singleton::ClassMethods.instance}
  #
  # @example Usage
  #   include ToProcInterface::Singleton
  module Singleton
    include ToProcInterface

    class << self
      # @api private
      private def included(base)
        if base.is_a?(Class)
          base.include ::Singleton
          base.extend ClassMethods
        end
        super if defined?(super)
      end
    end

    # @private
    module ClassMethods
      # @see ToProcInterface#to_proc
      # @return [Proc]
      def to_proc
        instance.to_proc
      end

      # @see #call
      def call(*args, **opts, &block)
        instance.call(*args, **opts, &block)
      end

      include Delegations
    end
  end
end