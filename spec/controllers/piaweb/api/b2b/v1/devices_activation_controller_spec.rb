require 'rails_helper'

RSpec.describe Piaweb::Api::B2b::V1::DevicesActivationController, type: :controller do
  shared_examples "respond error correctly" do
    it "response status 422" do
      expect(response).to have_http_status(422)
    end
    it "response body contains enough keys" do
      error_keys = %w(reference status url errors)
      expect(error_keys & respond_data.keys).to eq(error_keys)
    end
    it "status of response body is 422" do
      expect(respond_data["status"]).to eq(422)
    end
    it "errors of response body has enough keys" do
      error_detail_keys = %w(code message)
      respond_data["errors"].each do |error|
        expect(error.keys.flatten).to eq(error_detail_keys)
      end
    end
  end
  let(:valid_jwk) {
    {
      kty: "RSA",
      e: "AQAB",
      use: "sig",
      kid: "longdv",
      alg: "RS256",
      n: "5AkULjQ8vlWpb3qNpiCAaPyPISJ9BMq_kPCf8Wc_cI5YfVrtJD5K0eolF9NfWIpFNp0EbTOz9oSiv-846yCJdJebAez-7b6v78We9BvdJLDLsR2U_2ZKYCTaYvB21Ya-55_-j0n3mUaNOCWSlpkD70lCP2h2oM3NoJRFn98OA8uP-i_y2WI0cHIEA-KxiWyE0DWO_NWZNHqL6nFm7TUXLEnN0CPBNzfkflCa0ZQNiYOowwzAqzKwaA6tMd7gDDX5CS95nAllZppTaR_NJngpXF428-IQnw5oPh7GF-CyLJCrCBWlke5nYDqWcx3faxDxP3S-eYZM5pX775ksIoldYw"
    }
  }
  describe "PUT create" do
    let(:user) {create :user}
    let(:respond_data) {JSON.parse(response.body)}
    context "device not exist" do
      it "should respond 404" do
        put :create, params: {dvc_name: "faked", format: :json}
        expect(response).to have_http_status(404)
      end
    end
    context "device exist" do
      let(:device) {create :device}
      context "missing parameter" do
        before do
          put :create, params: {dvc_name: device.name, format: :json}
        end
        it "return error DE1, DE2, DE4, DE5" do
          expect(respond_data["errors"].length).to eq(4)
          expected_error_codes = %w(DE1 DE2 DE4 DE5)
          expect(respond_data["errors"].map{|err| err["code"]}).to match_array(expected_error_codes)
        end
      end

      context "have parameters" do
        let(:device) {create :device, name: "dvl"}
        let(:params) {{dvc_name: device.name, format: :json,
            orgId: device.organization_id, otac: device.code, key: valid_jwk.merge(device_id: device.name).to_json}}

        context "with valid params" do
          before do
            put :create, params: params
          end
          it "return successful" do
            expect(response).to be_successful
            expect(JSON.parse(response.body)).to eq({
              "deviceName" => "dvl",
              "deviceStatus" => "ACTIVE",
              "keyExpiry" => I18n.l(device.reload.public_key_expired_at),
              "keyStatus" => "ACTIVE",
              "org_id" => device.organization_id
            })
          end
          it "device activation code should be used" do
            expect(device.reload.activation_code_used?).to be_truthy
          end
        end

        context "with wrong activation code" do
          before do
            put :create, params: params.merge(otac: "faked")
          end
          it_behaves_like "respond error correctly"
          it "return error DE5" do
            expected_error_codes = %w(DE5)
            expect(respond_data["errors"].map{|err| err["code"]}).to match_array(expected_error_codes)
          end
        end

        context "with wrong organization_id" do
          before do
            put :create, params: params.merge(orgId: device.organization_id + 1)
          end
          it_behaves_like "respond error correctly"
          it "return error DE2" do
            expected_error_codes = %w(DE2)
            expect(respond_data["errors"].map{|err| err["code"]}).to match_array(expected_error_codes)
          end
        end
        context "with invalid public key" do
          before do
            put :create, params: params.merge(key: {content: "faked"}.to_json)
          end
          it_behaves_like "respond error correctly"
          it "return error DE4" do
            expected_error_codes = %w(DE4)
            expect(respond_data["errors"].map{|err| err["code"]}).to match_array(expected_error_codes)
          end
        end
      end
    end
  end
end
