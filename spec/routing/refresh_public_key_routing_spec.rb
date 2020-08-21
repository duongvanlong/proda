require 'rails_helper'

describe "refresh device routing", type: :routing do
  context "#create" do
    it "process activate device" do
      path = "/piaweb/api/b2b/v1/orgs/1/devices/dvl_device/jwk"
      expect(put: path).to route_to(controller: "piaweb/api/b2b/v1/refresh_device_keys", 
        action: "create", format: :json, org_id: "1", dvc_name: "dvl_device")
    end
  end
end