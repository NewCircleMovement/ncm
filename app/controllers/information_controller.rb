# == Schema Information
#
# Table name: information
#
#  id         :integer          not null, primary key
#  owner_id   :integer
#  owner_type :string
#  string     :string
#  position   :integer
#  title      :string
#  body       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  kind       :string
#  slug       :string
#

class InformationController < ApplicationController
  before_action :set_epicenter
  before_action :set_info, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  def index
    @information = @epicenter.information.order(:position)
  end

  def show
    @menu_items = @epicenter.information.where(:kind => 'Menu')
  end

  def new
    puts "-------------------------------------"
    puts params
    @info = @epicenter.information.build
  end

  def edit
  end

  def create
    @info = @epicenter.information.build(information_params)
    @info.slug = @info.title.parameterize
    if @info.save
      redirect_to epicenter_information_index_path(@epicenter), notice: 'Informationen blev oprettet'
    else
      render action: 'new'
    end
  end

  def update

    if @info.update(information_params)
      redirect_to epicenter_information_index_path(@epicenter), notice: 'Informationen blev opdateret.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @info.destroy
    redirect_to epicenter_information_index_path(@epicenter)
  end



  private

    def set_epicenter
      @epicenter = Epicenter.find_by_slug(params[:epicenter_id])
      @pages = @epicenter.epipages
    end

    def set_info
      # @info = Information.find_by(slug: params[:id])
      @info = Information.find(params[:id])
    end

    def information_params
      params.require(:information).permit(:title, :body, :position, :kind)
    end

end
