if Rails.env == "production"
  S3_CREDENTIALS = { 
    :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
    :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY'],
    :bucket => ENV['S3_BUCKET_NAME']
  }

else
  puts "we are in development"
  S3_CREDENTIALS = YAML.load_file(Rails.root.join("config/s3.yml"))[Rails.env].symbolize_keys  
end

CarrierWave.configure do |config|
  config.storage            = 'AWS',
  config.aws_bucket         = S3_CREDENTIALS[:bucket],
  config.aws_acl            = :public_read,
  config.aws_authenticated_url_expiration = 60 * 60 * 24 * 365,

  config.aws_credentials = {
    access_key_id:     S3_CREDENTIALS[:access_key_id],
    secret_access_key: S3_CREDENTIALS[:secret_access_key],
    region: 'eu-central-1'
  }
end

# Rails.configuration.stripe = {
#   :publishable_key => "",
#   :secret_key      => ""
# }

# if Rails.env == "production"
#   Rails.configuration.stripe = {
#     :publishable_key => ENV['STRIPE_PUBLISHABLE_KEY'],
#     :secret_key => ENV['STRIPE_SECRET_KEY']
#   }
# else
#   Rails.configuration.stripe[:publishable_key] = KEYS[:stripe_publishable_key]
#   Rails.configuration.stripe[:secret_key] = KEYS[:stripe_secret_key]
# end

# Stripe.api_key = Rails.configuration.stripe[:secret_key]

# puts Rails.configuration.stripe