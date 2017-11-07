# == Schema Information
#
# Table name: resources
#
#  id          :integer          not null, primary key
#  kind        :string
#  bookable    :boolean
#  title       :string
#  body        :text
#  owner_id    :integer
#  owner_type  :string
#  calender_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class ResourcesController < MainEpicentersController
  before_action :set_epicenter
  before_action :require_caretaker

  def index
    @resources = @epicenter.resources
  end

  def show
  end


  def new
    @resource = @epicenter.resources.build
    @resource.build_calendar
  end

  def edit
  end

  def create
    @resource = @epicenter.resources.build(resource_params)

    if @resource.save
      redirect_to epicenter_resources_path(@epicenter), notice: 'Ressourcen blev oprettet'
    else
      render action: 'new'
    end
  end

  def update
    if @page.update(resource_params)
      redirect_to epicenter_resources_path(@epicenter), notice: 'Ressourcen blev opdateret.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @resource.destroy
    redirect_to epicenter_resources_path(@epicenter)
  end


  private

  def set_epicenter
  	@epicenter = Epicenter.find_by_slug(params[:epicenter_id])
    @pages = @epicenter.epipages
  end


  def resource_params
  	params.require(:resource).permit(:menu_title, :title, :slug, :kind, :body, calendar_attributes: [
     :day_start, :day_end, :module_length, :flexible, :title] )
  end

end

