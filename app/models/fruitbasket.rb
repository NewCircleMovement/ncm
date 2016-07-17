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

  def find_fruitbag(fruittype)
    self.fruitbags.find_or_create_by(fruittype_id: fruittype.id, fruitbasket_id: self.id)
  end

  def receive_fruit(fruittype, amount)
    fruitbag = self.find_fruitbag(fruittype)
    fruitbag.amount += amount
    fruitbag.save
  end

  def give_fruit(fruittype, amount)
    fruitbag = self.find_fruitbag(fruittype)
    fruitbag.amount -= amount
    fruitbag.save
  end
	
end
