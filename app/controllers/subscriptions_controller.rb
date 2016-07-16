class SubscriptionsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_epicenter

  def new
    @memberships = @epicenter.memberships
  end

  def create
    success = false
    puts "/////////////////////////////////////"
    puts params
    puts params[:epicenter_id]
    puts "epicenter", @epicenter.name
    puts "mother", @mother.name
    puts "we are in create", params[:membership_id]
    
    @membership = Membership.find(params[:membership_id])
    membershipcard = current_user.get_membershipcard(@membership)

    puts "membershipcard", membershipcard

    # subscription to "new circle movement"
    if @epicenter == @mother
      puts "this is NCM subscription"

      token = params[:stripeToken]
      member = current_user.get_member( membershipcard )
      
      if member # already has membershipcard with payment info
        puts "user is already member"
        if current_user.update_card( member, token )
          Stripe::Subscription.create(
            :customer => member.id,
            :plan => @membership.payment_id
          )
          success = true
          flash[:success] = "Du er nu igen aktivt medlem af New Circle Movement"
        else
          flash[:warning] = "Der var et problem med din gentilmelding. Prøv venligst igen."
        end
      else # create new customer and attach to new/existing membershipcard
        puts "we need to create new customer object in stripe"
        member = Stripe::Customer.create(
          card: token,
          plan: @membership.payment_id, 
          email: current_user.email
        )
        membershipcard = Membershipcard.where(
          user_id: current_user.id, 
          membership_id: @membership.id, 
        ).first_or_create
        membershipcard.payment_id = member.id
        membershipcard.save
        puts "here is the new membership card", member, membershipcard
        success = true
        flash[:success] = "Du er nu medlem af New Circle Movement"
      end
    
    # subscription to all other epicenters
    else
      puts "//////////////////////////////////////////////"
      puts "we need to handle this"
      puts params
      success = true
    end

    if success
      @epicenter.give_fruittree_to( current_user )
      @epicenter.make_tshirt( current_user, @epicenter.access_point('member') )
    end
    
    redirect_to epicenters_path
  end


  def edit
    if current_user.stripe_id
      customer = Stripe::Customer.retrieve( current_user.stripe_id )
      @subscription_id = customer.subscriptions.data[0]["id"]
      @card = customer.sources.data[0]
    end
  end


  def destroy
    success = false

    begin
      subscription = Stripe::Subscription.retrieve( params[:id] )
      if subscription.delete
        current_user.subscribed = false
        current_user.save
        flash[:success] = "You have successfully unsubscribed"
      else
        flash[:error] = "There was a problem with your unsubscription"
      end
    rescue Stripe::InvalidRequestError
      flash[:error] = "You do not appear to have any active subscriptions"
    end
    redirect_to epicenters_path
  end

  private

    def set_epicenter
      @epicenter = Epicenter.find_by_slug(params[:epicenter_id])
    end

end