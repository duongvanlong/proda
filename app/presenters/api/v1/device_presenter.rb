class Api::V1::DevicePresenter
  def initialize(device)
    @device = device
  end

  def as_json
    {
      org_id: @device.organization_id,
      deviceName: @device.name,
      deviceStatus: @device.status,
      keyStatus: @device.key_status,
      keyExpiry: I18n.l(@device.public_key_expired_at)
    }
  end
end
