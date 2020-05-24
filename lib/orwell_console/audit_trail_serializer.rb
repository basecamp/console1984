module OrwellConsole
  class AuditTrailSerializer < RailsStructuredLogging::Serializers::Elastic::BaseSerializer
    def serialize
      encode do |json|
        json.console do
          json.user audit_trail.user
          json.reason audit_trail.reason
          json.statements audit_trail.statements
        end
      end
    end

    private
      def audit_trail
        payload.fetch(:audit_trail)
      end
  end
end
