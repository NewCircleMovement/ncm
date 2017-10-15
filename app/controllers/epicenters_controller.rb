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
#  slug                 :string
#  image                :string
#  tagline              :string
#  size                 :string
#  meeting_day          :string
#  meeting_time         :time
#  meeting_week         :string
#  meeting_address      :string
#  meeting_active       :boolean          default(FALSE)
#

class EpicentersController < ApplicationController
  # include SharedMethods
  before_action :authenticate_user!, only: [:new, :edit, :update]
  before_action :set_epicenter, only: [:edit, :update, :show, :join_epicenter, :leave_epicenter]

  before_filter :get_mother
  before_filter :has_edit_permission, only: [:edit, :update]


  # validates :slug, uniqueness: true

  def index
    if current_user and not current_user.get_membership(@mother)
      @epicenters = Epicenter.all
    else
      @epicenters = @mother.children.where.not(id: @mother_id)
    end
    
  end

  def show
    @left_info = @epicenter.information.where(:position => INFORMATION_POSITIONS[:left] ).first
    @right_info = @epicenter.information.where(:position => INFORMATION_POSITIONS[:right] ).first
    @logs = @epicenter.event_log
  end

  def new
    @epicenter = Epicenter.new
    set_minimum_requirements(@epicenter)
  end 

  def edit
    set_minimum_requirements(@epicenter)
  end

  def create
    @mother = Epicenter.find(@mother_id)

    @epicenter = @mother.make_child( epicenter_params, current_user )

    if @epicenter.save
      redirect_to edit_epicenter_path(@epicenter)
    else
      render action: 'new'
    end
  end


  def update
    if @epicenter.update(epicenter_params)

      # if sowing the seed, redirect to Trin 3 (Memberships) after saving
      if params[:sow]
        redirect_to epicenter_memberships_path(@epicenter, :sow => true)
      elsif params[:review]
        redirect_to epicenter_review_plant_path(@epicenter)
      elsif params[:confirm]
        redirect to
      else
        redirect_to edit_epicenter_path(@epicenter), notice: 'Epicenteret er blevet opdateret.'
      end
    else
      if params[:sow]
        redirect_to epicenter_edit_engagement_path(@epicenter, :sow => true), notive: ''
      else
        render action: 'edit'
      end
    end
  end

  # def join_epicenter
  #   if @epicenter.has_member?(current_user)
  #     redirect_to epicenters_path, notice: 'Du er allerede medlem'
  #   else
  #     member_access = @epicenter.get_access_point('member')
  #     member_tshirt = @epicenter.make_tshirt( current_user, member_access )
  #     redirect_to epicenters_path, notice: 'Yes! Du er medlem nu.'
  #   end
  # end

  def leave_epicenter
    if @epicenter.has_member?( current_user )

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

  def edit_members
    @epicenter = Epicenter.find_by_slug(params[:epicenter_id])
  end

  def edit_engagement
    @epicenter = Epicenter.find_by_slug(params[:epicenter_id])
  end

  def edit_meeting_time
    @epicenter = Epicenter.find_by_slug(params[:epicenter_id])
  end

  def review_plant
    @epicenter = Epicenter.find_by_slug(params[:epicenter_id])
    @membership = @epicenter.memberships.first
  end

  def confirm_plant
    @caretaker = User.find(params[:caretaker_id])
    @epicenter = Epicenter.find_by_slug(params[:epicenter_id])
    @epicenter.set_status(SPROUT, @caretaker)
    message = "Tillykke, #{@epicenter.name} er nu en #{SPROUT}. Meld dig ind så andre også kan modtage medlemmer"
    redirect_to new_epicenter_subscription_path(@epicenter), :notice => message
  end

  def members
    @epicenter = Epicenter.find_by_slug(params[:epicenter_id])
    @pages = @epicenter.epipages
    
    if tshirt_name = params['tshirt']
      if params['title']
        @title = params['title']
      else
        @title = tshirt_name
      end
    else
      tshirt_name = 'member'
      @title = 'Medlemmer'
    end
    @members = @epicenter.users_with_tshirt( tshirt_name ).where.not(:image => nil).order(:name)
    @nophoto = @epicenter.users_with_tshirt( tshirt_name ).where(:image => nil).order(:name)  
    
  end

  def tshirts
    @tshirt = Tshirt.new
    @temptshirt = TempTshirt.new
    @epicenter = Epicenter.find_by_slug(params[:epicenter_id])
  end

  def give_tshirt
    @epicenter = Epicenter.find_by_slug(params[:epicenter_id])
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

  def set_minimum_requirements(epicenter)
    if epicenter.depth_fruits
      @depth_fruits = @epicenter.depth_fruits 
    else 
      @depth_fruits = MIN_DEPTH_FRUITS
    end

    if epicenter.depth_members
      @depth_members = @epicenter.depth_members
    else
      @depth_members = MIN_DEPTH_MEMBERS
    end
  end


  private
    
    def has_edit_permission
      if current_user
        puts "-------------------------"
        puts "Check permission for user", current_user.email
        puts "And epicenter", @epicenter.name
        unless @epicenter.has_caretaker?(current_user)
          redirect_to :back, notice: "Du er ikke medlem af new circle movement"
        end
      end
    end


    # Use callbacks to share common setup or constraints between actions.
    def set_epicenter
      @epicenter = Epicenter.find_by_slug(params[:id])
      @pages = @epicenter.epipages
    end


    # Never trust parameters from the scary internet, only allow the white list through.
    def epicenter_params
      params.require(:epicenter).permit(:name, :description, :image, :tagline, :max_members, :video_url, :growing, :manifested,
                                        :ongoing, :size, :depth_fruits, :depth_members, :slug, :monthly_fruits_basis,
                                        :meeting_day, :meeting_time, :meeting_week, :meeting_address, :meeting_active,
                                        fruittype_attributes: [:name, :monthly_decay],
                                        memberships_attributes: [:name, :monthly_fee, :engagement] )
    end

end
