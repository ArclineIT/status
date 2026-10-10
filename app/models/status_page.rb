# Everything the public page shows, gathered once.
class StatusPage
  HEADLINES = {
    "operational" => "All systems operational", "degraded" => "Some systems are degraded",
    "outage" => "Some systems are down", "maintenance" => "Maintenance in progress"
  }.freeze

  attr_reader :components, :incidents, :maintenances, :generated_at

  def initialize(now: Time.current)
    @generated_at = now
    @components = Component.ordered.to_a
    @incidents = Incident.active.includes(:updates).to_a
    @maintenances = Maintenance.upcoming(now).to_a
  end

  def title = Rails.configuration.x.status.title
  def overall = Component.overall(components)

  # An open incident is news even if nobody has changed a component yet.
  def headline
    return "We are looking into a problem" if overall == "operational" && incidents.any?

    HEADLINES.fetch(overall)
  end

  def state
    overall == "operational" && incidents.any? ? "degraded" : overall
  end

  def as_json(*)
    {
      title: title, status: state, headline: headline, generated_at: generated_at.utc.iso8601,
      components: components.map { |component| { name: component.name, status: component.status } },
      incidents: incidents.map do |incident|
        { title: incident.title, status: incident.status, severity: incident.severity, started_at: incident.started_at.utc.iso8601,
          updates: incident.updates.map { |update| { status: update.status, body: update.body, posted_at: update.posted_at.utc.iso8601 } } }
      end,
      maintenance: maintenances.map do |maintenance|
        { title: maintenance.title, status: maintenance.status(generated_at), starts_at: maintenance.starts_at.utc.iso8601, ends_at: maintenance.ends_at.utc.iso8601 }
      end
    }
  end
end
