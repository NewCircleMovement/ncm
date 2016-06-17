class MembershipsController < ApplicationController
  before_action :set_epicenter
  before_action :set_membership, only: [:edit, :update, :destroy]

  def index
  end

  def new
    @membership = Membership.new
  end

  def edit
  end


  def create
    @membership = Membership.new(membership_params)
    @membership.epicenter_id = @epicenter.id
    if @membership.save
      redirect_to epicenter_memberships_path(@epicenter), notice: 'Medlemskabet blev oprettet'
    else
      render action: 'new'
    end

  end

  def update
    if @membership.update(membership_params)
      redirect_to epicenter_memberships_path(@epicenter), notice: 'Medlemskabet blev opdateret.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @membership.destroy
    redirect_to epicenter_memberships_path(@epicenter)
  end


  private
    def set_epicenter
      @epicenter = Epicenter.find(params[:epicenter_id])
    end

    def set_membership
      @membership = Membership.find(params[:id])
    end

    def membership_params
      params.require(:membership).permit(:name, :monthly_fee, :epicenter_id)
    end

end
