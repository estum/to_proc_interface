# frozen_string_literal: true

module ToProcInterface
  # The namespace for hook mixins & the composition mixin.
  #
  # @example Usage
  #   module MyToProcInterface
  #     include ToProcInterface::Mixin
  #     include ToProcInterface::Delegations
  #     extend ToProcInterface::Hooks
  #   end
  module Hooks
    # The mixin contains the {Class.inherited} hook for the proper memoization of {#to_proc} singleton class method.
    # It is neccessary to use it when extending a singleton class with the interface.
    # @api private
    module Inherited
      # @param subclass [Class]
      # @return [void]
      private def inherited(subclass)
        if subclass.instance_variable_defined?(:@to_proc)
          subclass.remove_instance_variable(:@to_proc)
          subclass.to_proc
        end
        super
      end
    end

    # The mixin hooks the {#extend_object} method that selects
    # the proper extension.
    #
    # @example Usage
    #   module Extension
    #     include ToProcInterface
    #     extend Hooks::Extended
    #   end
    #
    #   class Example
    #     # @!parse extend ToProcInterface::Hooks::Inherited
    #     extend Extension
    #   end
    #
    # @api private
    module Extended
      # @return [void]
      #
      # @overload extend_object(module_object)
      #   @param module_object [Module]
      #   Extends the target module {ToProcInterface::Hooks::Included}.
      #
      # @overload extend_object(class_object)
      #   @param class_object [Class]
      #   Extends the target class with {ToProcInterface::Hooks::Inherited}
      private def extend_object(object)
        case object
        when Class
          object.extend Inherited
        when Module
          object.extend Included
        end
        super
      end
    end

    # @example Usage
    #   module Mixin
    #     # @!parse extend ToProcInterface::Hooks::Included
    #     include ToProcInterface
    #   end
    #
    #   class Example
    #     extend Mixin
    #   end
    #
    # @api private
    module Included
      # @return [void]
      #
      # @overload append_features(module_object)
      #   @param module_object [Module]
      #   Extends the target module (unless it is the namespaced {ToProcInterface::Singleton} mixin)
      #   with {Hooks::Extended}.
      #
      # @overload append_features(class_object)
      #   @param class_object [Class]
      #   Does nothing if includes to {Class}
      private def append_features(base)
        return false if base < self

        case base
        when Class
          super
        when Module
          super
          base.extend Extended unless ToProcInterface.const_defined?(:Singleton) && base == Singleton
        end
      end
    end

    include Extended
    include Included
  end
end
