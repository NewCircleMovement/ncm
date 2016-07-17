namespace :ncm do

  desc "Make new circle movement epicenter"
  task :make_mother => :environment do

    # first create the location for "ncm"
    location = Location.find_or_create_by( { density: 1, name: "New Circle Movement"} )

    # create "caretaker" and "member" access points
    if location.save
      caretaker_access = location.access_points.build(:name => "caretaker")
      member_access = location.access_points.build(:name => "member")
      caretaker_access.save
      member_access.save
    end

    params = {  
      name: "New Circle Movement",
      description: "Mother", 
      video_url: "", 
      max_members: 1000, 
      growing: false, 
      manifested: false, 
      niveau: nil, 
      depth_members: nil, 
      depth_fruits: nil 
    }

    mother = Epicenter.find_or_create_by(params)
    mother.location = location
    
    if mother.save
      mother.mother_id = mother.id

      # create basis membership object for NCM
      membership = Membership.create(
        :name => 'basis', 
        :monthly_fee => 108,
        :engagement => 2,
        :epicenter_id => mother.id
      )

      # create fruittype, fruitbasket and fruitbag for NCM
      fruittype = Fruittype.create(:name => 'citron', :monthly_decay => 0.1, :epicenter_id => mother.id)
      Fruitbasket.find_or_create_by(:owner_id => mother.id, :owner_type => 'Epicenter')
      Fruitbag.create(:fruittype_id => fruittype.id, :fruitbasket_id => fruitbasket.id)

      # create user
      User.skip_callback(:create, :after, :create_fruittree_and_basket)
      user = User.find_or_create_by(:name => "Johan", :email => "johantino@gmail.com")
      user.password = "12345678"
      user.save(validate: false)

      # make user member
      Membershipcard.find_or_create_by(:user_id => user.id, :membership_id => membership.id)

      # give tshirts to user
      mother.make_tshirt( user, caretaker_access )
      mother.make_tshirt( user, member_access )

      # give tree, fruitbasket and fruitbag to user
      mother.give_fruittree_to( user )
      Fruitbasket.find_or_create_by(:owner_id => user.id, :owner_type => 'User')
      mother.give_fruitbag_to( user )

    end
  end

end