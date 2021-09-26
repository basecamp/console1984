# Prevents accessing trail model tables when executing console commands.
module Console1984::Ext::ActiveRecord::ProtectedAuditableTables
  include Console1984::Freezeable

  %i[ execute exec_query exec_insert exec_delete exec_update exec_insert_all ].each do |method|
    define_method method do |*args, **kwargs|
      sql = args.first
      if Console1984.command_executor.executing_user_command? && sql.b =~ auditable_tables_regexp
        raise Console1984::Errors::ForbiddenCommandAttempted, "#{sql}"
      else
        super(*args, **kwargs)
      end
    end
  end

  private
    def auditable_tables_regexp
      @auditable_tables_regexp ||= Regexp.new("#{auditable_tables.join("|")}")
    end

    def auditable_tables
      @auditable_tables ||= Console1984.command_executor.run_as_system { auditable_models.collect(&:table_name) }
    end

    def auditable_models
      @auditable_models ||= Console1984::Base.descendants
    end
end
