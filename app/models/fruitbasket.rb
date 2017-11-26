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

  def give_fruit_to(receiver_basket, fruittype, amount, log_level=LOG_FINE)
    fruit_was_given = false
    source_bag = self.find_fruitbag(fruittype)
    receiver_bag = receiver_basket.find_fruitbag(fruittype)

    bag_has_enough_fruit = (source_bag.amount >= amount)
    if bag_has_enough_fruit and fruittype.name != "kroner"
      source_bag.amount -= amount
      source_bag.save
      receiver_bag.amount += amount
      receiver_bag.save
      fruit_was_given = true
      details = { value: amount, fruittype: fruittype.name }
      EventLog.entry(self.owner, receiver_basket.owner, FRUIT_TRANSFER, details, log_level)
    end

    # enable epicenters to have negative fruits
    bag_owner_is_epicenter = (self.owner.class == Epicenter)
    if bag_owner_is_epicenter
      if not bag_has_enough_fruit and fruittype.name != "kroner"
        source_bag.amount -= amount
        source_bag.save
        receiver_bag.amount += amount
        receiver_bag.save
        fruit_was_given = true
        details = { value: amount, fruittype: fruittype.name }
        EventLog.entry(self.owner, receiver_basket.owner, FRUIT_TRANSFER, details, log_level)
      end
    end

    ##42 TODO
    ## if payment cannot be made, this should be logged in a logging object
    return fruit_was_given
  end
	
end
