# Load the Rails application.
require File.expand_path('../application', __FILE__)

# set constant if in development
if Rails.env == "development"
  yml_file = Rails.root.join("config/keys.yml")
  if File.exists? yml_file
    KEYS = YAML.load_file(yml_file)[Rails.env].try(:symbolize_keys)
  else
    raise "Missing key file"
  end  
end

# Initialize the Rails application.
Rails.application.initialize!
