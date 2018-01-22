class ApiResponseCode
  AUTH_ERROR         = 'auth_error'
  AUTH_SOCIAL_ERROR  = 'auth_social_error'
  UNAUTHORIZED_ERROR = 'unauthorized_error'
  VALIDATION_ERROR   = 'validation_error'
  PAYMENT_ERROR      = 'payment_error'
  NOT_FOUND_ERROR    = 'not_found_error'
  SERVER_ERROR       = 'server_error'
  RESET_PASS_ERROR   = 'reset_pass_error'

  def self.all
    {
      AUTH_ERROR         => 'User password/login is not valid',
      AUTH_SOCIAL_ERROR  => 'User social login failed',
      UNAUTHORIZED_ERROR => 'User is not authorized',
      VALIDATION_ERROR   => 'Validation error',
      PAYPAL_ERROR       => 'Paypal error',
      NOT_FOUND_ERROR    => 'Record not found',
      SERVER_ERROR       => 'Internal server error',
      RESET_PASS_ERROR   => 'Reset password error',
    }
  end
end
