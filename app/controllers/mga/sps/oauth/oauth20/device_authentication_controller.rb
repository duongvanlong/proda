module Mga::Sps::Oauth::Oauth20
  class DeviceAuthenticationController <  ActionController::Base
    skip_before_action :verify_authenticity_token
    respond_to :json

    before_action :validate_missing_params
    before_action :validate_grant_type
    before_action :validate_device
    before_action :validate_assertion

    def create
      DeviceTokenService.new(device).generate
      # don't know what status to update to device, so i skipped this step
      result = {
        token_type: "bearer",
        access_token: device.access_token,
        expires_in: expires_in(device.access_token_expired_at),
        key_expiry: expires_in(device_key.expired_at)
      }
      result.merge!(scope: params[:scope]) if params[:scope].present?
      render json: result
    end

    private

    def expires_in(expired_at)
      (expired_at - Time.zone.now).floor
    end
    def assertion
      params[:assertion]
    end

    def device_key
      @device_key ||= device.device_key
    end

    def public_key
      @public_key ||= JSON::JWK.new(proda_public_key).to_key
    end

    def proda_public_key
      @proda_public_key ||= JSON.parse(device_key.public_key)
    end

    def device
      @device ||= Device.where(name: params[:client_id]).last
    end

    def validate_missing_params
      required_param_keys = %w(grant_type assertion client_id)
      required_params = params.slice *required_param_keys
      if (required_param_keys & required_params.keys) != required_param_keys || required_params.values.any?(:blank?)
        response_error Constants::AUTHENTICATION_ERRORS[:missing_required_params]
      end
    end

    def validate_assertion
      @jwt = JSON::JWT.decode assertion, public_key, proda_public_key["alg"].to_sym
      validator = JwtTokenValidator.new(@jwt)
      unless validator.valid?
        # response_error(Constants::AUTHENTICATION_ERRORS[:assertion_invalid])
        response_error(validator.errors.first)
      end
    rescue JSON::JWT::InvalidFormat => e
      response_error Constants::JWT_ERRORS[:assertion_format_invalid]
    rescue JSON::JWS::VerificationFailed => e
      response_error Constants::JWT_ERRORS[:assertion_decode_error]
    rescue => e
      response_error Constants::UNKNOWN_ERROR
    end

    def validate_grant_type
      if params[:grant_type] != Constants::VALID_GRANT_TYPE
        response_error(Constants::AUTHENTICATION_ERRORS[:grant_type_invalid])
      end
    end

    def validate_device
      response_error(Constants::AUTHENTICATION_ERRORS[:device_not_found]) and return unless device.present?
      response_error(Constants::AUTHENTICATION_ERRORS[:device_not_active]) and return unless device.active?
      response_error(Constants::AUTHENTICATION_ERRORS[:public_key_expired]) and return if device_key.expired?
    end

    def response_error(error, status = 400)
      response_data = {
        error: error[:code],
        error_description: error[:message]
      }
      render json: response_data, status: status
    end
  end
end
# Invalid token in request
# Token Signature not Valid
# Token TTL too long
# Token is Expired
# Device not Active
# Unknown Error
