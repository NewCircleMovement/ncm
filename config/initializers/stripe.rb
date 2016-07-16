Rails.configuration.stripe = {
  :publishable_key => "",
  :secret_key      => ""
}

if Rails.env == "production"
  Rails.configuration.stripe = {
    :publishable_key => ENV['STRIPE_PUBLISHABLE_KEY'],
    :secret_key => ENV['STRIPE_SECRET_KEY']
  }
else
  Rails.configuration.stripe[:publishable_key] = KEYS[:stripe_publishable_key]
  Rails.configuration.stripe[:secret_key] = KEYS[:stripe_secret_key]
end

Stripe.api_key = Rails.configuration.stripe[:secret_key]

puts Rails.configuration.stripe