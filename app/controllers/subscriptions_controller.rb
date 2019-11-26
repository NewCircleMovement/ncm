class SubscriptionsController < ApplicationController
  # before_filter :authenticate_user!, except: [:new, :create]
  before_filter :authenticate, except: [:new]
  before_filter :set_epicenter, except: [:update_creditcard]
  before_filter :check_user_before_membership, only: [:create]

  def index
    @memberships = @epicenter.memberships
    
    if current_user.has_member_tshirt?(@epicenter)
      @membership = @epicenter.get_membership_for(current_user)
      # @change = current_user.membership_changes.find_by(epicenter_id: @epicenter)
      # if @change
      #   @new_membership = Membership.find(@change.new_membership_id)
      # end
    else
      puts "redirect attempt", epicenter_subscriptions_path( @epicenter )
      flash[:notice] = "Du er ikke aktivt medlem af #{@epicenter.name}"
      redirect_to epicenters_path
    end
  end

  def show
  end

  def new
    switch_to_credit_card = false
    
    if @epicenter == Epicenter.grand_mother
      membershipcard = current_user.get_membershipcard( @epicenter )
      if membershipcard.present?
        switch_to_credit_card = (membershipcard.payment_id == 'bank' or membershipcard.payment_id == 'upgrade')
      end
    end

    if current_user and @epicenter.has_member?( current_user ) and switch_to_credit_card == false
      flash[:notice] = "Du er allerede medlem. Du kan redigere dit medlemsskab her."
      redirect_to epicenter_subscriptions_path( @epicenter )
    else
      if switch_to_credit_card
        if membershipcard.payment_id == 'bank'
          flash[:notice] = "You are changing from Bank to Credit card member."
        end

        if membershipcard.payment_id == 'upgrade'
          flash[:notice] = "Please pick a new plan."    
        end
      end
      if session[:new_ncm_membership] and @epicenter == Epicenter.grand_mother
        @request = session[:new_ncm_membership]
        @request_epicenter = Epicenter.find_by_slug(@request['epicenter_id'])
        @request_membership = @request_epicenter.memberships.find(@request['membership_id'])
        
        @membership = @epicenter.memberships.where("monthly_gain >= ?", @request_membership.monthly_fee).min_by(&:monthly_gain)
      else
        @memberships = @epicenter.memberships
      end
    end
  end


  # will be called by stripe upon successful signup
  def welcome
    @membership = Membership.find(params['subscription_id'])
  end


  # POST > createa NEW subscription (but only for NON-mother epicenters)
  def create
    success = false
    no_success_message = ""
    
    # find the epicenter membership that the user wants
    @membership = Membership.find(params[:membership_id])
    membershipcard = current_user.get_membershipcard( @epicenter )

    # subscription to "new circle movement"
    if @epicenter == @mother
      flash[:warning] = 'This option is no longer active'
      redirect_path = epicenter_path(@epicenter)
    
    # subscription to all other epicenters
    else 
      puts "create non-NCM Epicenter subscription"
      stripe_customer = false
     
      success = @epicenter.validate_and_pay_new_membership( current_user, @membership )
      unless success
        no_success_message = "Du har ikke nok beholdning og/eller månedlig tilførsel af #{@epicenter.mother.fruittype.name}"
      end
    end

    if success
      if @epicenter == @mother
        current_user.name = params['stripeBillingName']
        splitted_name = current_user.name.split(' ')
        if splitted_name.length > 2
          current_user.last_name = splitted_name[-1]
          current_user.first_name = current_user.name.strip().gsub(current_user.last_name, '')
        elsif splitted_name == 2
          current_user.first_name = splitted_name[0]
          current_user.last_name = splitted_name[1]
        else
          current_user.first_name = splitted_name[0]
        end
        current_user.save
      end

      @epicenter.make_membershipcard( current_user, @membership, stripe_customer )
      @epicenter.make_member( current_user )
      @epicenter.harvest_time_for( current_user )

      log_details = { membership: @membership.name }
      EventLog.entry(current_user, @epicenter, NEW_MEMBERSHIP, log_details, LOG_COARSE)

      @request = session[:new_ncm_membership]
      if stripe_customer and @request        
        @child = Epicenter.find_by_slug(@request['epicenter_id'])
        @child_membership = @child.memberships.find(@request['membership_id'])

        session.delete(:new_ncm_membership)

        if @child.validate_and_pay_new_membership( current_user, @child_membership )
          @child.make_membershipcard( current_user, @child_membership, false )
          @child.make_member( current_user )
          @child.harvest_time_for( current_user )
          log_details = { membership: @child_membership.name }
          EventLog.entry(current_user, @child, NEW_MEMBERSHIP, log_details, LOG_COARSE)
        end
      end

      if @child
        if current_user.has_member_tshirt?(@child)
          flash[:success] = "Welcome. You are now a member of #{@child.name} and #{@epicenter.name}"
          redirect_path = epicenter_path(@child)
        else
          flash[:success] = "Welcome. You are now a member of #{@child.name}. BUT NOT #{@epicenter.name}"
          redirect_path = epicenter_path(@epicenter)
        end
      else
        flash[:success] = "Welcome. You are now a member af #{@epicenter.name}"
        redirect_path = epicenter_path(@epicenter)
      end
    else
      flash[:warning] = no_success_message
      redirect_path =  new_epicenter_subscription_path(@epicenter)
    end


    redirect_to redirect_path
  end


  def edit
  end

  
  # changing / updating a users subscription goes through this
  def update
    success = false
    
    old_membership = current_user.membership_for(@epicenter)
    new_membership = Membership.find(params[:id])
    upgrade = new_membership.monthly_fee > old_membership.monthly_fee

    membershipcard = current_user.get_membershipcard( @epicenter )

    # change subscription for "new circle movement"
    if @epicenter == @mother 
      redirect_path = nil

      # subscription is nil if bank member of if we have stripe info but no active subsctiptions
      if membershipcard.payment_id == 'bank'
        subscription = nil
      else
        customer = Stripe::Customer.retrieve( membershipcard.payment_id ) rescue nil
        subscription = customer.subscriptions.first rescue nil
      end

      # if we have active subscription we can simply change it
      if subscription
        # change user's subscription
        subscription.plan = new_membership.payment_id.to_s
        
        # if success and upgrade, charge additional payment
        if subscription.save
          success = true

          if upgrade
            today = Date.today
            diff_amount = new_membership.monthly_fee - old_membership.monthly_fee
            days_in_month = Time.days_in_month(today.month, today.year)
            days_left_in_month = days_in_month - today.day + 1
            percent_left = days_left_in_month / days_in_month.to_f

            # only charge for changes if there are more than 5% of days left in month and user is not in "trialing" subscription
            if (percent_left > 0.05 and subscription.status != 'trialing')
              charge_amount = [diff_amount * percent_left, 25].max.round
              payment = Stripe::Charge.create(
                :amount => charge_amount * 100,
                :currency => 'dkk',
                :customer => customer.id,
                :description => "Membership change from #{old_membership.name} to #{new_membership.name}"
              )
            end
          end

          current_user.membershipcards.each do |card|
            card.update_valid_supply
          end
        else
          no_success_message = "Der skete desvære en fejl. Betalingen blev ikke gennemført (subs171)"
        end

      # otherwise we need to create a new credit card subscription
      # the user does not have an active subscription but we have stripe info, so we delete it
      else
        if customer
          customer.delete
        end
        if membershipcard.payment_id != 'bank'
          membershipcard.payment_id = 'upgrade'
        end
        membershipcard.save

        redirect_path = new_epicenter_subscription_path(@epicenter)
      end

    # change subscription to all other epicenters
    else 
      success = @epicenter.validate_and_pay_new_membership( current_user, new_membership )
      unless success 
        no_success_message = "Du har ikke nok beholdning og/eller månedlig tilførsel af #{@epicenter.mother.fruittype.name}"
      end
    end


    # if we have success we can update the users membershipcard
    if success
      # update membershipcard
      membershipcard.membership_id = new_membership.id
      membershipcard.valid_payment = true
      membershipcard.update_valid_supply

      puts "--------------------------------"
      puts "new membership", membershipcard.membership.monthly_gain

      if membershipcard.save
        log_details = { from: old_membership.name, to: new_membership.name }
        EventLog.entry(current_user, @epicenter, MEMBERSHIP_CHANGE, log_details, LOG_COARSE)

        # only add fruits if upgrading
        if upgrade
          @epicenter.harvest_time_for(current_user)
        end

        flash[:success] = "Du er nu #{new_membership.name} medlem af #{@epicenter.name}"        
      else 
        flash[:error] = "Der skete desværre en fejl (142). Kontakt venligst NCM"
      end
      redirect_path = epicenter_path(@epicenter)
    
    # otherwise, if we don't have a redirect already (change from bank to credit card)
    # display error to user
    else
      if not redirect_path
        membershipcard.valid_payment = false
        membershipcard.save

        flash[:warning] = no_success_message
        redirect_path = epicenter_subscriptions_path(@epicenter)
      end
    end

    redirect_to redirect_path
  end


  def update_creditcard
    token = params[:stripeToken]

    card = current_user.get_membershipcard(@mother)
    customer = Stripe::Customer.retrieve( card.payment_id )
    current_user.update_card( customer, token)
    card.update_valid_supply
    
    # name = params[:stripeBillingName]
    # country = params[:stripeBillingAddressCountry]
    # zip = params[:stripeBillingAddressZip]
    # street1 = params[:stripeBillingAddressLine1]
    # city = params[:stripeBillingAddressCity]
    flash[:success] = "Great! Thansk for updating your credit card"
    redirect_to user_payment_path(current_user)
  end

  # def cancel_change
  #   change = current_user.requested_change(@epicenter)
  #   change.destroy
  #   flash[:success] = "Dit medlemskab vil ikke længere blive ændret"
  #   redirect_to epicenter_subscriptions_path(@epicenter)
  # end


  def destroy
    caretaker = false
    
    if params[:user_id].present?
      caretaker = true
      user = User.find(params[:user_id])
    else
      user = current_user
    end

    target = "#{caretaker ? user.name + ' is' : 'You are'}"

    if @epicenter == @mother
      card = user.get_membershipcard(@epicenter)
      
      if card.payment_id == "bank"
        @epicenter.delete_member(user)
        user.destroy
      else
        stripe_user = user.get_member(card)
        stripe_subscription = stripe_user.subscriptions.first
        if stripe_subscription.present?
          begin
            subscription = Stripe::Subscription.retrieve( stripe_user.subscriptions.first.id )
            if subscription.delete
              @epicenter.delete_member(user)
              user.destroy
              flash[:success] = "#{target} no longer active member of New Circle Movement"
            else
              flash[:error] = "A problem occurred while canceling the membership"
            end
          rescue Stripe::InvalidRequestError, Stripe::APIConnectionError
            flash[:error] = "An error occurred while cancelling the payment"
          end
        else
          @epicenter.delete_member(user)
          user.destroy
        end
      end
    else
      @epicenter.delete_member(user)
    end
    
    flash[:success] = "#{target} no longer member of #{@epicenter.name}"
    if caretaker
      redirect_to epicenter_edit_members_path(@epicenter)
    else
      redirect_to epicenters_path
    end
  end


  private

    def set_epicenter
      @epicenter = Epicenter.find_by_slug(params[:epicenter_id])
      @pages = @epicenter.epipages
    end

    # checks that a user is active NCM member before signing up to child epicenter
    # if user is not NCM user, redirects to ncm payment page (with requested child epicenter)
    def check_user_before_membership
      if current_user
        ncm_membership = current_user.get_membership(@mother)
        epicenter = Epicenter.find_by_slug(params['epicenter_id'])

        if epicenter != @mother and not ncm_membership
          session[:new_ncm_membership] = { 
            :epicenter_id => params['epicenter_id'], 
            :membership_id => params['membership_id'],
            :t => Time.now
          }
          #
          redirect_to new_epicenter_subscription_path(@mother)
        end
      else
        # it's possible that we can put the logic from "authenticate" method below here
        redirect_to epicenters_path
      end
    end

    def authenticate
      # @child = Epicenter.find_by_slug(params['epicenter_id'])
      # @child_membershio = @child.memberships.find(params['membership_id'])      

      # if @check_epicenter == Epicenter.grand_mother
      #   session.delete(:new_ncm_membership)
      # else
      #   session[:new_ncm_membership] = { :epicenter_id => params['epicenter_id'], :membership_id => params['membership_id'] }
      # end

      if current_user
        authenticate_user!
      else
        session[:new_ncm_membership] = { 
          :epicenter_id => params['epicenter_id'], 
          :membership_id => params['membership_id'],
          :t => Time.now
        }
        redirect_to new_user_registration_path(:epicenter_id => params['epicenter_id'], :membership_id => params['membership_id'])
      end
    end


end