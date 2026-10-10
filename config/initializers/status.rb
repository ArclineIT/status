Rails.application.configure do
  config.x.status.title = ENV.fetch("STATUS_TITLE", "Arcline Status")
  # Public address of the page, used in the feed.
  config.x.status.base_url = ENV.fetch("STATUS_BASE_URL", "https://status.arclineit.com").chomp("/")
  # HTTP basic auth for the admin area. Required in production.
  config.x.status.username = ENV["STATUS_USERNAME"].presence
  config.x.status.password = ENV["STATUS_PASSWORD"].presence
end
