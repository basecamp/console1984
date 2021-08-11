require_dependency "console1984/application_controller"

module Console1984
  class SessionsController < ApplicationController
    before_action :set_filtered_sessions

    def index
      @sessions = @filtered_sessions.all
    end

    def show
      @session = Console1984::Session.find(params[:id])
      @audit = @session.audits.find_by(auditor: Current.auditor) || @session.audits.build(auditor: Current.auditor)
    end

    private
      def set_filtered_sessions
        @filtered_sessions = Console1984::FilteredSessions.resume(session[:filtered_sessions])
      end
  end
end
