class EpicentersController < ApplicationController

  before_action :set_epicenter, only: [:edit, :update, :show]

  def index
    @epicenters = Epicenter.all
  end

  def show
  end

  def new
    @epicenter = Epicenter.new
  end 

  def create
    @epicenter = Epicenter.new(epicenter_params)

    if @epicenter.save
      redirect_to epicenters_path
    else
      render action: 'new'
    end
  end

  def update
    if @epicenter.update(epicenter_params)
      redirect_to epicenters_path, notice: 'Epicenteret er blevet opdateret.'
    else
      render action: 'edit'
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_epicenter
      @epicenter = Epicenter.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def epicenter_params
      params.require(:epicenter).permit(:name, :description, :max_members, :video_url, :growing, :manifested)
    end

end
