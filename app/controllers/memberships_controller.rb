# == Schema Information
#
# Table name: memberships
#
#  id           :integer          not null, primary key
#  name         :string
#  monthly_fee  :integer
#  epicenter_id :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  engagement   :integer          default(2)
#  payment_id   :string
#  monthly_gain :integer
#  profile      :text
#

class MembershipsController < MainEpicentersController
  before_action :set_epicenter
  before_action :set_membership, only: [:edit, :update, :destroy]
  before_action :require_caretaker, only: [:edit, :index]
  

  def index
    @sow = params['sow']
    @memberships = @epicenter.memberships.order(:monthly_fee)
    @hard_currency = (@epicenter == @mother)
  end

  def new
    @sow = params['sow']
    @membership = @epicenter.memberships.build
    puts "/// new membership"
    puts @membership
  end

  def edit
    @sow = params['sow']
  end

  def create
    @sow = params[:sow]
    @membership = @epicenter.memberships.build(membership_params)
    if @membership.save
      if params[:sow]
        redirect_to epicenter_edit_meeting_time_path(@epicenter, :sow => true)
      else
        redirect_to epicenter_memberships_path(@epicenter), notice: 'Medlemskabet blev oprettet'
      end
    else
      render action: 'new'
    end
  end
  

  def update
    @sow = params[:sow]
    if @membership.update(membership_params)
      if params[:sow]
        redirect_to epicenter_edit_meeting_time_path(@epicenter, :sow => true)
      else
        redirect_to epicenter_memberships_path(@epicenter), notice: 'Medlemskabet blev opdateret.'
      end
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
      @epicenter = Epicenter.find_by_slug(params[:epicenter_id])
      @pages = @epicenter.epipages
    end

    def set_membership
      @membership = Membership.find(params[:id])
    end

    def membership_params
      params.require(:membership).permit(:name, :profile, :monthly_fee, :monthly_gain, :epicenter_id, :payment_id)
    end

end
