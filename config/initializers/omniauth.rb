OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'],
    {
      # name: 'name_of_strategy',   # defaults to google_oauth2
      # hd: 'domain.com'            # limits sign-in to a particular Google Apps hosted domain
      # hd: 'varland.com'
    }
end