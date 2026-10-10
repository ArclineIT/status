require "test_helper"

class StatusModelsTest < ActiveSupport::TestCase
  test "the overall state is the worst component" do
    assert_equal "operational", Component.overall
    components(:dns).update!(status: "maintenance")
    assert_equal "maintenance", Component.overall
    components(:hosting).update!(status: "degraded")
    assert_equal "degraded", Component.overall
    components(:dns).update!(status: "outage")
    assert_equal "outage", Component.overall
    assert_equal "operational", Component.overall(Component.none)
  end

  test "a component needs a unique name and a known status" do
    assert_not Component.new(name: "Shared Hosting").valid?
    assert_not Component.new(name: "X", status: "on fire").valid?
  end

  test "opening an incident records its first update" do
    incident = Incident.open!(title: " API errors ", severity: "major", body: "Looking into it.")

    assert_equal [ "API errors", "investigating", "major" ], incident.values_at(:title, :status, :severity)
    assert_equal [ "Looking into it." ], incident.updates.map(&:body)
    assert_includes Incident.active, incident
  end

  test "an incident with no first update is not opened" do
    assert_no_difference -> { Incident.count } do
      assert_raises(ActiveRecord::RecordInvalid) { Incident.open!(title: "API errors", severity: "major", body: " ") }
    end
  end

  test "updates move the incident along, and resolving closes it" do
    incident = Incident.open!(title: "API errors", severity: "major", body: "Looking into it.", started_at: 2.hours.ago)

    incident.post_update!(status: "identified", body: "Bad deploy.")
    assert_equal "identified", incident.status
    assert_nil incident.resolved_at

    incident.post_update!(status: "resolved", body: "Rolled back.")
    assert incident.resolved?
    assert_in_delta 2.hours, incident.duration, 5
    assert_equal %w[ resolved identified investigating ], incident.updates.reload.map(&:status)
    assert_not_includes Incident.active, incident

    incident.post_update!(status: "monitoring", body: "It came back.")
    assert_nil incident.resolved_at, "reopening clears the resolved time"
  end

  test "history is resolved incidents from the last 90 days" do
    assert_equal [ incidents(:resolved_blip) ], Incident.history.to_a
  end

  test "maintenance follows the clock and must end after it starts" do
    window = Maintenance.new(title: "X", starts_at: Time.utc(2026, 3, 10, 2), ends_at: Time.utc(2026, 3, 10, 4))

    assert_equal "scheduled", window.status(Time.utc(2026, 3, 10, 1))
    assert_equal "in_progress", window.status(Time.utc(2026, 3, 10, 3))
    assert_equal "completed", window.status(Time.utc(2026, 3, 10, 5))

    assert_not Maintenance.new(title: "X", starts_at: Time.current, ends_at: 1.hour.ago).valid?
    assert_equal [ maintenances(:upgrade) ], Maintenance.upcoming.to_a
    assert_equal [ maintenances(:done) ], Maintenance.past.to_a
  end

  test "the page headline reflects components and open incidents" do
    assert_equal [ "operational", "All systems operational" ], StatusPage.new.then { |page| [ page.state, page.headline ] }

    Incident.open!(title: "API errors", severity: "minor", body: "Looking.")
    assert_equal [ "degraded", "We are looking into a problem" ], StatusPage.new.then { |page| [ page.state, page.headline ] }

    components(:dns).update!(status: "outage")
    assert_equal [ "outage", "Some systems are down" ], StatusPage.new.then { |page| [ page.state, page.headline ] }
  end
end
