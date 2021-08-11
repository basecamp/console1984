require "rouge"

module Console1984
  module ApplicationHelper
    def format_date(date)
      # <time datetime="2016-1-1">11:09 PM - 1 Jan 2016</time>
      date.strftime("%Y-%m-%d")
    end

    def highlight_code(source)
      formatter = Rouge::Formatters::HTML.new
      lexer = Rouge::Lexers::Shell.new
      formatter.format(lexer.lex(source)).html_safe
    end
  end
end
