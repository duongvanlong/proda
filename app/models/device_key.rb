class DeviceKey < ApplicationRecord
  KEY_STATUS_EXPIRED_MAP = {valid: "ACTIVE", expired: "EXPIRED", inactive: "INACTIVE"}
  validates :public_key, uniqueness: true
  validate :public_key_format
  validates :expired_at, presence: true

  scope :by_key, ->(key) {where(public_key: key)}
  scope :active, ->{where(active: true)}
  scope :not_expired, -> {where("public_key_expired_at >= ?", Time.zone.now)}
  scope :by_device, ->(device) {where(device_id: device)}

  def expired?
    expired_at < Time.zone.now
  end

  def status
    key = active? ? (expired? ? :expired : :valid) : :inactive
    KEY_STATUS_EXPIRED_MAP[key]
  end

  private
  def public_key_format
    if PublicKeyFormatValidator.new(public_key).valid?
      errors.add(:public_key, "format is not valid")
    end
  end
end

