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

  belongs_to :epicenter

end
