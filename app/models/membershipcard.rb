# == Schema Information
#
# Table name: membershipcards
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  membership_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  payment_id    :string
#  epicenter_id  :integer
#

class Membershipcard < ActiveRecord::Base

  belongs_to :user
  belongs_to :membership

  def enough_fruit
    if self.membership.epicenter == self.membership.epicenter.mother
        enough_fruit = true
    else
        fruittype = self.membership.epicenter.mother.fruittype
        enough_fruit = (self.user.fruitbasket.fruit_amount( fruittype ) >= self.membership.monthly_fee )
    end
    return enough_fruit
  end


  def update_valid_supply
    self.valid_supply = false
    
    # MOTHER
    if self.membership.epicenter == self.membership.epicenter.mother
        if self.payment_id == "bank"
            self.valid_supply = true
        else
            next_month_date = Date.today.end_of_month + 1.days
            
            cards = Stripe::Customer.retrieve(self.payment_id)['sources']['data']

            cards.each do |card|
                expiration_date = Date.new(card.exp_year, card.exp_month)
                if expiration_date >= next_month_date
                    self.valid_supply = true
                end
            end
        end

    # OTHER EPICENTERS
    else
        monthly_mother_harvest = self.membership.epicenter.mother.get_membership_for( self.user ).monthly_gain
        monthly_epicenter_price = self.membership.monthly_fee  
        monthly_current_engagements = self.user.sum_of_all_engagements(self.membership.epicenter.mother.fruittype)

        if monthly_mother_harvest >= monthly_epicenter_price + monthly_current_engagements
            self.valid_supply = true
        end
    end
    self.save
    return self.valid_supply
  end
  
end
