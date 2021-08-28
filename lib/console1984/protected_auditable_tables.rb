# Prevents accessing trail model tables when executing console commands.
module Console1984::ProtectedAuditableTables
  include Console1984::Freezeable

  %i[ execute exec_query exec_insert exec_delete exec_update exec_insert_all ].each do |method|
    define_method method do |*args|
      sql = args.first
      if Console1984.supervisor.executing_user_command? && sql =~ auditable_tables_regexp
        raise Console1984::Errors::ForbiddenCommand, "#{sql}"
      else
        super(*args)
      end
    end
  end

  private
    def auditable_tables_regexp
      @auditable_tables_regexp ||= Regexp.new("#{auditable_tables.join("|")}")
    end

    def auditable_tables
      @auditable_tables ||= Console1984::Base.descendants.collect(&:table_name)
    end

    include Console1984::Freezeable
end
