module Console1984
  class AuditTrailSerializer < RailsStructuredLogging::Serializers::Elastic::BaseSerializer
    def serialize
      encode do |json|
        json.console do
          json.session_id audit_trail.session_id
          json.user audit_trail.user
          json.commands audit_trail.commands
          json.sensitive audit_trail.sensitive

          json.access_reason do
            json.for_session audit_trail.access_reason.for_session
            json.for_commands audit_trail.access_reason.for_commands
            json.for_sensitive_access audit_trail.access_reason.for_sensitive_access
          end
        end
      end
    end

    private
      def audit_trail
        payload.fetch(:audit_trail)
      end
  end
end
