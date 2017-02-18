# == Schema Information
#
# Table name: fruittrees
#
#  id               :integer          not null, primary key
#  owner_id         :integer
#  owner_type       :string
#  fruits_per_month :integer
#  fruittype_id     :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

"""
Every user has a fruittree for every epicenter to which he belongs
The fruittree has a fruittype to its corresponding epicenter
Fruittrees produce a certain amount of fruits per month
All produce end up in fruitbags in the user's fruitbasket
"""

class Fruittree < ActiveRecord::Base

  belongs_to :owner, polymorphic: true
  
end
