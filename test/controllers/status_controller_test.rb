require "test_helper"

class StatusControllerTest < ActionDispatch::IntegrationTest
  test "the public page shows components, upcoming maintenance and no admin links" do
    get root_path

    assert_response :success
    assert_select "h1", /All systems operational/
    assert_select ".status-row__label", text: "Client Portal"
    assert_select ".incident__title", text: "NVMe storage upgrade"
    assert_select ".incident__title", text: "Kernel patching", count: 0
    assert_select "a[href^='/admin']", count: 0
    assert_select "form", count: 0
  end

  test "an open incident leads the page with its updates" do
    incident = Incident.open!(title: "Elevated API errors", severity: "major", body: "We are investigating.")
    incident.post_update!(status: "identified", body: "A bad deploy.\n\nRolling back.")
    get root_path

    assert_select "h1", /We are looking into a problem/
    assert_select ".incident__title", text: "Elevated API errors"
    assert_select ".incident__updates li", 2
    assert_select ".incident__updates li:first-child strong", "Identified"
  end

  test "history lists recent resolved incidents and past maintenance" do
    get history_path

    assert_response :success
    assert_select ".incident__title", text: "Brief network disruption"
    assert_select ".incident__title", text: "Old outage", count: 0
    assert_select ".status-row__label", text: "Kernel patching"
  end

  test "status is available as JSON" do
    components(:dns).update!(status: "degraded")
    get status_path(format: :json)

    body = response.parsed_body
    assert_equal [ "degraded", "Some systems are degraded" ], body.values_at("status", "headline")
    assert_includes body["components"], { "name" => "DNS", "status" => "degraded" }
    assert_equal "scheduled", body["maintenance"].sole["status"]
  end

  test "the feed lists incidents with their updates" do
    get feed_path

    assert_response :success
    assert_equal "application/xml; charset=utf-8", response.headers["Content-Type"]
    assert_includes response.body, "<title>[resolved] Brief network disruption</title>"
    assert_includes response.body, "upstream BGP flap"
  end

  test "user text is escaped" do
    Incident.open!(title: "<script>alert(1)</script>", severity: "minor", body: "<img src=x onerror=alert(1)>")
    get root_path

    assert_no_match "<script>alert(1)</script>", response.body
    assert_no_match "<img src=x", response.body
  end
end
