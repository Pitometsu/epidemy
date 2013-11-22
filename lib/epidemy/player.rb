module Epidemy
  class Player
    def initialize(options = {})
      @color = options[:color]
      @name  = options[:name]
    end

    attr_reader :color, :name

  end
end
