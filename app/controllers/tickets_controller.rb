class TicketsController < ApplicationController
  before_filter :set_epicenter, only: [:index, :new, :create]
  # before_filter :set_admission, only: [:create]

  def index
    @admissions = @epicenter.admissions.where("start_t >= ?", Time.now).order(start_t: :asc)
  end

  def new
    @admissions = @epicenter.admissions.where("start_t >= ?", Time.now).order(start_t: :asc)
    session[:ticket] = { :epicenter_id => @epicenter.slug, :t => Time.now }
  end

  def create
    if current_user
      token = params[:stripeToken]
      @admission = Admission.find(params[:admission_id])

      charge = nil
      error_message = nil
      begin
        charge = Stripe::Charge.create({
          amount: @admission.price * 100,
          currency: 'dkk',
          description: "#{@admission.name} - #{@admission.description}",
          source: token,
          receipt_email: current_user.email
        })
      rescue Stripe::InvalidRequestError => e
        error_message = "The Payment was not acceptep. Please try again."
      rescue Stripe::AuthenticationError => e
        error_message = "Your credit card could not be authenticated. Please try again."
      rescue Stripe::APIConnectionError => e
        error_message = "The connection to the payment service was terminated. Please try again."
      end

      unless charge
        redirect_to epicenter_path(@epicenter), alert: error_message || "There was a problem with the payment"
      else

        # print admission card to user
        admissioncard = current_user.admissioncards.build(:admission_id => @admission.id, :charge_id => charge.id)
        admissioncard.save

        # transfer waterdrops to selling epicenter
        fruitbag = @epicenter.fruitbasket.find_fruitbag(@mother.fruittype)
        fruitbag.amount += @admission.price
        fruitbag.save

        # increase counter on admissions count
        @admission.n_actual += 1
        
        unless current_user.name.present?
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

        
        redirect_to epicenter_path(@epicenter), notice: "Thank you for purchasing admission to #{@admission.name}"
      end

    else
      session[:ticket] = { :epicenter_id => @epicenter.slug, :t => Time.now }
      redirect_to new_user_registration_path, notice: "Please create an account before purchasing a ticket"
    end
  end

  private 

  def set_epicenter
    @epicenter = Epicenter.find_by_slug(params['epicenter_id'])
  end

end