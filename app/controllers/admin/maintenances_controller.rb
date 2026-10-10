class Admin::MaintenancesController < Admin::BaseController
  def new
    @maintenance = Maintenance.new
  end

  def create
    @maintenance = Maintenance.new(params.expect(maintenance: %i[ title body starts_at ends_at ]))

    if @maintenance.save
      redirect_to admin_root_path, notice: "Maintenance scheduled."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    Maintenance.find(params[:id]).destroy
    redirect_to admin_root_path, notice: "Maintenance removed.", status: :see_other
  end
end
