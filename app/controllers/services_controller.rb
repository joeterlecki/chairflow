class ServicesController < ApplicationController
  def index
    @services = Service.order(:id)
  end

  def edit
    @service = Service.find(params[:id])
  end

  def update
    @service = Service.find(params[:id])
    if @service.update(params.expect(service: [ :default_duration ]))
      redirect_to services_path, notice: "Service default updated. Existing appointments keep their duration.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end
end
