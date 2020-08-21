class JwtTokenValidator
  attr_reader :errors

  def initialize(jwt)
    @errors = []
    @jwt = jwt
  end

  def valid?
    validate_params
    validate_organization_id
    validate_device_name
    validate_issue_timestamp
    validate_expiration
    @errors.empty?
  end

  private

  def validate_params
    validate_header
    validate_body
  end

  def validate_header
    if !public_key_id.present? || !algorithm.present?
      @errors << Constants::JWT_ERRORS[:format_invalid]
    end
    @errors << Constants::JWT_ERRORS[:format_invalid] unless Constants::VALID_ALGORITHMS.include? algorithm
  end

  def validate_body
    keys = %w(iss sub aud iat exp)
    if keys.any?{|key| @jwt[key].blank?}
      @errors << Constants::JWT_ERRORS[:format_invalid]
    end
  end
  def validate_organization_id
    unless Organization.exists?(id: organization_id)
      @errors << Constants::JWT_ERRORS[:organization_id_not_matched]
    end
  end

  def validate_device_name
    unless Device.exists?(name: device_name)
      @errors << Constants::JWT_ERRORS[:device_not_found]
    end
  end

  def validate_issue_timestamp
    date = Time.at(issue_timestamp)
    @errors << Constants::JWT_ERRORS[:issue_timestamp_invalid] if date >= Time.zone.now
  rescue
    @errors << Constants::JWT_ERRORS[:issue_timestamp_format_invalid]
  end

  def validate_expiration
    date = Time.at(exp_timestamp)
    @errors << Constants::JWT_ERRORS[:exp_timestamp_expired] if date <= Time.zone.now
    @errors << Constants::JWT_ERRORS[:exp_timestamp_too_long] if date >= Time.zone.now + Constants::MAXIMUM_AUTHENTICATION_TOKEN_EXPIRATION
  rescue
    @errors << Constants::JWT_ERRORS[:exp_timestamp_format_invalid]
  end

  def public_key_id
    @jwt.header[:kid]
  end

  def algorithm
    @jwt.header[:alg]
  end

  def organization_id
    @jwt[:iss]
  end

  def device_name
    @jwt[:sub]
  end

  def provider
    @jwt[:aud]
  end

  def issue_timestamp
    @jwt[:iat]
  end

  def exp_timestamp
    @jwt[:exp]
  end
end
