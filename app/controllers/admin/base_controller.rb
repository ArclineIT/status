class Admin::BaseController < ApplicationController
  before_action :require_login

  private
    # HTTP basic auth from STATUS_USERNAME and STATUS_PASSWORD. With neither set
    # the admin area is open, which is only allowed outside production.
    def require_login
      settings = Rails.configuration.x.status

      if settings.username && settings.password
        authenticate_or_request_with_http_basic("arcline-status") do |username, password|
          ActiveSupport::SecurityUtils.secure_compare(username, settings.username) &
            ActiveSupport::SecurityUtils.secure_compare(password, settings.password)
        end
      elsif Rails.env.production?
        render plain: "Set STATUS_USERNAME and STATUS_PASSWORD to use the admin area.", status: :service_unavailable
      end
    end
end
