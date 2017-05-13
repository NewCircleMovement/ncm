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
  before_action :validate_user!, only: [:edit, :update]


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

  def fruitbasket
    @user = User.find(params[:user_id])
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
