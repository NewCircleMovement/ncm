# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  name                   :string
#  first_name             :string
#  last_name              :string
#  image                  :string
#  profile_text           :text
#

class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:edit, :update, :show]
  before_action :validate_user!, only: [:edit, :update, :payment]


  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])

    if @user == current_user
      @show_profile = true
    else
      profile_memberships = @user.epicenters.map(&:id).uniq
      users_memberships = current_user.epicenters.map(&:id).uniq
      @show_profile = (profile_memberships & users_memberships).count >= 2
    end
    
  end

  def edit
    # @caretaker_epicenters = @user.epicenters_with_role('caretaker')
  end

  def update
    if @user.update(user_params)
      redirect_to edit_user_path(@user), notice: 'Din profil blev opdateret.'
    else
      render action: 'edit'
    end
  end

  def memberships
    @user = User.find(params[:user_id])
  end

  def admissions
    @user = User.find(params[:user_id])
  end

  def caretaker
    @user = User.find(params[:user_id])
  end

  def fruitbasket
    @user = User.find(params[:user_id])
  end


  def payments
    @user = User.find(params[:user_id])
    @payment = @user.get_membershipcard(@mother)
    @membership = @user.get_membership(@mother)

    if @payment and @payment.payment_id != "bank" and @payment.payment_id != nil
      begin
        customer = Stripe::Customer.retrieve(@payment.payment_id)
        @card = customer.sources.retrieve(customer.default_source)
      rescue Stripe::InvalidRequestError => error
        @error = error
      end
    end
  end


  def support_epicenter
    amount = params['support']['amount']
    @epicenter = Epicenter.find(params['epicenter_id'])
    @user = User.find(params[:user_id])
    
    result = @user.give_fruit_to(@epicenter, @epicenter.mother_fruit, amount.to_i, )
    if result
      @epicenter.update_counters
      message = "Tak for din støtte med #{amount} #{@epicenter.mother_fruit.name} til #{@epicenter.name}"
    else
      message = "Tak for tanken, men du har ikke nok #{@epicenter.mother_fruit.name}"
    end

    redirect_to epicenter_path(@epicenter), notice: message
  end

  private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:name, :first_name, :last_name, :profile_text, :image)
    end

    def validate_user!
      if @user != current_user
        redirect_to edit_user_path(current_user)
      end
    end

end
