namespace :maintain do

  desc "members and fruit counters"
  task :epicenter_counters => :environment do
    Epicenter.all.each do |epicenter|
      epicenter.update_counters
      epicenter.save
    end

  end

end