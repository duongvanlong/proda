require 'rails_helper'

RSpec.describe Mga::Sps::Oauth::Oauth20::DeviceAuthenticationController, type: :controller do
  shared_examples "respond error correctly" do
    it "response status 400" do
      expect(response).to have_http_status(400)
    end
    it "response body contains enough keys" do
      error_keys = %w(error error_description)
      expect(error_keys & respond_data.keys).to eq(error_keys)
    end
  end
  describe "#POST" do
    let(:user) {create :user}
    let(:respond_data) {JSON.parse(response.body)}
    let(:default_device_name) {"longdv"}
    let(:jw_issue_time) {Time.zone.now.to_i}
    let(:jw_expires_time) {(Time.zone.now + 1.minutes).to_i}
    let(:jwt) {
      json_jwt = JSON::JWT.new(iss: user.organization_id, sub: default_device_name, aud: "http://www.google.com", iat: jw_issue_time, exp: jw_expires_time)
      json_jwt.header["alg"] = "RS256"
      json_jwt.header["kid"] = "demo key"
      json_jwt
    }
    let(:private_key){OpenSSL::PKey::RSA.new(File.read("spec/support/pri.txt"))}
    let(:valid_params) {
      {
        format: :json,
        grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
        client_id: device.name,
        scope: "TBA",
        assertion: jwt.sign(private_key, :RS256).to_s
      }
    }

    context "device inactive" do
      let(:device_key) {create :inactive_device_key}
      let(:device) {create :device, user: user, device_key_id: device_key.id, name: default_device_name}
      let(:params) {valid_params}

      before do
        post :create, params: params
      end

      it_behaves_like "respond error correctly"
      it "should respond error device_not_active(AT5)" do
        expect(respond_data["error"]).to eq("AT5")
        expect(respond_data["error_description"]).to eq("Device not Active")
      end
    end

    context "device active" do

      before(:each) do
        post :create, params: params
      end
      context "public key expired" do
        let(:device_key) {create :expired_device_key}
        let(:device) {create :device, user: user, device_key_id: device_key.id}
        let(:params) {valid_params}

        it_behaves_like "respond error correctly"
        it "should respond error public_key_expired(AT6)" do
          expect(respond_data["error"]).to eq("AT6")
        end
      end
      context "has valid public key" do
        let(:device_key) {create :device_key}
        let(:device) {create :device, user: user, organization_id: user.organization_id, device_key_id: device_key.id, name: default_device_name}

        context "and valid params" do
          let(:params) {valid_params}
          it "response status 200" do
            expect(response).to have_http_status(200)
          end

          it "response a hash" do
            expect(respond_data.class).to eq(Hash)
          end
          describe "contain valid token" do
            it "contains token type has value is bearer" do
              expect(respond_data["token_type"]).to eq("bearer")
            end

            it "contains access_token is a string has length 32" do
              expect(respond_data["access_token"].class).to eq(String)
              expect(respond_data["access_token"].length).to be 32
            end

            it "contains expires_in" do
              expect(respond_data["expires_in"].class).to eq(Integer)
            end

            it "contains key_expiry" do
              expect(respond_data["key_expiry"].class).to eq(Integer)
            end
          end
        end

        context "but missing params" do
          let(:params) {valid_params.slice(:format, :assertion, :client_id)} #missing grant_type
          it_behaves_like "respond error correctly"
          it "should respond missing_required_params (AT1)" do
            expect(respond_data["error"]).to eq("AT1")
          end
        end

        context "but have grant_type invalid" do
          let(:params) {valid_params.merge(grant_type: "faked")}
          it_behaves_like "respond error correctly"
          it "should respond grant_type_invalid (AT3)" do
            expect(respond_data["error"]).to eq("AT3")
          end
        end

        context "but have assertion invalid" do
          let(:private_key) {OpenSSL::PKey::RSA.new(2048)}
          let(:params) {valid_params}
          it_behaves_like "respond error correctly"
          it "should respond decode error (JW1)" do
            expect(respond_data["error"]).to eq("JW1")
            expect(respond_data["error_description"]).to eq("Token Signature not valid")
          end
        end

        context "but have device name invalid" do
          let(:device) {create :device, user: user, organization_id: user.organization_id, device_key_id: device_key.id, name: "not default"}
          let(:params) {valid_params}
          it_behaves_like "respond error correctly"
          it "should respond device not found (JW9)" do
            expect(respond_data["error"]).to eq("JW9")
          end
        end

        context "jwt token issue time invalid" do
          let(:jw_issue_time) {(Time.zone.now + 1.minutes).to_i}
          let(:params) {valid_params}
          it "should respond issue time invalid (JW4)" do
            expect(respond_data["error"]).to eq("JW4")
          end
        end

        context "jwt token expired" do
          let(:jw_expires_time) {(Time.zone.now - 1.minutes).to_i}
          let(:params) {valid_params}
          it "should respond expires time invalid (JW6)" do
            expect(respond_data["error"]).to eq("JW6")
            expect(respond_data["error_description"]).to eq("Token is Expired")
          end
        end

        context "token TTL too long" do
          let(:jw_expires_time) {(Time.zone.now + 5.minutes).to_i}
          let(:params) {valid_params}
          it "should respond TTL too long (JW8)" do
            expect(respond_data["error"]).to eq("JW8")
            expect(respond_data["error_description"]).to eq("Token TTL too long")
          end
        end
        context "Invalid token in request" do
          let(:params) {valid_params.merge(assertion: "faked")}
          it "should respond invalid token format (JW12)" do
            expect(respond_data["error"]).to eq("JW12")
            expect(respond_data["error_description"]).to eq("Invalid token in request")
          end
        end
      end
    end
  end
end
