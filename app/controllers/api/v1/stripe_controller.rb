module Api
  module V1
    class StripeController < BaseController

      # GET
      def get_public_key
        render json: { publicKey: Rails.application.secrets.stripe_publishable_key }
      end

      # GET
      def get_domain_url
        if Rails.env == "production"
          domain_url = "https://www.newcirclemovement.org"
        else
          domain_url = "http://localhost:3000"
        end
        return domain_url
      end


      # POST 
      def new_subscription_session
        error = nil
        membership_id = params['stripe']['membership_id'].to_i
        @membership = Membership.find(membership_id)

        begin
          session = Stripe::Checkout::Session.create(
            success_url: get_domain_url + "/epicenters/new_circle_movement/subscriptions/#{@membership.id}/welcome",
            cancel_url: get_domain_url + "/epicenters/new_circle_movement/subscriptions/#{@membership.id}/cancelled",
            payment_method_types: ['card'],
            client_reference_id: current_user.id,
            customer_email: current_user.email,
            subscription_data: {
              items: [{ 
                plan: @membership.payment_id,
              }],
              trial_end: get_trial_end || nil
            }
          )
        rescue Stripe::InvalidRequestError, Stripe::APIConnectionError
          error = "Your payment were not completed. Please try again."
        end

        render json: { checkoutSessionId: session['id'], error: error }
      end

      def update_card_session
        begin
          session = Stripe::Checkout::Session.create(
            success_url: get_domain_url + "/users/#{current_user.id}/payment?card_update=true&session_id={CHECKOUT_SESSION_ID}",
            cancel_url: get_domain_url + "/users/#{current_user.id}/payment?card_update=false",
            payment_method_types: ['card'],
            client_reference_id: current_user.id,
            customer_email: current_user.email,
            mode: 'setup'
          )
        rescue Stripe::InvalidRequestError, Stripe::APIConnectionError
          error = "Your payment were not completed. Please try again."
        end

        render json: { checkoutSessionId: session['id'], error: error }
      end


      # HANDLE webhooks -------------------------------------------------------------------------------------------
    
      # POST webhooks
      def webhooks
        webhook_secret = Rails.application.secrets.stripe_webhooks_secret

        event_type = params['type']
        data = params['data']
        data_object = data['object']
      
        puts event_type


        case event_type
        when 'checkout.session.completed'
          if data_object['mode'] == 'setup'
            puts data_object
          elsif data_object['mode'] == 'subscription'
            create_subscription(data_object)
          end

        when 'payment_method.attached', 'payment_method.updated'
          set_user_name_from_payment_object(data_object)
        end

        render json: { status: 'success' }
      end


      def set_user_name_from_payment_object(data_object)
        @user = User.find_by(:email => data_object['billing_details']['email'])
        unless @user.name.present?
          @user.update_name(data_object['billing_details']['name'])
        end
      end


      def create_subscription(data_object)
        user_id = data_object['client_reference_id'].to_i
        @user = User.find(user_id)

        @epicenter = Epicenter.grand_mother

        stripe_customer = Stripe::Customer.retrieve(data_object['customer'])
        current_subscriptions = stripe_customer.subscriptions.data || []
        active_subscription = current_subscriptions.select { |x| x.status == 'active' or x.status = 'trialing'}.first

        if active_subscription
          plan_id = active_subscription['plan']['id']
          @membership = Membership.find_by(payment_id: plan_id)
        
          @epicenter.make_membershipcard(@user, @membership, stripe_customer )
          @epicenter.make_member( @user )
          @epicenter.harvest_time_for( @user )

          log_details = { membership: @membership.name }
          EventLog.entry(@user, @epicenter, NEW_MEMBERSHIP, log_details, LOG_COARSE)
        else
          raise
        end
      end


      # -----------------------------------------------------------------------------
      
      def get_trial_end
        today = Date.new
        if (today <= Date.new(2019, 8).end_of_month) or (today <= Date.new(2019, 9).end_of_month - 2.days)
          return Date.new(2019, 9).end_of_month.to_time.to_i
        end
        return nil
      end

    end
  end
end