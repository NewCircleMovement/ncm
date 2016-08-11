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

  def fruit_amount(fruittype)
    amount = 0
    fruitbag = self.fruitbags.find_by(fruittype_id: fruittype.id, fruitbasket_id: self.id)
    if fruitbag
      amount = fruitbag.amount
    end
  end

  def receive_fruit(fruittype, amount)
    fruitbag = self.find_fruitbag(fruittype)
    fruitbag.amount += amount
    fruitbag.save
  end

  ### when becoming member a user will receive fruits
  def give_fruit_to(fruittype, amount)
    receiver_bag = self.find_fruitbag(fruittype)
    receiver_bag.amount -= amount
    receiver_bag.save
  end

  def give_fruit(receiver_basket, fruittype, amount)
    donor_bag = self.find_fruitbag(fruittype)
    donor_bag.amount -= amount
    donor_bag.save
    receiver_bag = receiver_basket.find_fruitbag(fruittype)
    receiver_bag.amount += amount
    receiver_bag.save
  end
	
end
