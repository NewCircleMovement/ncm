def get_ncm_membership(fee)
  return Epicenter.grand_mother.memberships.find_by(:monthly_fee => fee)
end


def get_tinkuy_fee(membership)
  required_fee = nil
  case membership
  when "BASIS"
    required_fee = 108
  when "KOMPLET"
    required_fee = 216
  else
    required_fee = 0
  end
  return required_fee
end


def create_new_subscription(log, email, membershipcard, membership)
  subscription = nil
  begin
    subscription = Stripe::Subscription.create(
      :customer => membershipcard.payment_id,
      :plan => membership.payment_id,
      :trial_end => Time.now.end_of_month.to_i
    )
  rescue Stripe::InvalidRequestError => e
    log.error "#{email} #{e}"
  rescue Stripe::AuthenticationError => e
    log.error "#{email} Authentication error > #{e}"
  rescue Stripe::APIConnectionError => e
    log.error "#{email} API connection error > #{e}"
  rescue Stripe::StripeError => e
    log.error "#{email} strange error #{e}"
  end
  return subscription
end


def update_membershipcard(card)

end



namespace :data do 

  task :prepare_migration => :environment do
    ActiveRecord::Base.logger.level = 1 
    @mother = Epicenter.grand_mother

    count = 0
    User.all.each do |u|
      puts
      is_member = false
      membercard = nil
      

      u.membershipcards.each do |card|
        if card.epicenter_id = @mother.id and not is_member
          count = count + 1
          is_member = true
          membercard = card
        end
      end

      if is_member
        print "#{count} MEMBER #{membercard.payment_id} - #{u.name} - #{u.email} - Card id: #{membercard.id}"
      else
        print "NOT MEMBER                - #{u.name} - #{u.email} - to be deleted"
        u.destroy
      end
    end
  end


  task :test, [:email] => :environment do |t, args|
    file = File.read("#{Rails.root}/public/seeddata.json")
    tinkuy_users = JSON.parse(file)
    loop_users = []
    loop_users = []
    if args[:email]
      tinkuy_users.each do |user|
        if user['email'] == args[:email]
          loop_users.append(user)
        end
      end
    else
      tinkuy_users.each do |user|
        unless ['christinarj@live.dk', 'lenejoergensen@gmail.com', 'pernille.bruun@gmail.com'].include? user['email']
          loop_users.append(user)
        end
      end
    end
    puts loop_users.count
    
  end


  task :populate, [:email] => :environment do |t, args|
    ActiveRecord::Base.logger.level = 1 
    log = Logger.new("#{Rails.root}/log/migrate.log")
    banklog = Logger.new("#{Rails.root}/log/migrate_bankers.log")

    # delete NCM users without memebershipcard

        
    # find mother
    @mother = Epicenter.grand_mother
    @tinkuy = Epicenter.find_by(:name => "Tinkuy")
    
    # jsonify seed data
    file = File.read("#{Rails.root}/public/seeddata.json")
    tinkuy_users = JSON.parse(file)
    
    loop_users = []
    if args[:email]
      tinkuy_users.each do |user|
        if user['email'] == args[:email]
          loop_users.append(user)
        end
      end
    else
      tinkuy_users.each do |user|
        unless ['christinarj@live.dk', 'lenejoergensen@gmail.com', 'pernille.bruun@gmail.com'].include? user['email']
          loop_users.append(user)
        end
      end
    end


    loop_users.each do |tinkuy_user|
      
      email = tinkuy_user['email']
      tinkuy_stripe_member = tinkuy_user['subscription']

      puts ""
      print "#{email}"
      
      @user = User.find_by(:email => email)


      ## tinkuy user already exists on NCM --------------------------------------------------------


      if @user
        print " > on ncm"
        # get users current membership, membershipcard and Stripe Information
        current_membership = @mother.get_membership_for(@user)
        current_membershipcard = @user.get_membershipcard(@mother)

        if @tinkuy.has_member?(@user)
          print " > already TINKUY member"
        else

          cus = nil
          begin
            cus = Stripe::Customer.retrieve(current_membershipcard.payment_id)
          rescue Stripe::InvalidRequestError => e
            log.error "#{email} - NOT FOUND - #{e}"
          rescue Stripe::AuthenticationError => e
            log.error "#{email} - NOT FOUND - Authentication error > #{e}"
          rescue Stripe::APIConnectionError => e
            log.error "#{email} - NOT FOUND - API connection error > #{e}"
          rescue Stripe::StripeError => e
            log.error "#{email} - NOT FOUND - error #{e}"
          end

          if cus
            ncm_fee = current_membership.monthly_fee
            tinkuy_fee = get_tinkuy_fee( tinkuy_user['membership'] )
            print " > pays #{tinkuy_fee}"
            print " > as #{tinkuy_stripe_member ? 'STRIPE' : 'BANK'} member"
            
            if ncm_fee == 54
              print " > but must pay more"
              log.info "#{email} - existing ncm member - should pay more as ncm"
              
              # delete current subsriptions            
              subscriptions = cus['subscriptions']['data']
              if subscriptions.length > 0
                subscriptions.each do |subscription|
                  subscription.delete( :at_period_end => true )
                  log.info "#{email} - subscription id #{subscription.id} set to cancel at end of month"
                end
              end

              # create new subscription with trial period and update current membershipcard
              new_fee = ncm_fee + tinkuy_fee
              new_membership = get_ncm_membership(new_fee)
              
              subscription = create_new_subscription( log, email, current_membershipcard, new_membership )
              new_membershipcard = @mother.make_membershipcard(@user, new_membership, cus)

              # update valid payment and valid supply on membershipcard
              if subscription
                log.info "#{email} - SUCCESS - has new #{new_membership.name} subscription"
                if not tinkuy_stripe_member
                  banklog.info "#{email} - SUCCESS - should stop bank transfer to Tinkuy"
                end
                new_membershipcard.valid_payment = true
                new_membershipcard.update_valid_supply
                new_membershipcard.save
                
              else
                log.info "#{email} - FAILED - problem with creating new #{new_membership.name} subscription"
                if not tinkuy_stripe_member
                  banklog.info "#{email} - FAILED - should update credit card on NCM"
                end
                new_membershipcard.valid_payment = false
                new_membershipcard.valid_supply = false
                new_membershipcard.save
              end
              
            else # ex. ncm_fee is 108 or 216
              print " > and pays the right amount"
              log.info "#{email} - tinkuy bank member - keep current subscription"
              new_fee = ncm_fee
            end
    
            puts ""
            

            # Harvest fruit for user and prepare to make user TINKUY member on NCM
            if not @tinkuy.has_member?(@user)
              print "#{email} - make tinkuy member on NCM platform ... "
              @mother.harvest_time_for( @user )

              # Make user Tinkuy member
              tinkuy_membership = @tinkuy.memberships.find_by( :name => tinkuy_user['membership'].capitalize )
              valid_payment = @tinkuy.validate_and_pay_new_membership( @user, tinkuy_membership )
              tinkuy_membershipcard = @tinkuy.make_membershipcard( @user, tinkuy_membership )

              @tinkuy.make_member( @user )
              bag = @user.fruitbasket.find_fruitbag(@tinkuy.fruittype)
              bag.amount = tinkuy_user['fruits']
              bag.save

              tinkuy_membershipcard.valid_payment = valid_payment
              tinkuy_membershipcard.update_valid_supply

              if valid_payment
                print " SUCCESS"
                log.info "#{email} successfully became a Tinkuy #{tinkuy_membership.name} member"
              else
                print " PROBLEM - Problem with payment"
                log.info "#{email} PROBLEM WITH becaming a Tinkuy #{tinkuy_membership.name} member"
              end
              puts ""
            end

          end # NO STRIPE CUSTOMER
        end


      ## tinkuy user DOES NOT exist on NCM --------------------------------------

      else
        print " > NOT on ncm"
        @user = User.new
        @user.email = tinkuy_user['email']
        @user.name = tinkuy_user['name']
        @user.first_name = tinkuy_user['first_name']
        @user.last_name = tinkuy_user['last_name']
        @user.profile_text = tinkuy_user['profile']
        @user.encrypted_password = tinkuy_user['encrypted_password']
        @user.save(:validate => false)
        print " > CREATED USER"
        
        tinkuy_fee = get_tinkuy_fee( tinkuy_user['membership'] )
        ncm_membership = @mother.memberships.find_by(:monthly_fee => tinkuy_fee)
        print " > should be #{ncm_membership.name} member"

        if tinkuy_stripe_member 
          #### STRIPE member
          stripe_id = tinkuy_stripe_member['stripe_id']
          begin
            cus = Stripe::Customer.retrieve(stripe_id)
            membershipcard = @mother.make_membershipcard(@user, ncm_membership, cus)
          rescue Stripe::InvalidRequestError => e
            log.error "#{email} #{e}"
          rescue Stripe::AuthenticationError => e
            log.error "#{email} Authentication error > #{e}"
          rescue Stripe::APIConnectionError => e
            log.error "#{email} API connection error > #{e}"
          rescue Stripe::StripeError => e
            log.error "#{email} strange error #{e}"
          end
          subscription = create_new_subscription(log, email, membershipcard, ncm_membership)
          if subscription
            log.info "#{email} - SUCCESS - has new #{ncm_membership.name} subscription"
            membershipcard.valid_payment = true
            membershipcard.update_valid_supply
            membershipcard.save
            print " > Stripe subscription created"
          else
            log.info "#{email} - FAILED - problem with creating new #{ncm_membership.name} subscription"
            membershipcard.valid_payment = false
            membershipcard.valid_supply = false
            membershipcard.save
            print " > PROBLEM with Stripe"
          end

        else
          #### BANK members
          membershipcard = @mother.make_membershipcard(@user, ncm_membership)
          membershipcard.payment_id = "bank"
          banklog.info "#{email} - new BANK member - as #{ncm_membership.name} member"
          membershipcard.valid_payment = true
          membershipcard.valid_supply = true
          membershipcard.save
          print " > Bank membershipcard created"
        end
        
        print " > make NCM member > "
        puts
        print " ... "
        @mother.make_member(@user)
        @mother.harvest_time_for(@user)
        
        print " > make Tinkuy member "
        tinkuy_membership = @tinkuy.memberships.find_by( :name => tinkuy_user['membership'].capitalize )
        valid_payment = @tinkuy.validate_and_pay_new_membership( @user, tinkuy_membership )
        tinkuy_membershipcard = @tinkuy.make_membershipcard( @user, tinkuy_membership )


        @tinkuy.make_member( @user )
        bag = @user.fruitbasket.find_fruitbag(@tinkuy.fruittype)
        bag.amount = tinkuy_user['fruits']
        bag.save
        
        tinkuy_membershipcard.valid_payment = valid_payment
        tinkuy_membershipcard.update_valid_supply



        if valid_payment
          print " SUCCESS"
          log.info "#{email} successfully became a Tinkuy #{tinkuy_membership.name} member"
        else
          print " PROBLEM - Problem with payment"
          log.info "#{email} PROBLEM WITH becaming a Tinkuy #{tinkuy_membership.name} member"
        end
        puts ""

      end
  
    end 
    puts ""   
  end


  task :refresh_stripe => :environment do
    ActiveRecord::Base.logger.level = 1 
    log = Logger.new("#{Rails.root}/log/refresh.log")
    
    @mother = Epicenter.grand_mother
    User.all.each do |user|
      print "#{user.email}"
      card = user.get_membershipcard(@mother)

      if card
        print " > has card"
        if card.payment_id
          print " > with id #{card.payment_id}"
          stripe_id = card.payment_id
          email = user.email

          cus = Stripe::Customer.retrieve(stripe_id)
          if not cus
            cus = Stripe::Customer.create(:id => stripe_id, :email => email)  
            token = Stripe::Token.create(
              :card => {
                :number => "4242424242424242",
                :exp_month => 10,
                :exp_year => [2019,2020].sample,
                :cvc => "314"
              }
            )
            cus.sources.create( {:source => token })
            print " > CREATED STRIPE CUSTOMER !!!"
          else
            print " > already existed"
          end
        else
          print " > but NO PAYMENT ID"
        end
      else
        print " > NO CARD"
      end
      puts ""
      
      # stripe_id = card.payment_id
      # email = user.email

      

    end

  end




  task :update_stripe => :environment do
    ActiveRecord::Base.logger.level = 1 
    log = Logger.new("#{Rails.root}/log/transfer.log")

    
    file = File.read('../tinkuy/seeddata.json')
    users = JSON.parse(file)
    users.each do |user|

      if user['subscription']
        email = user['email']
        stripe_id = user['subscription']['stripe_id']

        @user = User.find_by(:email => email)
        if @user
          puts
          print "Find stripe user: #{email} - stripe_id: #{stripe_id}"

          begin
            cus = Stripe::Customer.retrieve(stripe_id)
            print " - FOUND"
  
          rescue Stripe::InvalidRequestError => e
            begin
              cus = Stripe::Customer.create(:id => stripe_id, :email => email)
              token = Stripe::Token.create(
                :card => {
                  :number => "4242424242424242",
                  :exp_month => 10,
                  :exp_year => [2018,2018,2019,2020].sample,
                  :cvc => "314"
                }
              )
              cus.sources.create( {:source => token })
              print " - CREATED"
            rescue Stripe::InvalidRequestError => e
              print " - FAILED"
            end
          end


          # begin
          #   cus = Stripe::Customer.create(:id => stripe_id, :email => email)  
          #   begin
          #     token = Stripe::Token.create(
          #       :card => {
          #         :number => "4242424242424242",
          #         :exp_month => 10,
          #         :exp_year => [2018,2018,2019,2020].sample,
          #         :cvc => "314"
          #       }
          #     )
          #     cus.sources.create( {:source => token })
          #   rescue Stripe::InvalidRequestError => e
          #     log.error "#{email} #{e}"
          #   rescue Stripe::StripeError => e
          #     log.error "#{email} strange error #{e}"
          #   end

          # rescue Stripe::InvalidRequestError => e
          #   log.error "#{email} #{e}"
          # rescue Stripe::AuthenticationError => e
          #   log.error "#{email} Authentication error > #{e}"
          # rescue Stripe::APIConnectionError => e
          #   log.error "#{email} API connection error > #{e}"
          # rescue Stripe::StripeError => e
          #   log.error "#{email} strange error #{e}"
          # end
        
        else
          puts "Existing user: #{email}"
        end # if user does not exist in NCM

      end #if subscription
      
    end #tinkuy_users loop
  end #task



end
