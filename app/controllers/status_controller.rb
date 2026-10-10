# The public page. No login, and nothing here can change anything.
class StatusController < ApplicationController
  def show
    @page = StatusPage.new

    respond_to do |format|
      format.html
      format.json { render json: @page }
    end
  end

  def history
    @incidents = Incident.history.includes(:updates)
    @maintenances = Maintenance.past.limit(20)
  end

  def feed
    @incidents = Incident.recent.includes(:updates).limit(30)
    render formats: :xml
  end
end
