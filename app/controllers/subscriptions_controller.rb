class SubscriptionsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_epicenter

  def index
    @memberships = @epicenter.memberships
    @membership = @epicenter.get_membership_for(current_user)
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
    
    @membership = Membership.find(params[:membership_id])
    membershipcard = current_user.get_membershipcard(@membership)

    # subscription to "new circle movement"
    if @epicenter == @mother
      puts "create NCM subscription"
      token = params[:stripeToken]
      member = current_user.get_member( membershipcard )
      
      if member # already has membershipcard with payment info
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
        success = true
        flash[:success] = "Du er nu medlem af New Circle Movement"
      end
    
    # subscription to all other epicenters
    else 
      puts "create non-NCM Epicenter subscription"
      # TODO: make some form of payment to epicenter
      membershipcard = Membershipcard.where(
        user_id: current_user.id, 
        membership_id: @membership.id, 
      ).first_or_create
      success = true
    end

    if success
      @epicenter.make_member( current_user)
      @epicenter.give_fruit_to( current_user, @membership )
      flash[:success] = "Du er nu medlem af #{@epicenter.name}"
      # TODO: redirect to epicenter profile page
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

    puts "we are in update"
    flash[:success] = "Du har ændret dit medlemsskab til"
    puts epicenters_path(@epicenter)
    redirect_to epicenter_path(@epicenter)
  end


  def destroy
    success = false

    # begin
    #   subscription = Stripe::Subscription.retrieve( params[:id] )
    #   if subscription.delete
    #     current_user.subscribed = false
    #     current_user.save
    #     flash[:success] = "You have successfully unsubscribed"
    #   else
    #     flash[:error] = "There was a problem with your unsubscription"
    #   end
    # rescue Stripe::InvalidRequestError
    #   flash[:error] = "You do not appear to have any active subscriptions"
    # end
    redirect_to epicenters_path
  end

  private

    def set_epicenter
      @epicenter = Epicenter.find_by_slug(params[:epicenter_id])
    end

end