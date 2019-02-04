module Rung
  module Runner
    # Internal {Rung::Runner::Runner} context. It encapsulates
    # operation instance, state hash and internal flags
    class RunContext
      extend Forwardable

      # @param operation_instance [Rung::Operation]
      # @param initial_state [Hash]
      def initialize(operation_instance, initial_state)
        @operation_instance = operation_instance
        @state = initial_state
        @failed = false
        @stopped = false
      end

      def_delegators :operation_class,
        :steps_definition, :around_callbacks,
        :around_each_callbacks
      attr_reader :operation_instance, :state

      def operation_class
        operation_instance.class
      end

      # Marks operation run as failure
      def fail!
        @failed = true
      end

      # immediately stops operation run
      def stop!
        @stopped = true
      end

      # @return [false] if {#stop!} was called
      # @return [true] otherwise
      def stopped?
        @stopped
      end

      # @return [false] if {#fail!} was called
      # @return [true] otherwise
      def success?
        !@failed
      end

      # Transforms internal state to public state
      # @return [Rung::State]
      def to_state
        State.new state, success?, operation_instance
      end
    end
  end
end
