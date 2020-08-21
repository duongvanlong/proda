class ProdaCustomFailure < Devise::FailureApp
  def http_auth
    super
    self.status = 403
  end
end