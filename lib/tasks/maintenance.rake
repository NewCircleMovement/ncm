namespace :maintain do

  desc "update epicenter members and fruit counters"
  task :epicenter_counters => :environment do
    ActiveRecord::Base.logger.level = 1 
    
    Epicenter.all.each do |epicenter|
      epicenter.update_counters
      epicenter.save
    end
  end

  desc "update valid_supply indicators for stripe members"
  task :valid_payment_supply => :environment do
    ActiveRecord::Base.logger.level = 1 
    @mother = Epicenter.grand_mother
    
    cards_count = Membershipcard.all.count

    Membershipcard.all.each_with_index do |card, index|
      card.update_valid_supply
      puts "##{cards_count - index} #{card.user.email} - #{card.membership.epicenter.name} - #{card.valid_supply}"
    end

  end

end