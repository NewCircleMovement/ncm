
namespace :ncm do

  desc "harvest and engage"
  task :harvest_and_engage => :environment do
    Time.zone = 'Copenhagen'
    today = Date.today
    
    if today == today.end_of_month
      Epicenter.grand_mother.harvest_time
      Epicenter.grand_mother.engagement_time
    end

  end

  desc "Make new circle movement epicenter"
  task :make_mother => :environment do
    STRIPE_PLANS = [
      {
        name: "Engagement 1",
        id: "1",
        amount: 5400,
        interval: "month",
        currency: "dkk"
      }, {
        name: "Engagement 2",
        id: "2",
        amount: 10800,
        interval: "month",
        currency: "dkk"
      }, {
        name: "Engagement 3",
        id: "3",
        amount: 16200,
        interval: "month",
        currency: "dkk"
      }
    ]

    puts "make mother"

    # first create the location for "ncm"
    puts "create location"
    location = Location.find_or_create_by( { density: 1, name: "New Circle Movement"} )

    # create "caretaker" and "member" access points
    puts "create caretaker and member access points"
    if location.save
      caretaker_access = location.access_points.build(:name => "caretaker")
      member_access = location.access_points.build(:name => "member")
      caretaker_access.save
      member_access.save
    end

    params = {  
      name: "New Circle Movement",
      slug: "new_circle_movement",
      description: "Mother",
      tagline: "Bak op om gode projekter, eller lad fællesskabet støtte dig i at gøre din drøm til virkelighed.",
      video_url: "", 
      max_members: 10000, 
      growing: true, 
      manifested: true, 
      niveau: nil, 
      depth_members: 0, 
      depth_fruits: 0 
    }

    puts "create mother epicenter_id"
    mother = Epicenter.find_or_create_by(params)
    mother.location = location
    
    if mother.save
      puts "mother was saved"
      mother.mother_id = mother.id
      mother.save

      # create basis membership object for NCM
      Membership.create(
        :name => 'Engagement 1', 
        :monthly_fee => 54,
        :monthly_gain => 50,
        :engagement => 1,
        :payment_id => 1,
        :epicenter_id => mother.id
      )

      membership = Membership.create(
        :name => 'Engagement 2', 
        :monthly_fee => 108,
        :monthly_gain => 100,
        :engagement => 2,
        :payment_id => 2,
        :epicenter_id => mother.id
      )

      Membership.create(
        :name => 'Engagement 3', 
        :monthly_fee => 162,
        :monthly_gain => 150,
        :engagement => 3,
        :payment_id => 3,
        :epicenter_id => mother.id
      )

      # create stripe plans
      puts "Create stripe plans"
      STRIPE_PLANS.each do |plan|
        plan_exists = Stripe::Plan.retrieve(plan[:id])
        if not plan_exists
          Stripe::Plan.create(plan)
        end
      end

      # create fruittype, fruitbasket and fruitbag for NCM
      puts "create ncm fruitbasket and bag"
      fruitbasket = Fruitbasket.find_or_create_by(:owner_id => mother.id, :owner_type => 'Epicenter')
      fruitbag = Fruitbag.create(:fruitbasket_id => fruitbasket.id)
      
      puts "create fruittype - kroner"
      fruittype_kr = Fruittype.new(:name => 'kroner', :monthly_decay => 0.0, :epicenter_id => nil)
      fruittype_kr.save(validate: false) # ensure existence of KRONER 

      puts "create fruittype - vanddråber"
      fruittype_ncm = Fruittype.create(:name => 'vanddråber', :monthly_decay => 0.1, :epicenter_id => mother.id)
      fruitbag.fruittype_id = fruittype_ncm.id
      fruitbag.save

      # create user
      puts "create user"
      User.skip_callback(:create, :after, :create_fruittree_and_basket)
      user = User.find_or_create_by(:name => "Johan", :email => "johantino@gmail.com")
      user.password = "12345678"
      user.save(validate: false)

      # make user member
      puts "create membershipcard"
      # Membershipcard.find_or_create_by(:user_id => user.id, :membership_id => membership.id)

      # give tshirts to user
      puts "create tshirts"
      mother.make_tshirt( user, caretaker_access )
      # mother.make_tshirt( user, member_access )

      # give tree, fruitbasket and fruitbag to user
      puts "give fruittree"
      mother.give_fruittree_to( user )
      Fruitbasket.find_or_create_by(:owner_id => user.id, :owner_type => 'User')

      puts "give fruitbag"
      mother.give_fruitbag_to( user )

    end
  end

end