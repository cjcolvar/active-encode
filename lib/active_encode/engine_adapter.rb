require 'active_encode/engine_adapters'
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/string/inflections'

module ActiveEncode
  # The <tt>ActiveEncode::EngineAdapter</tt> module is used to load the
  # correct adapter. The default engine adapter is the :active_job engine.
  module EngineAdapter #:nodoc:
    extend ActiveSupport::Concern

    included do
      class_attribute :_engine_adapter, instance_accessor: false, instance_predicate: false
      self.engine_adapter = :inline
    end

    # Includes the setter method for changing the active engine adapter.
    module ClassMethods
      def engine_adapter
        _engine_adapter
      end

      # Specify the backend engine provider. The default engine adapter
      # is the :inline engine. See QueueAdapters for more
      # information.
      def engine_adapter=(name_or_adapter_or_class)
        self._engine_adapter = interpret_adapter(name_or_adapter_or_class)
      end

      private

      def interpret_adapter(name_or_adapter_or_class)
        case name_or_adapter_or_class
        when Symbol, String
          ActiveEncode::EngineAdapters.lookup(name_or_adapter_or_class).new
        else
          if engine_adapter?(name_or_adapter_or_class)
            name_or_adapter_or_class
          else
            raise ArgumentError
          end
        end
      end

      ENGINE_ADAPTER_METHODS = [:create, :find, :list, :cancel, :purge].freeze

      def engine_adapter?(object)
        ENGINE_ADAPTER_METHODS.all? { |meth| object.respond_to?(meth) }
      end

    end
  end
end
