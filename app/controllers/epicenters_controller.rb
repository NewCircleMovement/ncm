# == Schema Information
#
# Table name: epicenters
#
#  id                   :integer          not null, primary key
#  name                 :string
#  description          :text
#  video_url            :string
#  max_members          :integer          default(1000)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  growing              :boolean          default(FALSE)
#  manifested           :boolean          default(FALSE)
#  location_id          :integer
#  niveau               :integer
#  depth_members        :integer
#  depth_fruits         :integer
#  mother_id            :integer
#  monthly_fruits_basis :integer          default(100)
#

class EpicentersController < ApplicationController
  before_filter :get_mother
  before_action :set_epicenter, only: [:edit, :update, :show, :join_epicenter, :leave_epicenter]

  def index
    @epicenters = @mother.children.where.not(id: @mother_id)
  end

  def show
  end

  def new
    @epicenter = Epicenter.new
  end 

  def create
    @mother = Epicenter.find(@mother_id)

    @epicenter = @mother.make_child( epicenter_params, current_user )
    if @epicenter
      redirect_to edit_epicenter_path(@epicenter)
    else
      render action: 'new'
    end
  end

  def update
    if @epicenter.update(epicenter_params)
      redirect_to edit_epicenter_path(@epicenter), notice: 'Epicenteret er blevet opdateret.'
    else
      render action: 'edit'
    end
  end

  def join_epicenter
    if @epicenter.user_is_member(current_user)
      redirect_to epicenters_path, notice: 'Du er allerede medlem'
    else
      member_access = @epicenter.access_point('member')
      member_tshirt = @epicenter.make_tshirt( current_user, member_access )
      redirect_to epicenters_path, notice: 'Yes! Du er medlem nu.'
    end
  end

  def leave_epicenter
    if @epicenter.user_is_member( current_user )

      caretakers = @epicenter.users_with_tshirt('caretaker').map(&:id).uniq
      if caretakers.include? current_user.id and caretakers.count > 1
        @epicenter.cancel_membership( current_user )
        flash[:notice] = "Du er nu udmeldt af #{@epicenter.name}"
        redirect_to epicenters_path
      else
        flash[:error] = "Du kan ikke meldes ud af #{@epicenter.name} som eneste caretaker"
        redirect_to epicenters_path
      end
    else
      redirect_to epicenters_path, notice: "Du er ikke medlem af #{@epicenter.name}"
    end
  end

  def members
    @epicenter = Epicenter.find(params[:epicenter_id])
  end

  def tshirts
    @tshirt = Tshirt.new
    @temptshirt = TempTshirt.new
    @epicenter = Epicenter.find(params[:epicenter_id])
  end

  def give_tshirt
    @epicenter = Epicenter.find(params[:epicenter_id])
    temp = params["temp_tshirt"]
    user = User.find_by_email( temp["email"] )
    access_point = AccessPoint.find_by_id( temp["access_point"] )

    Tshirt.find_or_create_by(:user_id => user.id, :access_point_id => access_point.id, :epicenter_id => @epicenter.id)
    puts params
    redirect_to edit_epicenter_path(@epicenter), notice: "Du gav en #{access_point.name} tshirt til #{user.name}"
  end

  def get_mother
    @mother = Epicenter.grand_mother
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_epicenter
      @epicenter = Epicenter.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def epicenter_params
      params.require(:epicenter).permit(:name, :description, :max_members, :video_url, :growing, :manifested,
                                        :depth_fruits, :depth_members,
                                        fruittype_attributes: [:name, :monthly_decay],
                                        memberships_attributes: [:name, :monthly_fee, :engagement] )
    end

end
