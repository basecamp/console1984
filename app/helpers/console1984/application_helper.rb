require "rouge"

module Console1984
  module ApplicationHelper
    def format_date(date)
      # <time datetime="2016-1-1">11:09 PM - 1 Jan 2016</time>
      date.strftime("%Y-%m-%d")
    end

    def format_date_and_time(date)
      # <time datetime="2016-1-1">11:09 PM - 1 Jan 2016</time>
      date.strftime("%Y-%m-%d at %I:%m %P")
    end

    def highlighted_code_from(commands)
      highlight_code commands.collect(&:statements).collect(&:strip).filter(&:present?).join("\n")
    end

    def highlight_code(source)
      formatter = Rouge::Formatters::HTMLLinewise.new(Rouge::Formatters::HTML.new)
      lexer = Rouge::Lexers::Ruby.new
      formatter.format(lexer.lex(source)).html_safe
    end
  end
end
