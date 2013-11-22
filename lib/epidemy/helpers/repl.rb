module Epidemy
  module Repl

    ERROR_STRING = "Hint"

    def repl_until(hint = "", options = {})
      loop do
        result = yield
        key = options.keys.find { |condition| condition.call result }

        if key
          put_msg options[key].call, hint: hint, color: :yellow, mode: :bold
          return result

        end
      end
    end

    def repl_while(options = {})
      loop do
        result = yield
        key = options.keys.find { |condition| condition.call result }

        return result unless key

        put_err options[key]
      end
    end

    def put_err(message)
      put_msg message, hint: ERROR_STRING, color: :red, mode: :bold
    end

    def put_msg(message, hint: "", color: :default, mode: :default)
      puts prompt(hint, mode: :bold) << message.colorize(mode: :bold)
    end

    def get_msg(hint = "", color: :default, mode: :bold)
      print prompt(hint, color: color, mode: mode)
      gets.strip
    end

    def prompt(hint = "", color: :default, mode: :default)
      prompt = "#{$APP_NAME.upcase} |".colorize(mode: :bold)
      prompt << " #{hint}".colorize(color: color, mode: mode) unless hint.empty?
      prompt << " : ".colorize(mode: :bold)
    end
  end
end
