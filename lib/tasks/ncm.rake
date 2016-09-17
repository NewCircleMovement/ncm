namespace :ncm do

  desc "Make new circle movement epicenter"
  task :make_mother => :environment do
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
      video_url: "", 
      max_members: 1000, 
      growing: false, 
      manifested: false, 
      niveau: nil, 
      depth_members: nil, 
      depth_fruits: nil 
    }

    puts "create mother epicenter_id"
    mother = Epicenter.find_or_create_by(params)
    mother.location = location
    
    if mother.save
      mother.mother_id = mother.id

      # create basis membership object for NCM
      membership = Membership.create(
        :name => 'basis', 
        :monthly_fee => 108,
        :monthly_gain => 100,
        :engagement => 2,
        :epicenter_id => mother.id
      )
      Stripe::Plan.create(
        :name => "Engagement 1",
        :id => "1",
        :amount => 10800,
        :interval => "month",
        :currency => "dkk"
      )

      puts "create fruitbasket"
      fruitbasket = Fruitbasket.find_or_create_by(:owner_id => mother.id, :owner_type => 'Epicenter')
      fruitbag = Fruitbag.create(:fruitbasket_id => fruitbasket.id)

      # create fruittype, fruitbasket and fruitbag for NCM
      puts "create fruittype - kroner"
      fruittype_kr = Fruittype.create(:name => 'kroner', :monthly_decay => 0.0, :epicenter_id => nil)

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
      Membershipcard.find_or_create_by(:user_id => user.id, :membership_id => membership.id)

      # give tshirts to user
      puts "create tshirts"
      mother.make_tshirt( user, caretaker_access )
      mother.make_tshirt( user, member_access )

      # give tree, fruitbasket and fruitbag to user
      puts "give fruittree"
      mother.give_fruittree_to( user )
      Fruitbasket.find_or_create_by(:owner_id => user.id, :owner_type => 'User')

      puts "give fruitbag"
      mother.give_fruitbag_to( user )

    end
  end

end