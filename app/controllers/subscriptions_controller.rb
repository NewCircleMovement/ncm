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
      flash[:notice] = "Du er ikke længere aktivt medlem af #{@epicenter.name}"
      redirect_to epicenter_subscriptions_path( @epicenter )
    end
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
    membershipcard = current_user.get_membershipcard( @epicenter )

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
          epicenter_id: @epicenter.id
        ).first_or_create
        membershipcard.membership_id = @membership.id
        membershipcard.payment_id = member.id
        membershipcard.save
        success = true
      end
    
    # subscription to all other epicenters
    else 
      puts "create non-NCM Epicenter subscription"
      # TODO: make some form of payment to epicenter
      membershipcard = Membershipcard.where(
        user_id: current_user.id, 
        epicenter_id: @epicenter.id, 
      ).first_or_create
      membershipcard.membership_id = @membership.id
      membershipcard.save
      success = true
    end

    if success
      @epicenter.make_member( current_user )
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

    puts params
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
    flash[:success] = "Du er ikke længere medlem af #{@epicenter.name}"
    redirect_to epicenters_path
  end

  private

    def set_epicenter
      @epicenter = Epicenter.find_by_slug(params[:epicenter_id])
    end

end