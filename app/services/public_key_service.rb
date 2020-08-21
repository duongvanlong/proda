class PublicKeyService
  def initialize(device, public_key)
    @device = device
    @public_key = public_key
  end

  def add_key
    @device.device_key.update_attributes active: false if @device.device_key.present?
    expired_at = Time.zone.now + Constants::PUBLIC_KEY_EXPIRE_WITHIN
    device_key = DeviceKey.create(public_key: @public_key.to_json, active: true, expired_at: expired_at)
    raise Proda::PublicKeyNotAcceptableError.new(device_key) if device_key.errors.any?
    @device.update_attributes device_key_id: device_key.id
  end

  def key_valid?
    @key_valid ||= PublicKeyFormatValidator.new(@public_key).valid?
  end

  def key_uniq?
    @key_uniq ||= DeviceKey.by_key(@public_key.to_json).exists?
  end
end
