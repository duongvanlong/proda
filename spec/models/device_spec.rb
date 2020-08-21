require 'rails_helper'

RSpec.describe Device, type: :model do
  context "model invalid" do
    let(:device) {build :slang_device, name: ""}
    it "should be invalid" do
      expect(device.valid?).to be_falsey
    end

    it "should have error missing organization" do
      device.valid?
      expect(device.errors.full_messages).to include("Organization must exist")
    end

    it "should have error missing user" do
      device.valid?
      expect(device.errors.full_messages).to include("User must exist")
    end

    it "should have error missing user" do
      device.valid?
      expect(device.errors.full_messages).to include("Name is too short (minimum is 1 character)")
    end
  end
  context "model valid" do
    let(:device) {create :device}
    it "code should be generated" do
      expect(device.code.class).to eq(String)
      expect(device.code).not_to be_empty
    end

    it "code expiration should be generated" do
      expect(device.code_expired_at.class).to eq(ActiveSupport::TimeWithZone)
    end

    it "code expiration should less than 60s" do
      expect(device.code_expired_at - Time.zone.now).to be <= 60
    end
    describe "#active?" do
      context "device key missing" do
        it "should return false" do
          expect(device.active?).to be_falsey
        end
      end
      context "device key exist" do
        context "but inactive" do
          let(:device_key) {create :inactive_device_key}
          let(:device) {create :device, device_key_id: device_key.id}
          it "should return false" do
            expect(device.active?).to be_falsey
          end
        end
        context "and valid" do
          let(:device_key) {create :device_key}
          let(:device) {create :device, device_key_id: device_key.id}
          it "should return true" do
            expect(device.active?).to be_truthy
          end
        end
      end
    end
    describe "#status" do
      context "device key missing" do
        it "should return register" do
          expect(device.status).to eq("REGISTER")
        end
      end
      context "device key exist" do
        context "but inactive" do
          let(:device_key) {create :inactive_device_key}
          let(:device) {create :device, device_key_id: device_key.id}
          it "should return register" do
            expect(device.status).to eq("REGISTER")
          end
        end
        context "and valid" do
          let(:device_key) {create :device_key}
          let(:device) {create :device, device_key_id: device_key.id}
          it "should return active" do
            expect(device.status).to eq("ACTIVE")
          end
        end
      end
    end
    describe "#key_status" do
      context "device key missing" do
        it "should return false" do
          expect(device.key_status).to be_nil
        end
      end
      context "device key exist" do
        context "but expired" do
          let(:device_key) {create :expired_device_key}
          let(:device) {create :device, device_key_id: device_key.id}
          it "should return expired" do
            expect(device.key_status).to eq("EXPIRED")
          end
        end
        context "but inactive" do
          let(:device_key) {create :inactive_device_key}
          let(:device) {create :device, device_key_id: device_key.id}
          it "should return inactive" do
            expect(device.key_status).to eq("INACTIVE")
          end
        end
        context "and valid" do
          let(:device_key) {create :device_key}
          let(:device) {create :device, device_key_id: device_key.id}
          it "should return active" do
            expect(device.key_status).to eq("ACTIVE")
          end
        end
      end
    end
  end

end
