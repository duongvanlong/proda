require 'rails_helper'

RSpec.describe PublicKeyFormatValidator do
  let(:valid_jwk) {
    {
      "kty": "RSA",
      "e": "AQAB",
      "use": "sig",
      "kid": "device_id",
      "alg": "RS256",
      "n": "haeYzaftiAtl2LTFOd7ew1kKxR4Ieyn-j9z1dgNitZM8mVT1vVs7OhLgp_QAqGKZy25SY8KxxRVkVua5OOEkIyMRxHnHntbionWmvo84zwdssnkuNLSKjmDu6xEoed2-PUb4HDxJFPkyK6tKLg9YIHWGdwsNcDCupCe7I7mncfb27gnFrCw1hutrdsN-nUbyPv_SpOlQtkWHj_wG35fEgXgk3ce8FpUtX_6eUmEhn7aMy7t2gYxJJiul75FqZ6T76sixMw4y1VqmkRKL-jpDCltexhm_cD0-tUocvhjvzrxCg0oqhbIKS29EOpseaqFHUsa3fkAKqGuQFmD-1WgJzQ"
    }
  }
  context "not json" do
    let(:public_key) {Object.new}
    subject {PublicKeyFormatValidator.new(public_key)}
    it "should return false" do
      expect(subject.valid?).to be_falsey
      exptected_error_codes = %w(PB0)
      expect(subject.errors.map{|err| err[:code]}.flatten).to match_array(exptected_error_codes)
    end
  end

  context "is json" do

    context "correct key" do
      let(:public_key) {valid_jwk}
      subject {PublicKeyFormatValidator.new(public_key)}
      it "should return true" do
        expect(subject.valid?).to be_truthy
        exptected_errors = []
        expect(subject.errors).to match_array(exptected_errors)
      end
    end

    context "missing keys" do
      let(:public_key) {{}}
      subject {PublicKeyFormatValidator.new(public_key)}
      it "should return false" do
        expect(subject.valid?).to be_falsey
        exptected_error_codes = %w(PB1)
        expect(subject.errors.map{|err| err[:code]}.flatten).to match_array(exptected_error_codes)
      end
    end

    context "has empty value" do
      let(:public_key) {valid_jwk.merge(n: nil)}
      subject {PublicKeyFormatValidator.new(public_key)}
      it "should return false" do
        expect(subject.valid?).to be_falsey
        exptected_error_codes = %w(PB2)
        expect(subject.errors.map{|err| err[:code]}.flatten).to match_array(exptected_error_codes)
      end
    end

    context "key use invalid" do
      let(:public_key) {valid_jwk.merge(use: "faked")}
      subject {PublicKeyFormatValidator.new(public_key)}
      it "should return false" do
        expect(subject.valid?).to be_falsey
        exptected_error_codes = %w(PB3)
        expect(subject.errors.map{|err| err[:code]}.flatten).to match_array(exptected_error_codes)
      end
    end

    context "algorithm invalid" do
      let(:public_key) {valid_jwk.merge(alg: "faked")}
      subject {PublicKeyFormatValidator.new(public_key)}
      it "should return false" do
        expect(subject.valid?).to be_falsey
        exptected_error_codes = %w(PB4)
        expect(subject.errors.map{|err| err[:code]}.flatten).to match_array(exptected_error_codes)
      end
    end

    context "key type invalid" do
      let(:public_key) {valid_jwk.merge(kty: "faked")}
      subject {PublicKeyFormatValidator.new(public_key)}
      it "should return false" do
        expect(subject.valid?).to be_falsey
        exptected_error_codes = %w(PB5 PB8)
        expect(subject.errors.map{|err| err[:code]}.flatten).to match_array(exptected_error_codes)
      end
    end

    context "encoding invalid" do
      let(:public_key) {valid_jwk.merge(e: "faked")}
      subject {PublicKeyFormatValidator.new(public_key)}
      it "should return false" do
        expect(subject.valid?).to be_falsey
        exptected_error_codes = %w(PB6 PB8)
        expect(subject.errors.map{|err| err[:code]}.flatten).to match_array(exptected_error_codes)
      end
    end

    context "key size invalid" do
      let(:public_key) {valid_jwk.merge(n: OpenSSL::PKey::RSA.generate(256).public_key.to_jwk[:n])}
      subject {PublicKeyFormatValidator.new(public_key)}
      it "should return false" do
        expect(subject.valid?).to be_falsey
        exptected_error_codes = %w(PB7)
        expect(subject.errors.map{|err| err[:code]}.flatten).to match_array(exptected_error_codes)
      end
    end

    context "key invalid" do
      let(:public_key) {valid_jwk.merge(n: "faked")}
      subject {PublicKeyFormatValidator.new(public_key)}
      it "should return false" do
        expect(subject.valid?).to be_falsey
        exptected_error_codes = %w(PB8)
        expect(subject.errors.map{|err| err[:code]}.flatten).to match_array(exptected_error_codes)
      end
    end
  end
end
