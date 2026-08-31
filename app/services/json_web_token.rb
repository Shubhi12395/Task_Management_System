class JsonWebToken
  SECRET_KEY = Rails.application.secret_key_base.to_s

  def self.encode(payload, exp = 5.days.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY,'HS256')
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY,true,{alogrithm:'HS256'})[0]
    HashWithIndifferentAccess.new(decoded)
  rescue
  # 
  end
end
