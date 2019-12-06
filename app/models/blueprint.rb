class Blueprint < ActiveRecord::Base
  self.abstract_class = true

  def hello
    puts "hello"
  end  

  def write_to_log(event)
    case event
    when MEMBERSHIPCHANGE
      puts "membershipschange"
    end

  end

end
