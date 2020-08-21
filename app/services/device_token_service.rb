class DeviceTokenService
  def initialize(device)
    @device = device
  end

  def generate
    @device.access_token = SecureRandom.base58(32)
    @device.access_token_expired_at = Time.zone.now + Settings.device_tokens[:expires_in]
    @device.save!
  end
end
