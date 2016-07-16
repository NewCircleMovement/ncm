# == Schema Information
#
# Table name: fruittypes
#
#  id            :integer          not null, primary key
#  name          :string
#  monthly_decay :float
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  epicenter_id  :integer
#

"""
Every epicenter has it's own unique fruittype
"""


class Fruittype < ActiveRecord::Base
  after_create :update_epicenter_fruitbag
  after_update :update_epicenter_fruitbag

  belongs_to :epicenter

  def update_epicenter_fruitbag
    fruitbag = self.epicenter.fruitbasket.fruitbags.first
    fruitbag.fruittype_id = self.id
    fruitbag.save
  end

end
