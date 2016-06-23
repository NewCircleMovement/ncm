# == Schema Information
#
# Table name: tshirts
#
#  id              :integer          not null, primary key
#  epicenter_id    :integer
#  user_id         :integer
#  access_point_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  membership_id   :integer
#

class Tshirt < ActiveRecord::Base
	""" 
		Tshirts is what the user wears when entering an epi-center
		Its represents both the user's role and membership
	"""

	belongs_to :user
	belongs_to :ecicenter
	belongs_to :access_point
	belongs_to :membership # why this?

	def name
		self.access_point.name
	end

end


class TempTshirt
	extend ActiveModel::Naming
  include ActiveModel::Conversion

	attr_accessor :email
	attr_accessor :epicenter
	attr_accessor :access_point

  def persisted?
    false
  end

end