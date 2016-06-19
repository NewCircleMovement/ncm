class FruittypesController < ApplicationController
  before_action :set_epicenter
  before_action :set_membership, only: [:edit, :update, :destroy]

  def index
  end

  def new
    @fruittype = Fruittype.new
  end

  def edit
  end


  def create
    @fruittype = Fruittype.new(membership_params)
    @fruittype.epicenter_id = @epicenter.id
    if @fruittype.save
      redirect_to epicenter_fruittypes_path(@epicenter), notice: 'Frugttypen blev oprettet'
    else
      render action: 'new'
    end

  end

  def update
    if @fruittype.update(membership_params)
      redirect_to epicenter_fruittypes_path(@epicenter), notice: 'Frugttypen blev opdateret.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @fruittype.destroy
    redirect_to epicenter_fruittypes_path(@epicenter)
  end


  private
    def set_epicenter
      @epicenter = Epicenter.find(params[:epicenter_id])
    end

    def set_membership
      @fruittype = Fruittype.find(params[:id])
    end

    def fruittype_params
      params.require(:fruittype).permit(:name, :monthly_decay, :epicenter_id)
    end

end
