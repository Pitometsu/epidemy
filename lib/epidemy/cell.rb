module Epidemy
  class Cell
    def initialize(options = {})
      @player = options[:player]
      @owner = options[:owner]
    end

    attr_reader :player, :owner

    def to_print
      if @player
        if @owner
          ' # '.colorize(color: @player.color, background: @owner.color)
        else
          ' X '.colorize(color: @player.color)
        end
      else
        '   '
      end
    end

    def select(player)
      if @player
        @owner = player unless @owner # TODO: handle reselaction @owner
      else
        @player = player
      end
    end
  end
end
