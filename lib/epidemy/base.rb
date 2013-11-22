# -*- coding: utf-8 -*-
require 'colorize'
require_relative 'helpers/repl'
require_relative 'player'
require_relative 'field'
require 'byebug'

module Epidemy
  class Base
    include Repl

    MIN_PLAYER_NUMBER = 2
    MAX_PLAYER_NUMBER = 4
    DEFAULT_PLAYERS_NUMBER = MIN_PLAYER_NUMBER
    DEFAULT_FIELD_SIZE = {width: 8, height: 8}
    CORNERS_HINT = '(top left - 1, top right - 2, ' \
      'bottom right - 3, bottom left - 4)'

    def initialize
      @players = []
    end

    def default(argv)
      gameplay
    end

    def gameplay
      create_players
      create_field

      conditions =
        {->(result) { result && result[:win]
         } => ->(regular) do
           "Congratulations, #{result[:player].name} you win!"
         end }

      result = repl_until('Victory!!!', conditions) { turn }
    end

    def turn
      @players.each do |player|
        show_field
        result = @regular ? regular_turn(player) : first_turn(player)

        return result if result[:win]
      end
      @regular ||= true
      false
    end

    def first_turn(player)
      conditions = {->(result) { (result[:str] =~ /\A[1-4]\Z/).nil?
                    } => 'Select one of corners ' + CORNERS_HINT} # TODO: busy corner

      result = repl_while(conditions) do
        message = "#{player.name}, select edge for first point " + CORNERS_HINT
        input = get_msg message, color: player.color

        number_input_result(input)
      end

      location = location_from_corner(result[:num])
      select_location(player, location)
    end

    def location_from_corner(number)
      max_row = @field.cells.row_size - 1
      max_column = @field.cells.column_size - 1
      indexes = [0, max_row].product([0, max_column])[number - 1]
      to_location indexes
    end

    def regular_turn(player)
      conditions =
        {->(location) { !((0...@field.cells.row_size)    === location[:row] &&
                          (0...@field.cells.column_size) === location[:column])
         } => "Please, select location inside field " \
           "(#{@field.cells.row_size} x #{@field.cells.column_size})",
         ->(location) { @field.busy?(location)
         } => 'This location already busy', # FIXME: logic
         ->(location) { @field.owned?(location)
         } => 'This location already owned',
         -> (location) { !@field.available?(player, location)
         } => 'Select next to your point, ' \
           'or your connected owned point'}

      location = repl_while(conditions) do
        get_location(player)
      end

      select_location(player, location)
    end

    def get_location(player)
      conditions =
        {->(location) { (location =~ /\A\d+\s*.\s*\d+\Z/).nil?
         } => 'Location should have format: row x column'}

      location = repl_while(conditions) do
        message = "#{player.name}, select point location (row x column)"
        get_msg message, color: player.color
      end

      matches = location.scan(/\d+/)
      indexes = matches.map { |e| e.to_i - 1 }
      to_location indexes
    end

    def field_line(length)
      Array.new(length, '───')
    end

    def field_open_line(length)
      string = ?┌ + field_line(length) * ?┬ + ?┐ + ?\n
      string.colorize(mode: :bold)
    end

    def field_close_line(length)
      string = ?└ + field_line(length) * ?┴ + ?┘ + ?\n
      string.colorize(mode: :bold)
    end

    def field_row_line(length)
      string = field_line(length) * ?┼
      ?├.colorize(mode: :bold) + string + ?┤.colorize(mode: :bold) + ?\n
    end

    def show_field
      rows = @field.cells.to_a.map do |row|
        border = ?│.colorize(mode: :bold)
        border + row.map(&:to_print) * ?│ + border + ?\n
      end

      length = @field.cells.column_size
      field_rows = rows * field_row_line(length)
      field = field_open_line(length) + field_rows + field_close_line(length)
      puts ?\n + field
    end

    def create_field
      @field = Field.new(get_field_size)
    end

    def get_field_size
      conditions =
        {->(size) { (size =~ /\d+\s*.\s*\d+/).nil?
         } => 'Dimensions should have format: width x height'} # TODO: check min & max sizes

      size = repl_while(conditions) do
        input = get_msg "Select field size (width x height) " \
          "[#{DEFAULT_FIELD_SIZE[:width]}x#{DEFAULT_FIELD_SIZE[:height]}]"
        return DEFAULT_FIELD_SIZE if input.empty?

        input
      end

      matches = size.scan(/\d+/)
      indexes = matches.map(&:to_i)
      to_size indexes
    end

    def create_players
      players_count = get_players_count
      put_msg "#{players_count} players"
      players_count.times do
        @players << get_player
      end
    end

    def get_players_count
      conditions =
        {->(result) { result[:num].to_s != result[:str]
         } => 'Number should be numeric',
         ->(result) { !result[:num].between?(MIN_PLAYER_NUMBER,
                                             MAX_PLAYER_NUMBER)
         } => "Number should be between #{MIN_PLAYER_NUMBER} and " \
           "#{MAX_PLAYER_NUMBER}"}

      result = repl_while(conditions) do
        input = get_msg "Select number of players " \
          "(#{MIN_PLAYER_NUMBER}..#{MAX_PLAYER_NUMBER}) " \
          "[#{DEFAULT_PLAYERS_NUMBER}]"
        return DEFAULT_PLAYERS_NUMBER if input.empty?

        number_input_result(input)
      end
      result[:num]
    end

    def get_player
      name_conditions =
        {->(name) { @players.map(&:name).include? name
         } => 'Same name already used',
         ->(name) { name.empty? } => "Name shouldn't be empty"}

      player_name = repl_while(name_conditions) { get_msg('Player name') }

      color_conditions =
        {->(color) { !String::COLORS.keys.include?(color)
         } => String::COLORS.keys.unshift("Color should be one of:") * "\n  ",
         ->(color) { @players.map(&:color).include? color
         } => 'Same color already used'}

      player_color = repl_while(color_conditions) do
        get_msg("Color for #{player_name}").to_sym
      end

      Player.new(name: player_name, color: player_color)
    end

    def select_location(player, location)
      win = @field.select(player, location)
      {player: player, win: win}
    end

    def number_input_result(input)
      {str: input, num: input.to_i}
    end

    def to_location(array)
      Hash[[:row, :column].zip(array)]
    end

    def to_size(array)
      Hash[[:width, :height].zip(array)]
    end
  end
end
