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
    return self.fruitbags.find_or_create_by(fruittype_id: fruittype.id, fruitbasket_id: self.id)
  end

  def show_content
    self.fruitbags.each do |bag|
      puts "#{Fruittype.find(bag.fruittype_id).name}: #{bag.amount}"
    end
  end

  def fruit_amount(fruittype)
    amount = 0
    fruitbag = self.fruitbags.find_by(fruittype_id: fruittype.id, fruitbasket_id: self.id)
    if fruitbag
      amount = fruitbag.amount
    end
  end

  # def receive_fruit(fruittype, amount)
  #   fruitbag = self.find_fruitbag(fruittype)
  #   fruitbag.amount += amount
  #   fruitbag.save
  # end 

  def give_fruit_to(receiver_basket, fruittype, amount)
    donor_bag = self.find_fruitbag(fruittype)

    owner_is_user = self.owner.class == User
    has_too_little_fruit = donor_bag.amount < amount
    
    unless owner_is_user and has_too_little_fruit and fruittype.name != "kroner"
      donor_bag.amount -= amount
      donor_bag.save
      receiver_bag = receiver_basket.find_fruitbag(fruittype)
      receiver_bag.amount += amount
      receiver_bag.save
    end 

    ##42 TODO
    ## if payment cannot be made, this should be logged in a logging object
  end
	
end
