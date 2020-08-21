require 'rails_helper'

describe "authentication routing", type: :routing do
  context "#create" do
    it "process activate device" do
      path = "/mga/sps/oauth/oauth20/token"
      expect(post: path).to route_to(controller: "mga/sps/oauth/oauth20/device_authentication", 
        action: "create", format: :json)
    end
  end
end