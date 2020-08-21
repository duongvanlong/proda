require 'rails_helper'

RSpec.describe DeviceTokenService do
  let(:device) {create :device}
  subject {device.reload}
  before do
    DeviceTokenService.new(device).generate
  end

  it "token should be not empty" do
    expect(subject.access_token.class).to eq(String)
    expect(subject.access_token).not_to be_empty
  end

  it "token should be exactly characters" do
    expect(subject.access_token.length).to eq(32)
  end

  it "expired_at should in the future" do
    expect(subject.access_token_expired_at.to_i).to be >= Time.zone.now.to_i
  end

  it "expired_at should not more than 60 seconds from now" do
    expect(subject.access_token_expired_at - Time.zone.now).to be <= 60
  end
end
