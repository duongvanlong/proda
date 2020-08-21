class DevicesController < ApplicationController
  def new
    @device = Device.new
  end

  def create
    @device = Device.new
    @device.organization_id = current_user.organization_id
    @device.user_id = current_user.id
    @device.name = device_name
    if @device.valid?
      @device.save!
      redirect_to device_path(@device)
    else
      render action: "new"
    end
  end

  def show
    @device = Device.find params[:id]
  end

  private
  def device_name
    params[:device][:name]
  end
end
