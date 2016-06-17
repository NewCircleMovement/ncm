# == Schema Information
#
# Table name: fruitbaskets
#
#  id         :integer          not null, primary key
#  owner_id   :integer
#  owner_type :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

"""
Every user has one (and only one) fruitbasket 
A fruitbasket is used for storing fruitbags
(fruitbags are containers for single fruittypes)
"""


class Fruitbasket < ActiveRecord::Base

  belongs_to :owner, polymorphic: true
	has_many :fruitbags
	
end
