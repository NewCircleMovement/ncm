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
#

class User < ActiveRecord::Base
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

  # returns a user's fruit expensives per month in a given epicenter
  def monthly_engagement( epicenter )
    engagement = 0
    self.memberships.each do |membership|
      if membership.monthly_fee_fruittype.id == epicenter.fruittype.id
        puts membership.name
        puts membership.monthly_fee
        engagement += membership.monthly_fee
      end
    end
    return engagement
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


end
