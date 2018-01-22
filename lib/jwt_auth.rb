class JwtAuth
  def self.decode(token, options = {})
    claims = { algorithm: api_algo, leeway: expires.to_i }.merge(options)
    # iss: ENV['AUTH_ISS'], verify_iss: true # TODO: move to options
    JWT.decode(token, auth_secret, true, claims)
  end

  def self.issue(client_key)
    JWT.encode({ client_key: client_key }, auth_secret, api_algo)
  end

  def self.client_key
    ENV['CLIENT_KEY']
  end

  def self.auth_secret
    ENV['AUTH_SECRET']
  end

  def self.api_algo
    ENV['AUTH_ALGO']
  end

  def self.expires
    ENV['AUTH_EXP']
  end
end
