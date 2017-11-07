namespace :data do 

  task :populate => :environment do
    file = File.read('../tinkuy/seeddata.json')

    # find mother
    @mother = Epicenter.grand_mother

    
    # define memberships
    membership_54 = Membership.find_by(:name => "Engagement 1")
    membership_108 = Membership.find_by(:name => "Engagement 2")
    membership_162 = Membership.find_by(:name => "Engagement 3")
    membership_216 = Membership.find_by(:name => "Engagement 4")

    
    # jsonify seed data
    users = JSON.parse(file)

    
    # Loop for all users
    users.first(2).each do |u|
      print "check user >> #{u['email']}"
      
      ## create the user if he/she does not already exist
      existing_user = false
      @user = User.find_by(:email => u['email'])
      if not @user
        print ">> create user #{u['email']}"
        @user = User.new
        @user.email = u['email']
        @user.name = u['name']
        @user.first_name = u['first_name']
        @user.last_name = u['last_name']

        @user.encrypted_password = u['encrypted_password']
        @user.save(:validate => false)
      else
        print ">> user exists"
        existing_user = true
      end

      ## check tinkuy membership
      membership = nil
      case u['membership']
      when "BASIS"
        membership = membership_108
      when "WEEKEND"
        membership = membership_216
      end

      
      if existing_user
    
      end


      if not existing_user

      end

      
      

      ## Stripe customer ids will have been transferred to NCM
      ## but we need to create new subscriptions for everyone that has one
      # puts "Create new subscription"
      # Stripe::Subscription.create(
      #   :customer => stripe_customer.id,
      #   :plan => membership.payment_id,
      #   :trial_end => Time.now.end_of_month.to_i
      # )

      
      # create membershipscard
      # membershipcard = Membershipcard.where(
      #   user_id: user.id, 
      #   epicenter_id: self.id, 
      # ).first_or_create
      # membershipcard.membership_id = membership.id

      
      # add stripe customer id to membershipcard
      subscription = u['subscription']
      puts subscription
      # if subscription
      #   membershipcard.payment_id = subscription['stripe_id']
      # end
      # membershipcard.save


      # make user member of mother and run harvest time
      # @mother.make_member(@user)
      # @mother.harvest_time_for(@user)

      
    end
    
  end

end