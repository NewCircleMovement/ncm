module Api
  module V1
    class EpicentersController < BaseController

      before_filter :find_epicenter, only: [:show, :update]
      
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
        # render json: Epicenter.where('owner_id = ?', @epicenter.id)
        puts Epicenter.all.count
        render json: Epicenter.all
      end


      def show
        render json: @epicenter
      end

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
      

      private
      
      def find_epicenter
        render nothing: true, status: :not_found unless @epicenter.present?
      end
      

    end
  end
end