module Api
  module V1
    class UsersController < BaseController

      before_filter :set_user, only: [:show, :update]

      
      # before_filter only: :create do |c|
      #   meth = c.method(:validate_json) 
       #  meth.call (@json.has_key?('user') && @json['user'].responds_to?(:[]) && @json['user']['email'])
      # end

      
      # before_filter only: :update do |c|
      #   meth = c.method(:validate_json)
      #   meth.call (@json.has_key?('user'))
      # end


      # before_filter only: :create do |c|
      #   meth = c.method(:check_existence)
      #   meth.call(@user, "User", "find_by_email(@json['user']['email'])")
      # end


      def index
        puts "///////////////////////////////////"
        users = nil
        if params[:tshirt]
          users = @epicenter.users_with_tshirt(params[:tshirt])
        else 
          users = @epicenter.users
        end        
        render json: users
        # render json: Epicenter.where('owner_id = ?', @epicenter.id)
      end


      # def show
      #   render json: @user
      # end

      # def create
      #   if @user.present?
      #     render nothing: true, status: :conflict
      #   else
      #     @user = User.new
      #     update_values :@user, @json['user']
      #   end
      # end


      # def update
      #   @user.assign_attributes(@json['user'])
      #   if @user.save
      #     render json: @user
      #   else
      #     render nothing: true, status: :bad_request
      #   end
      # end


      def authenticate
        valid_password = false
        valid_member = false
        @user = User.find_by_email(params[:email])
        if @user
          valid_password = @user.valid_password?(params[:password] || '')
          valid_member = @epicenter.has_member?(@user)
          membership = @user.membership_for(@epicenter)
        end

        render json: { 
          user: @user, 
          valid_password: valid_password, 
          valid_member: valid_member, 
          membership: membership 
        }
      end
      

      private
      
      def set_user
        @user = User.find_by_email(params[:email])
        render nothing: true, status: :not_found unless @user.present?
      end

    end
  end
end