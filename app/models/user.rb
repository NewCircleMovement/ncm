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

  after_create :create_fruittree_and_basket

  has_many :epicenters, :through => :tshirts
  has_many :tshirts, :dependent => :destroy

  has_many :membershipcards
  has_many :memberships, :through => :membershipcards

  has_many :fruittrees, as: :owner, :dependent => :destroy
  has_one :fruitbasket, as: :owner, :dependent => :destroy

  
  # when user creates account he/she will get a NCM lemon tree
  def create_fruittree_and_basket
    ncm = Epicenter.grand_mother
    ncm.make_tshirt( self, ncm.access_point('member') )
    ncm.give_fruittree( self )
    Fruitbasket.create(:owner_id => self.id, :owner_type => 'User')
  end

end
