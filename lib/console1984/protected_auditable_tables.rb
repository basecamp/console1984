module Console1984
  module ProtectedAuditableTables
    %i[ execute exec_query exec_insert exec_delete exec_update exec_insert_all ].each do |method|
      define_method method do |*args|
        sql = args.first
        if Console1984.supervisor.executing_user_command? && sql =~ auditable_tables_regexp
          puts "Se detecta: #{sql}"
          raise Console1984::Errors::ForbiddenCommand, "#{sql}"
        else
          super(*args)
        end
      end
    end

    private
      AUDITABLE_MODELS = [ Console1984::User, Console1984::Session, Console1984::Command, Console1984::SensitiveAccess,
                          Console1984::Audit ]

      def auditable_tables_regexp
        @auditable_tables_regexp ||= Regexp.new("#{auditable_tables.join("|")}")
      end

      def auditable_tables
        # Not using Console1984::Base.descendants to make this work without eager loading
        @auditable_tables ||= AUDITABLE_MODELS.collect(&:table_name)
      end
  end
end
