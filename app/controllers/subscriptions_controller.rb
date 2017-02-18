class SubscriptionsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_epicenter

  def index
    @memberships = @epicenter.memberships
    
    if current_user.has_member_tshirt?(@epicenter)
      @membership = @epicenter.get_membership_for(current_user)
      @change = current_user.membership_changes.find_by(epicenter_id: @epicenter)
      if @change
        @new_membership = Membership.find(@change.new_membership_id)
      end
    else
      puts "redirect attempt", epicenter_subscriptions_path( @epicenter )
      flash[:notice] = "Du er ikke længere aktivt medlem af #{@epicenter.name}"
      redirect_to epicenters_path
    end
  end

  def show
  end

  def new
    if @epicenter.has_member?( current_user )
      flash[:notice] = "Du er allerede medlem. Du kan redigere dit medlemsskab her."
      redirect_to epicenter_subscriptions_path( @epicenter )
    else
      @memberships = @epicenter.memberships
    end
  end

  def create
    success = false
    no_success_message = ""
    
    @membership = Membership.find(params[:membership_id])
    membershipcard = current_user.get_membershipcard( @epicenter )

    # subscription to "new circle movement"
    if @epicenter == @mother
      puts "create NCM subscription"
      token = params[:stripeToken]

      member = current_user.get_member( membershipcard )
      
      if member # already has membershipcard with payment info
        if current_user.update_card( member, token )
          begin
            # first create active subscription to get payment
            subscription = Stripe::Subscription.create(
              :customer => member.id,
              :plan => @membership.payment_id
            )
            # delete active subscription
            subscription.delete
            # create new subscription with trial period to begin payment cycle at 1st in month
            Stripe::Subscription.create(
              :customer => member.id,
              :plan => @membership.payment_id,
              :trial_end => Time.now.end_of_month.to_i
            )
            success = true
          rescue Stripe::InvalidRequestError, Stripe::APIConnectionError
            flash[:danger] = "Din betaling blev desværre ikke gennemført. Prøv venligst igen"
          end          
          flash[:success] = "Du er nu igen aktivt medlem af New Circle Movement"
        else
          flash[:warning] = "Der var et problem med din gentilmelding. Prøv venligst igen."
        end
      else # create new customer and attach to new/existing membershipcard
        begin
          # first create customer, subscription and membershipcard
          stripe_customer = Stripe::Customer.create(
            card: token,
            plan: @membership.payment_id, 
            email: current_user.email
          )
          puts "--------------- member payment created -----------------"
          puts stripe_customer
          
          # then delete the subscription
          puts "stripe subscription", stripe_customer.subscriptions
          puts stripe_customer.subscriptions.first
          if stripe_customer.subscriptions.first
            stripe_customer.subscriptions.first.delete
            puts "subscription deleted"
          end
          
          puts "now create new trial subscription"
          # then create new subscription with trial_end (end of month)
          Stripe::Subscription.create(
            :customer => stripe_customer.id,
            :plan => @membership.payment_id,
            :trial_end => Time.now.end_of_month.to_i
          )
          puts "new trial subscription created"

          success = true
        rescue Stripe::InvalidRequestError, Stripe::APIConnectionError
          flash[:danger] = "Din betaling blev desværre ikke gennemført. Prøv venligst igen"
        end
      end
    
    # subscription to all other epicenters
    else 
      puts "create non-NCM Epicenter subscription"
      stripe_customer = false
     
      # TODO: make some form of payment to epicenter
      if @epicenter.validate_and_pay_new_membership( current_user, @membership )
        success = true
      else
        success = false
        no_success_message = "Du har ikke nok beholdning og/eller månedlig tilførsel af #{@epicenter.mother.fruittype.name}"
      end
    end

    if success
      if @epicenter == @mother
        current_user.name = params['stripeBillingName']
        current_user.save
      end
      @epicenter.make_membershipcard( current_user, @membership, stripe_customer )
      @epicenter.make_member( current_user )
      @epicenter.harvest_time_for( current_user )
      flash[:success] = "Du er nu medlem af #{@epicenter.name}"
      # TODO: redirect to epicenter profile page
    else
      flash[:warning] = no_success_message
    end
    redirect_to epicenters_path
  end


  def edit
    puts "we are in edit"
    # if current_user.stripe_id
    #   customer = Stripe::Customer.retrieve( current_user.stripe_id )
    #   @subscription_id = customer.subscriptions.data[0]["id"]
    #   @card = customer.sources.data[0]
    # end
  end

  def update
    change = MembershipChange.find_or_create_by(user_id: current_user.id, epicenter_id: @epicenter.id)
    @old_membership = current_user.membership_for(@epicenter)
    @new_membership = Membership.find(params[:id])
    change.old_membership_id = @old_membership.id
    change.new_membership_id = @new_membership.id
    change.save
    flash[:success] = "Dit medlemskab vil blive ændret til #{@new_membership.name}"
    redirect_to epicenter_subscriptions_path(@epicenter)
  end


  def cancel_change
    change = current_user.requested_change(@epicenter)
    change.destroy
    flash[:success] = "Dit medlemskab vil ikke længere blive ændret"
    redirect_to epicenter_subscriptions_path(@epicenter)
  end


  def destroy
    if @epicenter == @mother
      begin
        card = current_user.get_membershipcard(@epicenter)
        member = current_user.get_member(card)
        if member.delete
          current_user.destroy
          flash[:success] = "Du er ikke længere aktiv medlem af New Circle Movement"
        else
          flash[:error] = "Der var et problem med at slette dit abonnement"
        end
      rescue Stripe::InvalidRequestError, Stripe::APIConnectionError
        flash[:error] = "Du ser ikke ud til at være aktivt tilmeldt"
      end  
    else
      @epicenter.delete_member(current_user)
    end
    flash[:success] = "Du er ikke længere medlem af #{@epicenter.name}"
    redirect_to epicenters_path
  end


  private

    def set_epicenter
      @epicenter = Epicenter.find_by_slug(params[:epicenter_id])
    end

end