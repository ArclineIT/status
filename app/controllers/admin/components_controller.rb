class Admin::ComponentsController < Admin::BaseController
  def create
    component = Component.new(params.expect(component: %i[ name status ]))
    component.position = Component.maximum(:position).to_i + 1

    if component.save
      redirect_to admin_root_path, notice: "#{component.name} added."
    else
      redirect_to admin_root_path, alert: component.errors.full_messages.to_sentence
    end
  end

  def update
    component = Component.find(params[:id])

    if component.update(params.expect(component: %i[ name status position ]))
      redirect_to admin_root_path, notice: "#{component.name} is now #{component.status_label.downcase}."
    else
      redirect_to admin_root_path, alert: component.errors.full_messages.to_sentence
    end
  end

  def destroy
    component = Component.find(params[:id]).destroy
    redirect_to admin_root_path, notice: "#{component.name} removed.", status: :see_other
  end
end
