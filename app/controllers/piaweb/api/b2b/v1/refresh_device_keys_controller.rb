module Piaweb::Api::B2b::V1
  class RefreshDeviceKeysController < ::Piaweb::Api::B2b::BaseController
    before_action :validate_params
    def create
      public_key_service.add_key
      render json: ::Api::V1::DevicePresenter.new(@device.reload).as_json
    rescue Proda::PublicKeyNotAcceptableError => e
      errors = transform_device_errors(e.obj)
      response_errors(errors)
    end

    private
    def validate_params
      @validate_errors = []
      validate_headers
      validate_path_params
      validate_device
      validate_new_public_key
      validate_organization
      validate_access_token
      response_errors(@validate_errors, 400) and return false if @validate_errors.any?
    end

    def validate_headers
      unless access_token.present?
        @validate_errors << Constants::REFRESH_DEVICE_ERRORS[:missing_access_token]
      end 
    end

    def validate_path_params
      if [org_id, device_name].any?(&:nil?)
        @validate_errors << Constants::REFRESH_DEVICE_ERRORS[:missing_path_params]
      end
      @validate_errors << Constants::REFRESH_DEVICE_ERRORS[:device_not_found] unless device.present?
    end

    def validate_device
      if device.present?
        @validate_errors << Constants::REFRESH_DEVICE_ERRORS[:device_is_not_active] unless device.active?
        @validate_errors << Constants::REFRESH_DEVICE_ERRORS[:public_key_expired] if device.device_key.present? && device.device_key.expired?
      end
    end

    def validate_organization
      if device.present?
        @validate_errors << Constants::REFRESH_DEVICE_ERRORS[:organization_id_not_valid] unless device.organization_id == org_id
      end
    end

    def validate_access_token
      if device.present? && access_token.present?
        @validate_errors << Constants::REFRESH_DEVICE_ERRORS[:access_token_invalid] unless access_token == device.access_token
        @validate_errors << Constants::REFRESH_DEVICE_ERRORS[:access_token_expired] if device.access_token_expired?
      end
    end

    def validate_new_public_key
      validator = PublicKeyFormatValidator.new(public_key)
      unless validator.valid?
        @validate_errors += validator.errors.to_a
      end
    end

    def org_id
      params[:org_id].to_i
    end

    def device_name
      params[:dvc_name]
    end

    def device
      @device ||= Device.where(name: device_name).last
    end

    def public_key
      JSON.parse request.raw_post
    rescue
    end

    def access_token
      request.headers["Authorization"]
    end

    def public_key_service
      @public_key_service ||= PublicKeyService.new(device, public_key)
    end
  end
end

