module Rung
  class Steps
    extend Forwardable

    def initialize
      @list = []
    end

    def_delegators :@list, :push, :each
  end
end
