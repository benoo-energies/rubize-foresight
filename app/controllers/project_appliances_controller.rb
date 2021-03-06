class ProjectAppliancesController < ApplicationController
  include PowerSystemAttribution
  before_action :find_project, only: [:new, :create]
  before_action :find_appliance, only: [:new, :refresh_load]
  before_action :find_project_appliance, only: [:edit, :update, :destroy]
  skip_after_action :verify_authorized, only: [:refresh_load]
  layout 'form', only: [:new, :create, :edit, :update]

  def new
    @project_appliance = @project.project_appliances.new
    @project_appliance.appliance = @appliance
    (0..23).each do |hour|
      @project_appliance["hourly_rate_#{hour}"] = @appliance["hourly_rate_#{hour}"]
    end
    authorize @project_appliance
  end

  def create
    @project_appliance = @project.project_appliances.new(project_appliance_params)
    @appliance = @project_appliance.appliance
    authorize @project_appliance
    if @project_appliance.save
      update_project_solar_systems
      flash[:notice] = "#{@appliance.name} has been added to the project #{@project.name}."
      redirect_to project_path(@project)
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @project_appliance.update(project_appliance_params)
      @project = @project_appliance.project
      update_project_solar_systems
      flash[:notice] = "#{@project_appliance.appliance.name} has been updated for the project."
      redirect_to project_path(@project)
    else
      render :edit
    end
  end

  def destroy
    @project_appliance.destroy
    @use = @project_appliance.appliance.use
    @project = @project_appliance.project
    update_project_solar_systems
    # flash[:notice] = "#{@project_appliance.appliance.name} has been removed from the project."
  end

  def refresh_load
  end

  private

  def find_project
    @project = Project.find(params[:project_id])
  end

  def find_appliance
    @appliance = Appliance.find(params[:appliance_id])
  end

  def find_project_appliance
    @project_appliance = ProjectAppliance.find(params[:id])
    authorize @project_appliance
  end

  def update_project_solar_systems
    @solar_system = @project.solar_system
    attribute_power_system_to_solar_system
  end

  def project_appliance_params
    params.require(:project_appliance).permit(
      :appliance_id,
      :quantity,
      :hourly_rate_0,
      :hourly_rate_1,
      :hourly_rate_2,
      :hourly_rate_3,
      :hourly_rate_4,
      :hourly_rate_5,
      :hourly_rate_6,
      :hourly_rate_7,
      :hourly_rate_8,
      :hourly_rate_9,
      :hourly_rate_10,
      :hourly_rate_11,
      :hourly_rate_12,
      :hourly_rate_13,
      :hourly_rate_14,
      :hourly_rate_15,
      :hourly_rate_16,
      :hourly_rate_17,
      :hourly_rate_18,
      :hourly_rate_19,
      :hourly_rate_20,
      :hourly_rate_21,
      :hourly_rate_22,
      :hourly_rate_23
    )
  end
end
