module Rung
  class State
    def initialize(initial_state)
      @state = initial_state
    end

    extend Forwardable
    def_delegators :@state, :[], :[]=
  end
end
