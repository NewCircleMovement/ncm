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
#

# niveau "kan måske slettes... kan evt. sættes af location"

class Epicenter < ActiveRecord::Base
  before_destroy :test_if_ncm

  belongs_to :mother, :class_name => "Epicenter", :foreign_key => 'mother_id'
  has_many :children, :class_name => "Epicenter", :foreign_key => 'mother_id', :dependent => :destroy

  has_many :users, :through => :tshirts
  has_many :tshirts, :dependent => :destroy
  has_many :memberships

  has_one :fruittype
  has_one :fruitbasket, as: :owner, :dependent => :destroy
  belongs_to :location # kan fx. være en "gateway (density 2)"

  accepts_nested_attributes_for :memberships
  accepts_nested_attributes_for :fruittype


  def self.grand_mother
    return Epicenter.where(:name => "New Circle Movement").first
  end
  
  # create new epicenter
  def make_child(epicenter_params, current_user)
  
    # first create and save a location for the epicenter
    location_for_child = Location.new(:name => epicenter_params[:name], :density => 2)

    if location_for_child.save
      
      child = Epicenter.new(epicenter_params)
      child.mother_id = self.id
      child.location = location_for_child
      
      if child.save
        fruitbasket = Fruitbasket.create(:owner_id => self.id, :owner_type => 'Epicenter')
        Fruitbag.create(:fruitbasket_id => fruitbasket.id, :amount => 0)

        # access points
        caretaker_access = child.location.access_points.build(:name => "caretaker")
        member_access = child.location.access_points.build(:name => "member")
        caretaker_access.save
        member_access.save

        [caretaker_access, member_access].each do |access|
          child.make_tshirt( current_user, access )
        end
      end

    end

    return child
  end


  def members
    users.uniq
  end

  def make_member(user)
    member_access = self.access_point('member')
    self.make_tshirt( user, member_access )
    self.give_fruittree_to( user )
    self.give_fruitbag_to( user )
  end

  def make_tshirt(user, access_point)
    tshirt = Tshirt.new(:epicenter_id => self.id, :user_id => user.id, :access_point_id => access_point.id)
    tshirt.save
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

  def delete_member(user)
    self.tshirts.find_by(user_id: user.id).delete_all
    Fruittree.find_by(owner_id: user.id, owner_type: "User", fruittype_id: self.fruittype_id)
  end


  def give_fruit_to(user)
    """ give user fruits according to membership, and take residual amount from epicenter fruitbag """
    membership = self.get_membership_for(user)
    user.fruitbasket.receive_fruit( self.fruittype, membership.monthly_gain )
    residual_amount = [0, membership.monthly_gain - self.monthly_fruits_basis].max
    self.fruitbasket.give_fruit( self.fruittype, residual_amount )
  end


  def fruitbag
    return self.fruitbasket.fruitbags.first
  end

  def access_point(role)
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

  def can_accept_members?
    return self.fruittype.present? && self.memberships.present?
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

  def get_membership_for(user)
    return user.memberships.find_by( epicenter_id: self.id )
  end

  def video
    if video_url.present?
      # <iframe width="560" height="315" src="https://www.youtube.com/embed/AiZFoxjQFcI" frameborder="0" allowfullscreen></iframe>
      if video_url.include? "youtube"
        id = video_url.split('watch?v=')[1]
        embed_link = "<iframe width='560' height='315' src='https://www.youtube.com/embed/#{id}' frameborder='0' allowfullscreen></iframe>"
        return embed_link
      end
    end
    return ""
  end

  def test_if_ncm
    if self.id == self.mother_id
      self.mother_id = nil
      self.save
      self.destroy
    end
  end

  def to_param
    self.slug
  end
end
