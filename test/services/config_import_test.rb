require "test_helper"

class ConfigImportTest < ActiveSupport::TestCase
  setup do
    [ IncidentUpdate, Incident, Maintenance, Component ].each(&:delete_all)
    @config = YAML.safe_load_file(Rails.root.join("status.example.yaml"), permitted_classes: [ Time ])
  end

  test "imports the example file" do
    counts = ConfigImport.new(@config).call

    assert_equal({ components: 6, incidents: 1, maintenances: 1 }, counts)
    assert_equal [ "Client Portal", "Billing", "Threat Monitoring", "DNS / Nameservers", "Email", "Network" ], Component.ordered.map(&:name)

    incident = Incident.sole
    assert_equal [ "Brief network disruption", "resolved", "minor" ], incident.values_at(:title, :status, :severity)
    assert_equal Time.utc(2026, 2, 28, 15, 30), incident.resolved_at
    assert_equal [ [ "resolved", "Issue resolved. Root cause: upstream BGP flap." ], [ "investigating", "Investigating reports of connectivity issues." ] ],
                 incident.updates.map { |update| [ update.status, update.body ] }

    window = Maintenance.sole
    assert_equal [ "NVMe storage upgrade", Time.utc(2026, 3, 10, 2), Time.utc(2026, 3, 10, 4) ], window.values_at(:title, :starts_at, :ends_at)
  end

  test "importing again updates in place" do
    ConfigImport.new(@config).call
    @config["components"].first["status"] = "degraded"

    assert_no_difference [ -> { Component.count }, -> { Incident.count }, -> { IncidentUpdate.count }, -> { Maintenance.count } ] do
      ConfigImport.new(@config).call
    end
    assert_equal "degraded", Component.find_by!(name: "Client Portal").status
  end

  test "a bad value anywhere rolls the whole import back" do
    @config["incidents"].first["severity"] = "apocalyptic"

    assert_raises(ActiveRecord::RecordInvalid) { ConfigImport.new(@config).call }
    assert_equal 0, Component.count
  end

  test "an empty file imports nothing" do
    assert_equal({ components: 0, incidents: 0, maintenances: 0 }, ConfigImport.new(nil).call)
  end
end
