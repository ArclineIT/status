class Admin::DashboardController < Admin::BaseController
  def show
    @components = Component.ordered
    @component = Component.new
    @incidents = Incident.recent.limit(20)
    @maintenances = Maintenance.order(starts_at: :desc).limit(20)
  end
end
