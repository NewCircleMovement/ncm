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

# niveau "kan måske slettes... kan evt. sættes af location"

class Epicenter < ActiveRecord::Base
  before_destroy :test_if_ncm

  belongs_to :mother, :class_name => "Epicenter", :foreign_key => 'mother_id'
  has_many :children, :class_name => "Epicenter", :foreign_key => 'mother_id', :dependent => :destroy

  has_many :users, :through => :tshirts
  has_many :tshirts, :dependent => :destroy
  has_many :memberships

  has_one :fruittype
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
        caretaker_access = child.location.access_points.build(:name => "caretaker")
        member_access = child.location.access_points.build(:name => "member")
        caretaker_access.save
        member_access.save

        [caretaker_access, member_access].each do |access|
          child.make_tshirt( current_user, access )
        end

        # temporary solution for fruit types and meberships
        # fruit = Fruittype.create(:name => epicenter_params[:fruittype_name], 
        #                          :monthly_decay => epicenter_params[:fruittype_decay],
        #                          :epicenter_id => child.id)
        # fruit.save

        # membership = Membership.create(:name => 'basis', 
        #                                :monthly_fruits => epicenter_params[:membership_monthly_fruits],
        #                                :epicenter_id => child.id)
        # membership.save

      end

    end

    return child
  end


  def members
    users.uniq
  end

  def make_tshirt(user, access_point)
    tshirt = Tshirt.new(:epicenter_id => self.id, :user_id => user.id, :access_point_id => access_point.id)
    tshirt.save
  end

  def give_fruittree(user)
    puts "Giving fruittree to", user.
    fruittree = Fruittree.find_or_create_by(
      :owner_id => user.id, 
      :owner_type => 'User', 
      :fruittype_id => self.fruittype.id,
      :fruits_per_month => self.monthly_fruits_basis
    )
  end

  def access_point(role)
    return self.location.access_points.find_by( :name => role )
  end

  def users_with_tshirt(role)
    tshirts = self.tshirts.joins(:access_point).where('access_points.name' => [role.downcase])
    user_ids = tshirts.map(&:user_id)
    return User.where(:id => user_ids)
  end

  def tshirts_belonging_to_user(user)
    return self.tshirts.where( user_id: user.id )
  end

  def cancel_membership(user)
    tshirts_belonging_to_user( user ).each do |tshirt|
      tshirt.destroy
    end
  end

  def user_is_member(user)
    result = false
    members = users_with_tshirt('member')
    if members.find_by( id: user.id ).present?
      result = true
    end
    return result
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

  # temporary virtual attributs 
  def fruittype_name
    @fruittype_name
  end
  def fruittype_name=(value)
    @fruittype_name = value
  end

  def fruittype_decay
    @fruittype_decay
  end
  def fruittype_decay=(value)
    @fruittype_decay = value
  end

  def membership_monthly_fruits
    @membership_monthly_fruits
  end
  def membership_monthly_fruits=(value)
    @membership_monthly_fruits = value
  end

end