# == Schema Information
#
# Table name: information
#
#  id         :integer          not null, primary key
#  owner_id   :integer
#  owner_type :string
#  string     :string
#  position   :integer
#  title      :string
#  body       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Information < ActiveRecord::Base
  belongs_to :owner, polymorphic: true
  
end
