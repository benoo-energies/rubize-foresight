class ProjectsController < ApplicationController
  include PowerSystemAttribution
  before_action :find_project, only: [:show, :edit, :update, :destroy, :appliances]
  before_action :find_project_by_token, only: [:load, :public]
  skip_before_action :authenticate_user!, only: [:public]
  layout 'form', only: [:new, :create, :edit, :update, :duplicate]

  def index
    @query = params[:query]
    page_number = params[:page]
    if @query.present?
      @projects = policy_scope(Project).search(@query).page(page_number)
    else
      @projects = policy_scope(Project).ordered.page(page_number)
    end
  end

  def show
    @project_appliances = @project.project_appliances.ordered
    @uses = @project.uses.ordered
  end

  def new
    @project = current_user.projects.new
    authorize @project
  end

  def duplicate
    @parent_project = Project.find(params[:id])
    @project = @parent_project.dup
    @project.name += " -- copy"
    @project.token = SecureRandom.hex
    authorize @project
    duplicate_project_appliances
    duplicate_solar_system
    @project.save
  end

  def create
    @project = current_user.projects.new(project_params)
    authorize @project
    if @project.save
      flash[:notice] = "#{@project.name} has been created"
      redirect_to project_path(@project)
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @project.update(project_params)
      update_solar_systems
      flash[:notice] = "#{@project.name} has been updated"
      redirect_to project_path(@project)
    else
      render :edit
    end
  end

  def destroy
    @project.destroy
    flash[:notice] = "#{@project.name} has been deleted"
    redirect_to projects_path
  end

  def appliances
    @query = params[:query]
    @page_number = params[:page]
    @use_pagination_id = params[:use].to_i
    appliance_subset = policy_scope(Appliance).where(current_type: @project.current_array)
    @appliances = @query.present? ? appliance_subset.search(@query) : appliance_subset.ordered
    use_ids = @appliances.select(:use_id).reorder("").distinct
    @uses = policy_scope(Use).where(id: use_ids).ordered
  end

  def public
    @project_appliances = @project.project_appliances.ordered
    @uses = @project.uses.ordered
    render layout: 'public'
  end

  def load
    respond_to do |format|
      filename = "#{Date.today}-rubize_foresight-#{@project.name.underscore.tr(" ","_")}.csv"
      startDate = params[:startDate].to_datetime
      endDate = params[:endDate].to_datetime
      timeFormat = params[:timeFormat]
      unit = params[:unit]
      loadBreakdown = params[:loadBreakdown]
      format.csv { send_data @project.load_to_csv(startDate, endDate, timeFormat, unit, loadBreakdown), filename: filename }
    end
  end

  private

  def find_project
    @project = Project.find(params[:id])
    authorize @project
  end

  def find_project_by_token
    @project = Project.find_by(token: params[:token])
    authorize @project
  end

  def update_solar_systems
    @solar_system = @project.solar_system
    attribute_power_system_to_solar_system
  end

  def duplicate_project_appliances
    @parent_project.project_appliances.each do |parent_project_appliance|
      @project.project_appliances.new(parent_project_appliance.dup.attributes)
    end
  end

  def duplicate_solar_system
    @project.solar_system = SolarSystem.new(@parent_project.solar_system.dup.attributes)
  end

  def project_params
    params.require(:project).permit(
      :name,
      :description,
      :country_code,
      :city,
      :day_time,
      :night_time,
      :current_ac,
      :current_dc,
      :voltage_min,
      :voltage_max,
      :frequency,
      :wiring,
      :grid_connection_charge,
      :grid_subscription_charge,
      :grid_consumption_charge,
      :diesel_price,
      :currency
    )
  end
end
