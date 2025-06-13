Rails.application.config.middleware.use OmniAuth::Builder do
  provider :openid_connect, {
    name: :okta,
    scope: [ :openid, :email, :profile, :groups ],
    discovery: true,
    issuer: ENV["OKTA_ISSUER_URL"],
    client_id: ENV["OKTA_CLIENT_ID"],
    client_secret: ENV["OKTA_CLIENT_SECRET"],
    uid_field: :sub,
    redirect_uri: "http://localhost:3000/auth/okta/callback",
    client_options: {
      identifier: ENV["OKTA_CLIENT_ID"],
      secret: ENV["OKTA_CLIENT_SECRET"],
      redirect_uri: "http://localhost:3000/auth/okta/callback",
      port: 443,
      scheme: "https",
      host: "hendrick.okta.com"
    }
  }
end

# Configure OmniAuth to handle CSRF protection
OmniAuth.config.allowed_request_methods = [ :post, :get ]
OmniAuth.config.silence_get_warning = true
