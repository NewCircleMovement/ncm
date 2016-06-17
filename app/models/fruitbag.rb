# == Schema Information
#
# Table name: fruitbags
#
#  id             :integer          not null, primary key
#  amount         :integer
#  fruittype_id   :string
#  fruitbasket_id :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

"""
A user has many fruitbags in his fruitbasket
Fruitbags can only contain one fruittype
"""


class Fruitbag < ActiveRecord::Base

  belongs_to :fruitbasket
  belongs_to :fruittype

end
