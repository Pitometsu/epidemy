require 'matrix'
require_relative 'cell'
require_relative 'player'

module Epidemy
  class Field
    def initialize(options = {})
      @cells = Matrix.build(options[:width], options[:height]) { Cell.new }
    end

    attr_reader :cells

    def select(player, options = {})
      @cells[options[:row], options[:column]].select player
      win?
    end

    def win?
      false # TODO: give a chance
    end

    def busy?(options = {})
      @cells[options[:row], options[:column]].player == options[:player]
    end

    def owned?(options = {})
      !@cells[options[:row], options[:column]].owner.nil?
    end

    def available?(player, options = {})
      adjacent?(options[:row], options[:column], player)
    end

    def adjacent?(row, column, player)
      adjacent_cells(row, column).any? { |cell| cell.player == player }
    end

    def adjacent_cells(row, column)
      near(row).product(near(column)).map { |index| @cells[*index] }.compact
    end

    def near(number)
      (-1..1).map { |e| e + number }
    end
  end
end
