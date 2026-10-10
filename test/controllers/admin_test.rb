require "test_helper"

class AdminTest < ActionDispatch::IntegrationTest
  test "sets, adds and removes components" do
    patch admin_component_path(components(:dns)), params: { component: { status: "outage" } }
    assert_equal "outage", components(:dns).reload.status
    assert_equal "DNS is now outage.", flash[:notice]

    patch admin_component_path(components(:dns)), params: { component: { status: "exploded" } }
    assert_equal "outage", components(:dns).reload.status
    assert flash[:alert].present?

    assert_difference -> { Component.count } do
      post admin_components_path, params: { component: { name: "Email" } }
    end
    assert_equal 2, Component.find_by!(name: "Email").position

    assert_difference -> { Component.count }, -1 do
      delete admin_component_path(components(:hosting))
    end
  end

  test "opens an incident, posts updates and resolves it" do
    get new_admin_incident_path
    assert_response :success

    assert_difference -> { Incident.count } do
      post admin_incidents_path, params: { incident: { title: "API errors", severity: "major", status: "investigating", body: "Looking into it." } }
    end
    incident = Incident.order(:id).last
    assert_redirected_to admin_incident_path(incident)

    get admin_incident_path(incident)
    assert_select ".incident__updates li", 1

    post post_update_admin_incident_path(incident), params: { incident_update: { status: "resolved", body: "Fixed." } }
    assert incident.reload.resolved?

    post post_update_admin_incident_path(incident), params: { incident_update: { status: "resolved", body: " " } }
    assert_match "Body can't be blank", flash[:alert]
  end

  test "an incident without a first update is sent back to the form" do
    assert_no_difference -> { Incident.count } do
      post admin_incidents_path, params: { incident: { title: "API errors", severity: "major", status: "investigating", body: "" } }
    end
    assert_response :unprocessable_entity
    assert_select "input[name='incident[title]'][value='API errors']"
  end

  test "schedules and removes maintenance" do
    get new_admin_maintenance_path
    assert_response :success

    assert_difference -> { Maintenance.count } do
      post admin_maintenances_path, params: { maintenance: { title: "Router firmware", starts_at: "2027-01-10T02:00", ends_at: "2027-01-10T04:00", body: "Blips." } }
    end

    post admin_maintenances_path, params: { maintenance: { title: "Backwards", starts_at: "2027-01-10T04:00", ends_at: "2027-01-10T02:00" } }
    assert_response :unprocessable_entity
    assert_select ".form__errors li", text: "Ends at must be after the start"

    assert_difference -> { Maintenance.count }, -1 do
      delete admin_maintenance_path(maintenances(:done))
    end
  end

  test "deletes an incident with its updates" do
    assert_difference -> { Incident.count } => -1, -> { IncidentUpdate.count } => -2 do
      delete admin_incident_path(incidents(:resolved_blip))
    end
  end
end
