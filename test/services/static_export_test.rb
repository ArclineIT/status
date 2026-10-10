require "test_helper"

class StaticExportTest < ActiveSupport::TestCase
  setup { @directory = Rails.root.join("tmp", "static-export-test-#{SecureRandom.hex(4)}") }
  teardown { FileUtils.rm_rf(@directory) }

  test "writes two self-contained pages" do
    components(:dns).update!(status: "outage")
    files = StaticExport.new(@directory).call

    assert_equal %w[ history.html index.html ], files.map { |file| file.basename.to_s }.sort
    index = @directory.join("index.html").read
    history = @directory.join("history.html").read

    assert_includes index, "Some systems are down"
    assert_includes index, "NVMe storage upgrade"
    assert_includes history, "Brief network disruption"
    assert_not_includes history, "Old outage"

    [ index, history ].each do |html|
      assert_includes html, "<style>"
      assert_no_match(/<script|<link|src=|url\(/, html, "nothing may be loaded from elsewhere")
      assert_equal %w[ history.html index.html ], html.scan(/href="([^"]*)"/).flatten.uniq.sort
    end
  end
end
