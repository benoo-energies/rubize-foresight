class BatteriesController < ApplicationController
  include PowerSystemAttribution
  before_action :find_battery, only: [:edit, :update, :destroy]
  layout 'form', only: [:new, :create, :edit, :update]

  def new
    @battery = current_user.batteries.new
    authorize @battery
  end

  def create
    @battery = current_user.batteries.new(battery_params)
    authorize @battery
    if @battery.save
      flash[:notice] = "A new battery has been created."
      redirect_to power_components_path
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @battery.update(battery_params)
      update_solar_systems
      flash[:notice] = "The battery has been updated."
      redirect_to power_components_path
    else
      render :edit
    end
  end

  def destroy
    @battery.destroy
    @batteries = policy_scope(Battery).ordered
    # flash[:notice] = "The battery has been deleted"
  end

  private

  def update_solar_systems
    @battery.solar_systems.each do |solar_system|
      @project = solar_system.project
      @solar_system = solar_system
      attribute_power_system_to_solar_system
    end
  end

  def find_battery
    @battery = Battery.find(params[:id])
    authorize @battery
  end

  def battery_params
    params.require(:battery).permit(
      :technology,
      :dod,
      :voltage,
      :capacity,
      :efficiency,
      :price_min,
      :price_max,
      :currency,
      :lifetime
    )
  end
end
