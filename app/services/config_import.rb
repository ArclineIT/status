# Loads a status.yaml written for the original arcline-status generator.
# Components are matched by name, incidents by title and start time, and
# maintenance by title and start time, so importing twice changes nothing.
class ConfigImport
  def initialize(config)
    @config = config || {}
  end

  def call
    ActiveRecord::Base.transaction do
      { components: import_components, incidents: import_incidents, maintenances: import_maintenance }
    end
  end

  private
    def import_components
      Array(@config["components"]).each_with_index.count do |entry, index|
        Component.find_or_initialize_by(name: entry.fetch("name")).update!(status: entry["status"].presence || "operational", position: index)
      end
    end

    def import_incidents
      Array(@config["incidents"]).count do |entry|
        started_at = time(entry.fetch("started"))
        incident = Incident.find_or_initialize_by(title: entry.fetch("title"), started_at: started_at)
        incident.update!(status: entry["status"].presence || "investigating", severity: entry["severity"].presence || "minor",
                         resolved_at: entry["resolved"] && time(entry["resolved"]))

        updates = Array(entry["updates"])
        incident.updates.destroy_all
        updates.each_with_index do |update, index|
          # The file only records the incident's final status, so earlier updates are shown as investigating.
          status = index == updates.size - 1 ? incident.status : "investigating"
          incident.updates.create!(status: status, body: update.fetch("body"), posted_at: time(update.fetch("time")))
        end
      end
    end

    def import_maintenance
      Array(@config["maintenance"]).count do |entry|
        Maintenance.find_or_initialize_by(title: entry.fetch("title"), starts_at: time(entry.fetch("starts")))
                   .update!(ends_at: time(entry.fetch("ends")), body: entry["body"].to_s)
      end
    end

    def time(value)
      value.is_a?(Time) ? value : Time.zone.parse(value.to_s) || raise(ArgumentError, "unreadable time #{value.inspect}")
    end
end
