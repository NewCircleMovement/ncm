# == Schema Information
#
# Table name: epipages
#
#  id           :integer          not null, primary key
#  slug         :string
#  menu_title   :string
#  title        :string
#  body         :text
#  kind         :string           default("Info")
#  epicenter_id :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class EpipagesController < MainEpicentersController
  before_action :set_epicenter
  before_action :set_page, only: ['show', 'edit', 'update', 'destroy']
  before_action :require_caretaker, except: [:show]

  def index
    @pages = @epicenter.epipages
  end

  def show
    @pages = @epicenter.epipages
    @resources = @page.resources
    @resource = @resources.first
  end

  def new
    @page = @epicenter.epipages.build
  end

  def edit
  end

  def create
    @page = @epicenter.epipages.build(epipage_params)
    if @page.menu_title
      @page.slug = @page.menu_title.parameterize
    end

    if @page.save
      redirect_to epicenter_epipages_path(@epicenter), notice: 'Siden blev oprettet'
    else
      render action: 'new'
    end
  end

  def update
    if @page.update(epipage_params)
      redirect_to epicenter_epipages_path(@epicenter), notice: 'Siden blev opdateret.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @page.destroy
    redirect_to epicenter_epipages_path(@epicenter)
  end


  private

  def set_epicenter
  	@epicenter = Epicenter.find_by_slug(params[:epicenter_id])
    @pages = @epicenter.epipages.where.not(:id => nil)
  end

  def set_page
  	@page = Epipage.find_by(slug: params[:id])
  end

  def epipage_params
  	params.require(:epipage).permit(:menu_title, :title, :slug, :kind, :body)
  end

end

