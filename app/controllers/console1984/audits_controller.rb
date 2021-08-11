require_dependency "console1984/application_controller"

module Console1984
  class AuditsController < ApplicationController
    before_action :set_session
    before_action :set_audit, only: %i[ update ]

    def create
      @session.audits.create!(audit_param.merge(auditor: Current.auditor))
      redirect_to sessions_path
    end

    def update
      @audit.update!(audit_param)
      redirect_to sessions_path
    end

    private
      def set_session
        @session = Session.find(params[:session_id])
      end

      def set_audit
        @audit = @session.audits.find(params[:id])
      end

      def audit_param
        params.require(:audit).permit(:notes, :status)
      end
  end
end
