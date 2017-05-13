# == Schema Information
#
# Table name: loggings
#
#  id         :integer          not null, primary key
#  id_1       :integer
#  id_2       :integer
#  type_1     :string
#  type_2     :string
#  event      :string
#  text       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Logging < ActiveRecord::Base
end
