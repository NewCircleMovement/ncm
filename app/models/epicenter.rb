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
#  ongoing              :boolean          default(TRUE)
#  api_token            :string
#  members_count        :integer
#  fruits_count         :integer
#  show_postits         :boolean          default(FALSE)
#

# niveau "kan måske slettes... kan evt. sættes af location"
require 'blueprint'

class Epicenter < Blueprint
  include PgSearch
  # pg_search_scope :search_for, against: [:name, :description], using: { tsearch: { any_word: true } }
  pg_search_scope :search_for, against: [:name, :tagline, :description], using: { tsearch: { any_word: true } }
  # multisearchable :against => [:title, :author], using: { tsearch: { any_word: true } }

  before_create :generate_api_token
  before_destroy :test_if_ncm
  before_save :update_counters

  validates :name, :tagline, :depth_members, :depth_fruits, :presence => true
  # validates :size, :presence => true
  validates :depth_members,
    numericality: { only_integer: true, greater_than: 99 }
  validates :depth_fruits, 
    numericality: { only_integer: true, greater_than: 29999 }
  validates :monthly_fruits_basis,
    numericality: { only_integer: true, greater_than: -1, less_than: 100000 }

  belongs_to :mother, :class_name => "Epicenter", :foreign_key => 'mother_id'
  has_many :children, :class_name => "Epicenter", :foreign_key => 'mother_id', :dependent => :destroy

  has_many :users, :through => :tshirts
  has_many :tshirts, :dependent => :destroy
  has_many :epipages, :dependent => :destroy
  has_many :memberships, :dependent => :destroy
  has_many :admissions, :dependent => :destroy
  has_many :information, as: :owner, :dependent => :destroy
  
  has_many :resources, as: :owner, :dependent => :destroy
  has_many :postits

  has_one :fruittype, :dependent => :destroy
  has_one :fruitbasket, as: :owner, :dependent => :destroy
  has_many :event_logs, as: :owner, :dependent => :destroy ##42

  belongs_to :location # kan fx. være en "gateway (density 2)"

  accepts_nested_attributes_for :memberships
  accepts_nested_attributes_for :fruittype

  mount_uploader :image, ImageUploaderEpicenter

  def self.grand_mother
    return Epicenter.where(:name => "New Circle Movement").first
  end

  def all_children(children_array = [])
    children_array += self.children
    children.each do |child|
      if child != Epicenter.grand_mother
        return child.all_children(children_array)
      end
    end
    return children_array
  end

  # once a month members will harvest fruits from their epicenter trees
  # the epicenter will provide any fruit in excess of what can be harvested according to memberships
  # only MOTHER should call this function
  def harvest_time
    # only harvst for epicenters with status "tree"
    if self.status == TREE  
      self.members.each do |member|
        self.harvest_time_for(member)
      end
      
      self.children.each do |child|
        unless child == Epicenter.grand_mother
          child.harvest_time
        end
      end

    end
  end

  def harvest_time_for(user)
    """ give user fruits according to membership, 
        and take residual amount from epicenter fruitbag """
    membership = self.get_membership_for(user)
    print "#{self.name} > User harvest"
    print " > should get = #{membership.monthly_gain}"

    user_harvest = user.harvest_fruittree(self)    
    missing_fruit = [0, membership.monthly_gain - user_harvest].max

    print " > from tree = #{user_harvest}"
    print " > missing_fruit = #{missing_fruit}"

    self.fruitbasket.give_fruit_to( user.fruitbasket, self.fruittype, missing_fruit )
  end

  # once a month members will show engagement to their epicenters
  # only MOTHER should call this function
  def engagement_time
    self.members.each do |member|
      member.show_engagement_to(self)
    end

    self.children.each do |child|
      unless child == Epicenter.grand_mother
        child.engagement_time
      end
    end
  end


  # returns the STATUS of the epicenter (tree, plant, sprout, seed)
  def set_status(new_status, caretaker=nil)
    details = { from: self.status, to: new_status }

    case new_status
    when SPROUT
      self.manifested = false
      self.growing = true
    when PLANT
      self.manifested = true
      self.growing = false
    when TREE
      self.manifested = true
      self.growing = true
    end
    
    if caretaker
      actor = caretaker
    else
      actor = self
    end
    
    EventLog.entry(actor, self, EPICENTER_STATUS_CHANGE, details)
    self.save
  end


  def status
    if self.manifested && self.growing
      status = TREE
    elsif self.manifested && !self.growing
      status = PLANT
    elsif !self.manifested && self.growing
      status = SPROUT
    else
      status = SEED
    end
    return status
  end

  def status_text
    case self.status
    when SEED
      return "Seed"
    when SPROUT
      return "Sprout"
    when PLANT
      return "Plant"
    when TREE
      return "Tree"
    end
  end

  def get_max_members
    case self.size
    when TRIBE, GATHERING
      return 1000
    when MOVEMENT
      return 10000
    end
  end

  def check_seed
    
  end

  def has_current_admissions?
    return self.admissions.map(&:start_t).any? { |t| t >= Time.now }
  end


  def progress_members
    progress = [self.members.count.to_f / self.depth_members, 1].min * 100
    return progress
  end

  def progress_fruits
    collected_fruits = self.fruitbasket.fruit_amount( self.mother_fruit ) 
    progress = [collected_fruits.to_f / self.depth_fruits, 1].min * 100
    return progress
  end
  

  def progress
    progress_members = [self.members.count.to_f / self.depth_members, 1].min

    collected_fruits = self.fruitbasket.fruit_amount( self.mother_fruit )
    progress_fruits = [collected_fruits.to_f / self.depth_fruits, 1].min

    progress = ((progress_members + progress_fruits) / 2 * 100).to_i
    return progress
  end
  
  # create new epicenter
  def make_child(epicenter_params, current_user)
    puts "---------------------------------------------------"
    puts "MAKE CHILD"
    # first create and save a location for the epicenter
    location_for_child = Location.new(:name => epicenter_params[:name], :density => 2)

    if location_for_child.save
      child = Epicenter.new(epicenter_params)
      child.mother_id = self.id
      child.location = location_for_child
      child.slug = child.to_slug

      ##42 child depth members and fruits must be variable on mother epicenter
      case child.size
      when TRIBE, GATHERING
        child.depth_members = MIN_DEPTH_MEMBERS_TRIBE
        child.depth_fruits = MIN_DEPTH_FRUITS_TRIBE
      when MOVEMENT
        child.depth_members = MIN_DEPTH_MEMBERS_MOVEMENT
        child.depth_fruits = MIN_DEPTH_FRUITS_MOVEMENT
      else
        child.depth_members = 100
        child.depth_fruits = 30000
      end
      
      if child.save
        puts ">> Epicenter", child.name, "has been saved"
        fruitbasket = Fruitbasket.create(:owner_id => child.id, :owner_type => 'Epicenter')
        Fruitbag.create(:fruitbasket_id => fruitbasket.id, :amount => 0)

        # access points
        puts ">> Creating acess points"
        caretaker_access = child.location.access_points.build(:name => "caretaker")
        member_access = child.location.access_points.build(:name => "member")
        caretaker_access.save
        member_access.save
        puts "caretaker", caretaker_access
        puts "member", member_access

        child.make_tshirt( current_user, caretaker_access )
      else
        puts "----------------------------------------------"
        puts "CHILD NOT SAVED"
      end

    else 
      puts "---------------------------------"
      puts "LOCATION NOT SAVED"
    end

    return child
  end

  ##42 Should return all members with ONLY "member" tshirts
  # check how to select through association attribute
  def members
    access_point = self.get_access_point("member")
    if access_point
      users = self.users.joins(:tshirts).where(:tshirts => { :access_point_id => access_point.id })
      return users.uniq
    else
      return []
    end
  end


  # pays for new membership and ensures that the new members has:
  # 1. the required fruit to become member
  # 2. the required monthly engagement (new monthly fruit) to be able to pay in the future (next month)
  def validate_and_pay_new_membership(user, new_membership)
    result = false
    fruittype = self.mother_fruit
    puts ""
    print "VALIDATE payment"
    # check if user has enough fruits
    enough_fruit = (user.fruitbasket.fruit_amount( fruittype ) >= new_membership.monthly_fee )
    print "> Enough fruit now #{enough_fruit}"

    # handle existing memberships (if the user is changing memberships)
    already_paying = 0
    if self.has_member?(user)
      existing_membership = user.membership_for(self)
      already_paying = existing_membership.monthly_fee
    end

    # check if user has enough monhtly engagement (fruit income)
    # 1: the user receives a monthly harvest from NCM (Tinkuy's mother)
    # 2: harvest must be larger than user membership for Tinkuy/BASIS cost 100 "waterdrops" (monthly price)
    # 3: and harvest must be larger than the tinkuy monthly membership cost
    # 4: plus other monthly engagements (of the same mother)
    monthly_mother_harvest = self.mother.get_membership_for( user ).monthly_gain
    monthly_epicenter_price = new_membership.monthly_fee
    monthly_current_engagements = user.sum_of_all_engagements(self.mother.fruittype) - already_paying
    enough_engagement = ( monthly_mother_harvest >= monthly_epicenter_price + monthly_current_engagements )
      
    print " > Harvest = #{monthly_mother_harvest}"
    print " > Membership price = #{monthly_epicenter_price}"
    print " > Other prices = #{monthly_current_engagements}"
    print " > Enough engagement = #{enough_engagement}"

    # overfør frugt fra bruger til epicenter
    if enough_fruit && enough_engagement
      user.fruitbasket.give_fruit_to( self.fruitbasket, fruittype, new_membership.monthly_fee )
      result = true
    end
    return result

  end


  # every member has a membershipcard (which binds new members to a specific epicenter mebership)
  # the membershipcard also has the stripe_id (if NCM)
  def make_membershipcard(user, membership, stripe_customer=nil)
    membershipcard = Membershipcard.where(
      user_id: user.id, 
      epicenter_id: self.id, 
    ).first_or_create
    membershipcard.membership_id = membership.id
    if stripe_customer
      membershipcard.payment_id = stripe_customer.id
    end
    membershipcard.save
    return membershipcard
  end


  # makes a new member of an epicenter (member tshirt, fruittree and fruitbag)
  def make_member(user)
    member_access = self.get_access_point('member')
    self.make_tshirt( user, member_access )
    self.give_fruittree_to( user )
    self.give_fruitbag_to( user )
    self.save
  end


  # makes a new tshirt with specific access point, e.g. 'member' or 'caretaker'
  def make_tshirt(user, access_point)
    tshirt = Tshirt.where(
      :epicenter_id => self.id, 
      :user_id => user.id, 
      :access_point_id => access_point.id
    ).first_or_create
  end


  def give_fruittree_to(user)
    Fruittree.find_or_create_by(
      :owner_id => user.id, 
      :owner_type => 'User', 
      :fruittype_id => self.fruittype.id,
      :fruits_per_month => self.monthly_fruits_basis
    )
  end


  def give_fruitbag_to(user)
    Fruitbag.find_or_create_by(
      :fruitbasket_id => user.fruitbasket.id,
      :fruittype_id => self.fruittype.id
    )
  end


  # ensures that all members of an epicenter has the required fruittree
  def ensure_tree_for_all_members
    self.members.each do |member|
      fruittree = member.fruittrees.where(:fruittype_id => self.fruittype.id).first
      if not fruittree
        puts "Giving new fruittree to #{member.id}, #{member.email}"
        give_fruittree_to(member)
      end
    end
  end


  def delete_member(user)
    self.tshirts.where(user_id: user.id).delete_all
    
    fruittree = Fruittree.find_by(owner_id: user.id, owner_type: "User", fruittype_id: self.fruittype.id)
    if fruittree
      fruittree.destroy
    end
    
    log_details = { from: self.name }
    EventLog.entry(user, self, DELETE_MEMBERSHIP, log_details, LOG_COARSE)
  end

  def fruitbag
    return self.fruitbasket.fruitbags.first
  end


  def get_access_point(role)
    return self.location.access_points.find_by( :name => role )
  end


  def users_with_tshirt(role)
    tshirts = self.tshirts.joins(:access_point).where('access_points.name' => [role.downcase])
    user_ids = tshirts.map(&:user_id)
    return User.where(id: user_ids)
  end


  def tshirts_belonging_to_user(user)
    return self.tshirts.where( user_id: user.id )
  end


  def all_caretakers_are_members?
    result = false
    caretaker_ids = self.users_with_tshirt('caretaker').pluck(:id)
    member_ids = self.users_with_tshirt('member').pluck(:id)

    if caretaker_ids.count > 0 and (caretaker_ids - member_ids).empty?
      result = true
    end
      
    return result
  end


  def can_accept_members?
    return self.memberships.present? && 
      self.all_caretakers_are_members? && 
      self.fruittype.present? &&
      self.status != SEED
  end


  def cancel_membership(user)
    tshirts_belonging_to_user( user ).each do |tshirt|
      tshirt.destroy
    end
  end


  def has_member?(user)
    result = false
    members = users_with_tshirt('member')
    if members.find_by( id: user.id ).present?
      result = true
    end
    return result
  end


  def has_caretaker?(user)
    result = false
    caretakers = users_with_tshirt('caretaker')
    if caretakers.find_by( id: user.id ).present?
      result = true
    end
    return result
  end

  def get_membership_for(user)
    return user.memberships.find_by( epicenter_id: self.id )
  end


  ## does not work in "new" action because mother is not known
  def mother_fruit
    fruit = nil
    if self == Epicenter.grand_mother
      fruit = Fruittype.where(:name => "kroner").first
    else
      fruit = self.mother.fruittype
    end
    return fruit
  end


  def video
    if video_url.present?
      # <iframe width="560" height="315" src="https://www.youtube.com/embed/AiZFoxjQFcI" frameborder="0" allowfullscreen></iframe>
      if video_url.include? "youtube"
        id = video_url.split('watch?v=')[1]
        embed_link = "<iframe width='100%' src='https://www.youtube.com/embed/#{id}' frameborder='0' allowfullscreen></iframe>"
        return embed_link
      end

      if video_url.include? "youtu.be"
        id = video_url.split('youtu.be/')[1]
        embed_link = "<iframe width='100%' src='https://www.youtube.com/embed/#{id}' frameborder='0' allowfullscreen></iframe>"
        return embed_link
      end

    end
    return ""
  end

  def event_log(log_level=LOG_COARSE)
    return EventLog.where(
      :acts_on_type => Epicenter.name, 
      :acts_on_id => self.id,
      :log_level => log_level
    ).limit(10).order("created_at DESC")
  end


  def test_if_ncm
    if self.id == self.mother_id
      self.mother_id = nil
      self.save
      self.destroy
    end
  end

  def update_counters
    self.members_count = self.members.count
    if self.fruitbasket
      self.fruits_count = self.fruitbasket.fruit_amount( self.mother.fruittype ) || 0
    else
      self.fruits_count = 0
    end
  end


  def to_param
    self.slug
  end


  def to_slug
    #strip the string
    ret = self.name.strip.downcase

    #blow away apostrophes
    ret.gsub! /['`]/,""

    # @ --> at, and & --> and
    ret.gsub! /\s*@\s*/, " at "
    ret.gsub! /\s*&\s*/, " and "

    #replace all non alphanumeric, underscore or periods with underscore
    ret.gsub! /\s*[^A-Za-z0-9\.\-]\s*/, '_'  

    #convert double underscores to single
    ret.gsub! /_+/,"_"

    #strip off leading/trailing underscore
    ret.gsub! /\A[_\.]+|[_\.]+\z/,""

    ret
  end

  def new_api_token
    self.send(:generate_api_token)
  end

  
  private

  def generate_api_token
    begin
      self.api_token = SecureRandom.hex
    end while self.class.exists?(api_token: api_token)
  end

end
