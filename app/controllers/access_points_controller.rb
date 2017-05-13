# == Schema Information
#
# Table name: access_points
#
#  id          :integer          not null, primary key
#  location_id :integer
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class AccessPointsController < ApplicationController
  before_action :set_epicenter
  before_action :set_access, only: [:edit, :update, :destroy]

  def index
  end

  def new
    @access = AccessPoint.new
  end

  def edit
  end


  def create
    @access = AccessPoint.new(access_point_params)
    @access.location_id = @location.id
    if @access.save
      redirect_to epicenter_access_points_path(@epicenter), notice: 'Rollen blev oprettet'
    else
      render action: 'new'
    end

  end

  def update
    if @access.update(access_point_params)
      redirect_to epicenter_access_points_path(@epicenter), notice: 'Rollen blev opdateret.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @access.destroy
    redirect_to epicenter_access_points_path(@epicenter)
  end


  private
    def set_epicenter
      @epicenter = Epicenter.find_by_slug(params[:epicenter_id])
      @location = @epicenter.location
    end

    def set_access
      @access = AccessPoint.find(params[:id])
    end

    def access_point_params
      params.require(:access_point).permit(:name, :menu_item, :menu_title, :profile, :monthly_decay, :location_id)
    end

end
