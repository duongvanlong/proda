module Piaweb::Api::B2b::V1
  class DevicesActivationController < ::Piaweb::Api::B2b::BaseController
    before_action :get_device
    before_action :validate_params

    def create
      public_key_service.add_key
      @device.code_used_at = Time.zone.now
      @device.save!
      render json: ::Api::V1::DevicePresenter.new(@device.reload).as_json
    rescue Proda::PublicKeyNotAcceptableError => e
      errors = transform_device_errors(e.obj)
      response_errors(errors)
    end

    def get_device
      @device = Device.where(name: dvc_name).first
      respond_device_not_found and return false unless @device.present?
    end

    private
    def dvc_name
      params[:dvc_name]
    end

    def activation_code
      params[:otac]
    end

    def public_key
      JSON.parse params[:key].to_s
    rescue
    end

    def organization_id
      params[:orgId].to_i
    end

    def respond_device_not_found
      response_errors([Constants::ACTIVATION_ERRORS[:device_not_found]], 404)
    end

    def validate_params
      @validate_errors ||= []
      validate_missing_params
      validate_activation_code
      validate_public_key_format
      validate_public_key_uniqueness
      validate_organization
      response_errors(@validate_errors) if @validate_errors.any?
    end

    def validate_missing_params
      @validate_errors << Constants::ACTIVATION_ERRORS[:missing_params] if [activation_code, public_key, organization_id].any?(&:nil?)
    end

    def validate_organization
      @validate_errors << Constants::ACTIVATION_ERRORS[:organization_id_not_matched] if organization_id != @device.organization_id
    end

    def validate_public_key_uniqueness
      @validate_errors << Constants::ACTIVATION_ERRORS[:public_key_not_uniq] if public_key_service.key_uniq?
    end

    def validate_public_key_format
      @validate_errors << Constants::ACTIVATION_ERRORS[:public_key_not_valid] unless public_key_service.key_valid?
    end

    def validate_activation_code
      @validate_errors << Constants::ACTIVATION_ERRORS[:code_not_matched] if activation_code != @device.code
      @validate_errors << Constants::ACTIVATION_ERRORS[:code_expired] if @device.code.present? && @device.activation_code_expired?
      @validate_errors << Constants::ACTIVATION_ERRORS[:code_used] if @device.code.present? && @device.activation_code_used?
    end

    def public_key_service
      @public_key_service ||= PublicKeyService.new(@device, public_key)
    end
  end
end
