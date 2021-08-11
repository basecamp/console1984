require_dependency "console1984/application_controller"

module Console1984
  class FilteredSessionsController < ApplicationController
    def update
      session[:filtered_sessions] = Console1984::FilteredSessions.new(filtered_sessions_param).to_h
      redirect_to sessions_path
    end

    private
      def filtered_sessions_param
        params.require(:filtered_sessions).permit(:sensitive_only)
      end
  end
end
