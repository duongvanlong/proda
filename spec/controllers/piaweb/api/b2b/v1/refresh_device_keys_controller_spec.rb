require 'rails_helper'

RSpec.describe Piaweb::Api::B2b::V1::RefreshDeviceKeysController, type: :controller do
  shared_examples "respond error correctly" do
    it "response status 422" do
      expect(response).to have_http_status(400)
    end
    it "response body contains enough keys" do
      error_keys = %w(reference status url errors)
      expect(error_keys & respond_data.keys).to eq(error_keys)
    end
    it "status of response body is 422" do
      expect(respond_data["status"]).to eq(400)
    end
    it "errors of response body has enough keys" do
      error_detail_keys = %w(code message)
      respond_data["errors"].each do |error|
        expect(error.keys.flatten).to eq(error_detail_keys)
      end
    end
  end
  describe "PUT create" do
    let(:user) {create :user}
    let(:respond_data) {JSON.parse(response.body)}
    let(:error_codes) {respond_data["errors"].map{|err| err["code"]}}
    let(:device_key) {create :device_key}
    let(:device) {create :device_with_access_token, device_key_id: device_key.id}
    let(:valid_jwk) {
      {
        kty: "RSA",
        e: "AQAB",
        use: "sig",
        kid: "longdv",
        alg: "RS256",
        n: "m_yHg0gWuvoeq3KRlVf3KM0SC811klL9KHnOgur9hx4vL1qBTg2YNONG1BWBh84vMXoMc_1FEUA-fKmLY9IkkMBWsB_2LVjF2kKHEvPhnWV9OmJH-CJL_-A2XVgI1Z-qlhQLLPHavOqF3xfwDRGQDnQ_hZztORLel-wXxizfqVwwda1EYLkgua6V1Xj_GuWPnWfad0WqdXcg2oRJgTdEgL_P2zQ9AMJT5dPncFfDUJonxVOD7dW4wXjsxfk95jerGB3dE48PKOu_tywmK-7PeYHdkQYDjVC0AtM88tZPd7Ny8KKS29Mi5Hl3Rz1eVsi33vk_hg10TvoSEKi9pk5InQ"
      }
    }
    let(:valid_params) {{dvc_name: device.name, org_id: device.organization_id, format: :json}}
    context "have valid params" do
      let(:params) {valid_params}
      before do
        request.headers["Authorization"] = device.access_token
        post :create, params: params, body: valid_jwk.to_json
      end
      it "should response status 200" do
        expect(response).to have_http_status(200)
      end

      it "response in json format" do
        expect(JSON.parse(response.body).class).to eq(Hash)
      end

      it "should contains correct organization_id" do
        expect(respond_data["org_id"]).to eq(device.organization_id)
      end
      
      it "should contains correct deviceName" do
        expect(respond_data["deviceName"]).to eq(device.name)
      end
      
      it "should contains correct deviceStatus" do
        expect(respond_data["deviceStatus"]).to eq("ACTIVE")
      end
      
      it "should contains correct deviceStatus" do
        expect(respond_data["keyStatus"]).to eq("ACTIVE")
      end
      
      it "should contains correct keyExpiry" do
        expect(respond_data["keyStatus"]).not_to be_nil
      end
    end
    context "miss required params" do
      let(:params) {valid_params}
      before(:each) do
        post :create, params: params, body: valid_jwk.to_json
      end
      it_behaves_like "respond error correctly"
      it "should contain missing_required_params(RD1)" do
        expected_error_codes = %w(RD1)
        expect(error_codes).to match_array(expected_error_codes)
      end
    end

    context "have enough params" do
      let(:params) {valid_params}
      let(:private_key) {OpenSSL::PKey::RSA.new(2048)}

      context "public key has been used" do
        let(:public_key) {JSON.parse device_key.public_key}
        before(:each) do
          request.headers["Authorization"] = device.access_token
          post :create, params: params, body: valid_jwk.merge(n: public_key).to_json
        end
        it_behaves_like "respond error correctly"
        it "should contain public key used (PB8)" do
          expected_error_codes = %w(PB8)
          expect(error_codes).to match_array(expected_error_codes)
        end

      end

      context "key has been expired" do
        let(:device_key) {create :device_key, expired_at: Time.zone.now - 1.minutes}
        let(:device) {create :device_with_access_token, device_key_id: device_key.id}
        before(:each) do
          request.headers["Authorization"] = device.access_token
          post :create, params: params, body: valid_jwk.to_json
        end
        it "should contain public key expired (RD5)" do
          expected_error_codes = %w(RD5)
          expect(error_codes).to match_array(expected_error_codes)
        end
      end

      context "invalid organization id" do
        let(:params) {valid_params.merge(org_id: device.organization_id + 1)}
        before(:each) do
          request.headers["Authorization"] = device.access_token
          post :create, params: params, body: valid_jwk.to_json
        end
        it "should contain organization_id not match (RD6)" do
          expected_error_codes = %w(RD6)
          expect(error_codes).to match_array(expected_error_codes)
        end
      end

      context "invalid device name" do
        let(:params) {valid_params.merge(dvc_name: "faked")}
        before(:each) do
          request.headers["Authorization"] = device.access_token
          post :create, params: params, body: valid_jwk.to_json
        end
        it "should contain device not found (RD3)" do
          expected_error_codes = %w(RD3)
          expect(error_codes).to match_array(expected_error_codes)
        end
      end

      context "invalid token" do
        before(:each) do
          request.headers["Authorization"] = "faked"
          post :create, params: params, body: valid_jwk.to_json
        end
        it "should contain token invalid (RD7)" do
          expected_error_codes = %w(RD7)
          expect(error_codes).to match_array(expected_error_codes)
        end
      end

      context "access_token expired" do
        let(:device) {create :device_with_access_token, device_key_id: device_key.id, access_token_expired_at: Time.zone.yesterday}
        before(:each) do
          request.headers["Authorization"] = device.access_token
          post :create, params: params, body: valid_jwk.to_json
        end
        it "should contain token invalid (RD8)" do
          expected_error_codes = %w(RD8)
          expect(error_codes).to match_array(expected_error_codes)
        end
      end
    end
  end
end
