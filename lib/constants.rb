class Constants
  MINIMUM_KEY_SIZE = 2048
  CODE_EXPIRE_WITHIN = 1.minutes
  PUBLIC_KEY_EXPIRE_WITHIN = 84.days
  MAXIMUM_AUTHENTICATION_TOKEN_EXPIRATION = 1.minutes
  VALID_ALGORITHMS = %w(RS256 RS384 RS512).freeze
  JWT_PROVIDER = "https://proda.humanservices.gov.au".freeze
  VALID_GRANT_TYPE = "urn:ietf:params:oauth:grant-type:jwt-bearer".freeze
  UNKNOWN_ERROR = {code: "UNK", message: I18n.t("errors.unknown")}
  ACTIVATION_ERRORS = {
    device_not_found: {code: "DE0", message: I18n.t("errors.activation.device_not_found")},
    missing_params: {code: "DE1", message: I18n.t("errors.activation.missing_params")},
    organization_id_not_matched: {code: "DE2", message: I18n.t("errors.activation.organization_id_not_matched")},
    public_key_not_uniq: {code: "DE3", message: I18n.t("errors.activation.public_key_not_uniq")},
    public_key_not_valid: {code: "DE4", message: I18n.t("errors.activation.public_key_not_valid")},
    code_not_matched: {code: "DE5", message: I18n.t("errors.activation.code_not_matched")},
    code_expired: {code: "DE6", message: I18n.t("errors.activation.code_expired")},
    code_used: {code: "DE7", message: I18n.t("errors.activation.code_used")}
  }.freeze

  PUBLIC_KEY_ERRORS = {
    not_json: {code: "PB0", message: I18n.t("errors.public_key.not_json")},
    missing_keys: {code: "PB1", message: I18n.t("errors.public_key.missing_keys")},
    required_value_empty: {code: "PB2", message: I18n.t("errors.public_key.required_value_empty")},
    key_use_invalid: {code: "PB3", message: I18n.t("errors.public_key.key_use_invalid")},
    algorithm_invalid: {code: "PB4", message: I18n.t("errors.public_key.algorithm_invalid")},
    key_type_invalid: {code: "PB5", message: I18n.t("errors.public_key.key_type_invalid")},
    encoding_invalid: {code: "PB6", message: I18n.t("errors.public_key.encoding_invalid")},
    key_size_invalid: {code: "PB7", message: I18n.t("errors.public_key.key_size_invalid")},
    key_invalid: {code: "PB8", message: I18n.t("errors.public_key.key_invalid")}
  }.freeze

  JWT_ERRORS = {
    token_invalid: {code: "JW0", message: I18n.t("errors.jwt.token_invalid")},
    assertion_decode_error: {code: "JW1", message: I18n.t("errors.jwt.decode_error")},
    format_invalid: {code: "JW2", message: I18n.t("errors.jwt.format_invalid")},
    issue_timestamp_format_invalid: {code: "JW3", message: I18n.t("errors.jwt.issue_timestamp_format_invalid")},
    issue_timestamp_invalid: {code: "JW4", message: I18n.t("errors.jwt.issue_timestamp_invalid")},
    exp_timestamp_format_invalid: {code: "JW5", message: I18n.t("errors.jwt.issue_timestamp_format_invalid")},
    exp_timestamp_expired: {code: "JW6", message: I18n.t("errors.jwt.exp_timestamp_expired")},
    exp_timestamp_invalid: {code: "JW7", message: I18n.t("errors.jwt.issue_timestamp_format_invalid")},
    exp_timestamp_too_long: {code: "JW8", message: I18n.t("errors.jwt.exp_timestamp_too_long")},
    device_not_found: {code: "JW9", message: I18n.t("errors.activation.device_not_found")},
    organization_id_not_matched: {code: "JW10", message: I18n.t("errors.activation.organization_id_not_matched")},
    assertion_format_invalid: {code: "JW12", message: I18n.t("errors.jwt.assertion_format_invalid")},
  }.freeze

  ACTIVE_RECORD_ERRORS = {
    "devices.organization.error.blank" => {code: "AR1", message: I18n.t("errors.devices.organization.error.blank")},
    "devices.user.error.blank" => {code: "AR2", message: I18n.t("errors.devices.user.error.blank")},
    "devices.name.error.too_short.count" => {code: "AR3", message: I18n.t("errors.devices.name.error.too_short.count")},
    "devices.name.error.taken" => {code: "AR4", message: I18n.t("errors.devices.name.error.taken")},
    "device_keys.public_key.error.value" => {code: "AR5", message: I18n.t("errors.device_keys.public_key.error.value")}
  }.freeze

  AUTHENTICATION_ERRORS = {
    missing_required_params: {code: "AT1", message: I18n.t("errors.authentication.missing_required_params")},
    assertion_invalid: {code: "AT2", message: I18n.t("errors.authentication.assertion_invalid")},
    grant_type_invalid: {code: "AT3", message: I18n.t("errors.authentication.grant_type_invalid")},
    device_not_found: {code: "AT4", message: I18n.t("errors.authentication.device_not_found")},
    device_not_active: {code: "AT5", message: I18n.t("errors.authentication.device_not_active")},
    public_key_expired: {code: "AT6", message: I18n.t("errors.authentication.public_key_expired")}
  }.freeze
  REFRESH_DEVICE_ERRORS = {
    missing_access_token: {code: "RD1", message: I18n.t("errors.refresh_device.missing_access_token")},
    missing_path_params: {code: "RD2", message: I18n.t("errors.refresh_device.missing_path_params")},
    device_not_found: {code: "RD3", message: I18n.t("errors.refresh_device.device_not_found")},
    device_is_not_active: {code: "RD4", message: I18n.t("errors.refresh_device.device_is_not_active")},
    public_key_expired: {code: "RD5", message: I18n.t("errors.refresh_device.public_key_expired")},
    organization_id_not_valid: {code: "RD6", message: I18n.t("errors.refresh_device.organization_id_not_valid")},
    access_token_invalid: {code: "RD7", message: I18n.t("errors.refresh_device.access_token_invalid")},
    access_token_expired: {code: "RD8", message: I18n.t("errors.refresh_device.access_token_expired")}
  }.freeze
end
