require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  setup do
    @settings = Rails.configuration.x.status
    @settings.username, @settings.password = "admin", "s3cret-pass"
  end

  teardown { @settings.username = @settings.password = nil }

  test "the admin area asks for the configured credentials" do
    get admin_root_path
    assert_response :unauthorized

    get admin_root_path, headers: basic("admin", "wrong")
    assert_response :unauthorized

    get admin_root_path, headers: basic("admin", "s3cret-pass")
    assert_response :success
    assert_select "select[name='component[status]']", 2
  end

  test "nothing can be changed without credentials" do
    assert_no_difference [ -> { Component.count }, -> { Incident.count }, -> { Maintenance.count } ] do
      post admin_components_path, params: { component: { name: "X" } }
      delete admin_component_path(components(:dns))
      post admin_incidents_path, params: { incident: { title: "X", severity: "minor", body: "x" } }
      post post_update_admin_incident_path(incidents(:resolved_blip)), params: { incident_update: { status: "monitoring", body: "x" } }
      delete admin_maintenance_path(maintenances(:done))
    end
    patch admin_component_path(components(:dns)), params: { component: { status: "outage" } }

    assert_response :unauthorized
    assert_equal "operational", components(:dns).reload.status
  end

  test "the public pages stay open" do
    [ root_path, history_path, feed_path, status_path(format: :json), rails_health_check_path ].each do |path|
      get path
      assert_response :success, path
    end
  end

  private
    def basic(username, password)
      { "Authorization" => ActionController::HttpAuthentication::Basic.encode_credentials(username, password) }
    end
end
