class Admin::IncidentsController < Admin::BaseController
  before_action :set_incident, only: %i[ show destroy post_update ]

  def new
    @incident = Incident.new(severity: "minor", status: "investigating")
  end

  def create
    form = params.expect(incident: %i[ title severity status body ])
    @incident = Incident.open!(title: form[:title], severity: form[:severity], status: form[:status].presence || "investigating", body: form[:body])
    redirect_to admin_incident_path(@incident), notice: "Incident opened."
  rescue ActiveRecord::RecordInvalid => e
    @incident = Incident.new(form.except(:body))
    flash.now[:alert] = e.record.errors.full_messages.to_sentence
    render :new, status: :unprocessable_entity
  end

  def show
  end

  def post_update
    form = params.expect(incident_update: %i[ status body ])
    @incident.post_update!(status: form[:status], body: form[:body])
    redirect_to admin_incident_path(@incident), notice: "Update posted."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to admin_incident_path(@incident), alert: e.record.errors.full_messages.to_sentence
  end

  def destroy
    @incident.destroy
    redirect_to admin_root_path, notice: "Incident deleted.", status: :see_other
  end

  private
    def set_incident
      @incident = Incident.find(params[:id])
    end
end
