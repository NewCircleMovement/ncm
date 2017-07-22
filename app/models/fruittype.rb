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

  validates :name, :presence => true
  validates :monthly_decay, 
    presence:true, 
    numericality: { only_float: true, greater_than: 0 }, 
    :inclusion => { :in => 0..1 }

  belongs_to :epicenter

  # TODO: do we need this function
  def update_epicenter_fruitbag
    unless self.epicenter_id == nil
      fruitbag = self.epicenter.fruitbasket.fruitbags.first
      fruitbag.fruittype_id = self.id
      fruitbag.save
    end
  end

end
