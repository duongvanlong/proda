class Device < ApplicationRecord
  STATUS_ACTIVE_MAP = {"true" => "ACTIVE", "false" => "REGISTER"}

  belongs_to :organization
  belongs_to :user
  belongs_to :device_key, optional: true

  validates :name, uniqueness: true
  validates_length_of :name, minimum: 1, maximum: 255

  scope :by_code, ->(code) {where(code: code)}

  before_create :update_authentication_code


  def update_authentication_code
    self.code = get_uniq_code
    self.code_expired_at = Time.zone.now + Constants::CODE_EXPIRE_WITHIN
    self.code_used_at = nil
  end

  def status
    #don't care public key expired
    STATUS_ACTIVE_MAP[active?.to_s]
  end

  def active?
    device_key.present? && device_key.active?
  end

  def key_status
    device_key.try :status
  end

  def public_key_expired_at
    device_key.try :expired_at
  end

  def activation_code_expired?
    code_expired_at < Time.zone.now
  end

  def activation_code_used?
    !code_used_at.nil?
  end

  def access_token_expired?
    access_token.present? && access_token_expired_at < Time.zone.now
  end

  private

  def get_uniq_code
    new_code = generate_authentication_code
    #may loop infinitive but not handle now because the possibilty is very low
    until(Device.by_code(new_code).empty?)
      new_code = generate_authentication_code
    end
    new_code
  end

  def generate_authentication_code
    SecureRandom.urlsafe_base64(7)
  end
end
