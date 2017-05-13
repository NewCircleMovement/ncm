# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  name                   :string
#  first_name             :string
#  last_name              :string
#  image                  :string
#  profile_text           :text
#

class User < ActiveRecord::Base
  mount_uploader :image, ImageUploaderUser

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # all users must have a fruitbasket
  after_create :create_fruitbasket

  has_many :epicenters, :through => :tshirts
  has_many :tshirts, :dependent => :destroy

  # a user has epicenter memberships through membershipcards
  # cards will be destroyed on deletion, but not memberships
  has_many :memberships, :through => :membershipcards
  has_many :membershipcards, :dependent => :destroy

  # membership_changes are used to store membership change requests
  has_many :membership_changes, :dependent => :destroy
  
  has_many :fruittrees, as: :owner, :dependent => :destroy
  has_one :fruitbasket, as: :owner, :dependent => :destroy

  # when user creates account he/she will a fruitbasket
  def create_fruitbasket
    Fruitbasket.create(:owner_id => self.id, :owner_type => 'User')
  end

  def membership_for(epicenter)
    return self.memberships.find_by(epicenter_id: epicenter.id)
  end

  def get_membershipcard(epicenter)
    return Membershipcard.find_by(user_id: self.id, epicenter_id: epicenter.id)
  end

  def get_tshirts(epicenter)
    return Tshirt.where(user_id: self.id, epicenter_id: epicenter.id).includes(:access_point).order("access_points.name desc")
  end

  def has_member_tshirt?(epicenter)
    self.tshirts.pluck(:epicenter_id).include? epicenter.id
  end

  def requested_change(epicenter)
    return MembershipChange.find_by(user_id: self.id, epicenter_id: epicenter.id)
  end


  def update_card(customer, token)
    new_card = customer.sources.create(card: token)
    customer.default_source = new_card.id
    customer.save
  rescue Stripe::InvalidRequestError => e
    logger.error "Error while updating card info: #{e.message}"
    errors.add :base, "#{e.message}"
    false
  end


  # returns a user's fruit expences per month in a given epicenter
  def monthly_engagement( epicenter )
    membership = get_membership(epicenter)
    return membership.monthly_fee
  end


  # returns a user's fruit harvest per month in a given epicenter
  def monthly_harvest( epicenter )
    membership = get_membership(epicenter)
    return membership.monthly_gain
  end


  # returns a users membership for all epicenters of same mother 
  # (optional exception of specific epicenter)
  def all_memberships( epicenter, exception=nil )
    if exception
      exception_id = exception.id
    else
      exception_id = -1
    end
    return self.memberships.where(:id => epicenter.id).where.not(:id => exception_id)
  end


  def sum_of_all_engagements(epicenter, exception=nil)
    result = 0
    memberships = self.all_memberships(epicenter, exception)
    memberships.each do |membership|
      result += membership.monthly_fee
    end
    return result
  end

  # returns a user's membership for a specific epicenter
  def get_membership(epicenter)
    return self.memberships.where(:epicenter_id => epicenter.id).first
  end


  def show_engagement_to(epicenter)
    engagement = self.monthly_engagement(epicenter)
    fruittype = epicenter.mother_fruit
    self.fruitbasket.give_fruit_to(epicenter.fruitbasket, fruittype, engagement)
  end


  def get_member(membershipcard)
    if membershipcard && membershipcard.payment_id.present?
      # NCM members
      if membershipcard.membership.present? && membershipcard.membership.epicenter == Epicenter.grand_mother
        begin
          return Stripe::Customer.retrieve( membershipcard.payment_id )
        rescue => error
          return nil
        end
      # all other epicenter members
      else
        puts "How to deal with memberinfo for these types?"
      end
    else
      return nil
    end
  end

  def fruits(epicenter)
    if epicenter.fruittype.present?
      fruitbag = self.fruitbasket.fruitbags.find_by(fruittype_id: epicenter.fruittype.id)
      if fruitbag
        return fruitbag.amount
      else
        return nil
      end
    else
      return nil
    end
  end

  def harvest_fruittree( epicenter )
    membership = self.get_membership( epicenter )

    fruittype = epicenter.fruittype
    
    fruittree = self.fruittrees.where(:fruittype_id => fruittype.id).first
    fruitbag = self.fruitbasket.fruitbags.where(:fruittype_id => fruittype.id).first

    # make sure that users cannot harvest more than their membership gain
    harvest = fruittree.fruits_per_month
    if harvest > membership.monthly_gain
      harvest = membership.monthly_gain
    end

    fruitbag.amount += harvest
    fruittree.yield += harvest
    
    fruitbag.save
    fruittree.save

    return fruittree.fruits_per_month
  end


end
