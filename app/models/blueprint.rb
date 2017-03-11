puts "/////////////////////"

class Blueprint < ActiveRecord::Base
  self.abstract_class = true

  def write_to_log(event)
    case event
    when MEMBERSHIPCHANGE
      puts "membershipschange"
    end

  end



end
