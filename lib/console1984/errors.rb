module Console1984
  module Errors
    class ProtectedConnection < StandardError
      def initialize(details)
        super "A connection attempt was prevented because it represents a sensitive access."\
          "Please run decrypt! and try again. You will be asked to justify this access: #{details}"
      end
    end

    class ForbiddenCommand < StandardError; end
    class ForbiddenIncineration < StandardError; end
    class ForbiddenCodeManipulation < StandardError; end
  end
end
