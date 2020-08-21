require 'rails_helper'

describe "device activation routing", type: :routing do
  context "#create" do
    it "process activate device" do
      path = "/piaweb/api/b2b/v1/devices/faked_dvc_name/jwk"
      expect(put: path).to route_to(controller: "piaweb/api/b2b/v1/devices_activation", 
        action: "create", 
        dvc_name: "faked_dvc_name",
        format: :json)
    end
  end
end