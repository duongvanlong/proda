FactoryBot.define do
  factory :device_key do
    public_key {
      {
        kty: "RSA",
        e: "AQAB",
        use: "sig",
        kid: "longdv",
        alg: "RS256",
        n: "5AkULjQ8vlWpb3qNpiCAaPyPISJ9BMq_kPCf8Wc_cI5YfVrtJD5K0eolF9NfWIpFNp0EbTOz9oSiv-846yCJdJebAez-7b6v78We9BvdJLDLsR2U_2ZKYCTaYvB21Ya-55_-j0n3mUaNOCWSlpkD70lCP2h2oM3NoJRFn98OA8uP-i_y2WI0cHIEA-KxiWyE0DWO_NWZNHqL6nFm7TUXLEnN0CPBNzfkflCa0ZQNiYOowwzAqzKwaA6tMd7gDDX5CS95nAllZppTaR_NJngpXF428-IQnw5oPh7GF-CyLJCrCBWlke5nYDqWcx3faxDxP3S-eYZM5pX775ksIoldYw"
      }.to_json
    }
    expired_at { Time.zone.now + 10.days }
    active {true}
  end

  factory :expired_device_key, class: DeviceKey do
    public_key {
      {
        kty: "RSA",
        e: "AQAB",
        use: "sig",
        kid: "longdv",
        alg: "RS256",
        n: "5AkULjQ8vlWpb3qNpiCAaPyPISJ9BMq_kPCf8Wc_cI5YfVrtJD5K0eolF9NfWIpFNp0EbTOz9oSiv-846yCJdJebAez-7b6v78We9BvdJLDLsR2U_2ZKYCTaYvB21Ya-55_-j0n3mUaNOCWSlpkD70lCP2h2oM3NoJRFn98OA8uP-i_y2WI0cHIEA-KxiWyE0DWO_NWZNHqL6nFm7TUXLEnN0CPBNzfkflCa0ZQNiYOowwzAqzKwaA6tMd7gDDX5CS95nAllZppTaR_NJngpXF428-IQnw5oPh7GF-CyLJCrCBWlke5nYDqWcx3faxDxP3S-eYZM5pX775ksIoldYw"
      }.to_json
    }
    expired_at { Time.zone.now - 30.seconds }
    active {true}
  end

  factory :inactive_device_key, class: DeviceKey do
    public_key {
      {
        kty: "RSA",
        e: "AQAB",
        use: "sig",
        kid: "longdv",
        alg: "RS256",
        n: "5AkULjQ8vlWpb3qNpiCAaPyPISJ9BMq_kPCf8Wc_cI5YfVrtJD5K0eolF9NfWIpFNp0EbTOz9oSiv-846yCJdJebAez-7b6v78We9BvdJLDLsR2U_2ZKYCTaYvB21Ya-55_-j0n3mUaNOCWSlpkD70lCP2h2oM3NoJRFn98OA8uP-i_y2WI0cHIEA-KxiWyE0DWO_NWZNHqL6nFm7TUXLEnN0CPBNzfkflCa0ZQNiYOowwzAqzKwaA6tMd7gDDX5CS95nAllZppTaR_NJngpXF428-IQnw5oPh7GF-CyLJCrCBWlke5nYDqWcx3faxDxP3S-eYZM5pX775ksIoldYw"
      }.to_json
    }
    expired_at { Time.zone.now + 30.seconds }
    active {false}
  end
end
