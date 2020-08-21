module Piaweb::Api::B2b
  class BaseController < ActionController::Base
    skip_before_action :verify_authenticity_token
    respond_to :json

    protected

    def transform_device_errors(object)
      build_string(object.errors.details, object.class.table_name).flatten.map do |error_string|
        Constants::ACTIVE_RECORD_ERRORS[error_string] || error_string
      end
    end

    def build_string(hash, prefix = "")
      hash.map do |key, value|
        value = if value.is_a?(Hash)
          [prefix, key.to_s, build_string(value)].join(".")
        elsif value.is_a?(Array)
          value.map{|val| [prefix, key.to_s, build_string(val)].join(".")}
        else
          key
        end
      end
    end

    def response_errors(errors, status=422)
      respond_data = {
        reference: "N/A",
        status: status,
        url: request.env['PATH_INFO'],
        errors: errors
      }
      render json: respond_data, status: status
    end
  end
end
