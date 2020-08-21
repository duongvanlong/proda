class PublicKeyFormatValidator
  attr_accessor :errors
  def initialize(public_key)
    @errors = Set.new
    @public_key = public_key
  end

  def valid?
    unless @public_key.is_a? Hash
      @errors << Constants::PUBLIC_KEY_ERRORS[:not_json]
      return false
    end
    @public_key = @public_key.with_indifferent_access
    required_keys = %w(kty alg use kid n e)
    if (required_keys & @public_key.keys) != required_keys
      @errors << Constants::PUBLIC_KEY_ERRORS[:missing_keys]
      return false
    end
    if(@public_key.slice(*required_keys).values.any?(&:blank?))
      @errors << Constants::PUBLIC_KEY_ERRORS[:required_value_empty]
      return false
    end
    @errors << Constants::PUBLIC_KEY_ERRORS[:key_type_invalid] if @public_key[:kty] != "RSA"
    @errors << Constants::PUBLIC_KEY_ERRORS[:algorithm_invalid] unless Constants::VALID_ALGORITHMS.include? @public_key[:alg]
    @errors << Constants::PUBLIC_KEY_ERRORS[:key_use_invalid] if @public_key[:use] != "sig"
    @errors << Constants::PUBLIC_KEY_ERRORS[:encoding_invalid] if @public_key[:e] != "AQAB"
    @errors << Constants::PUBLIC_KEY_ERRORS[:key_size_invalid] if key_length < Constants::MINIMUM_KEY_SIZE
    @errors.empty?
  rescue StandardError => e
    # JSON::JWK::UnknownAlgorithm happen when kty is invalid
    # ArgumentError happen when e is invalid or n is invalid (ex: invalid base64)
    @errors << Constants::PUBLIC_KEY_ERRORS[:key_invalid]
    return false
  end

  def jwk
    @jwk ||= JSON::JWK.new(@public_key)
  end

  def key_length
    jwk.to_key.public_key.n.num_bytes  * 8
  end

end
