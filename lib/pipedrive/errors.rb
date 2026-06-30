# frozen_string_literal: true

module Pipedrive
  class PipedriveError < StandardError
    attr_reader :code, :data, :http_method, :http_path

    def initialize(message = nil, code = nil, data = nil, http_method: nil, http_path: nil)
      super(message)
      @message = message
      @code = code
      @data = data
      @http_method = http_method
      @http_path = http_path
    end

    def message
      code_str = @code.nil? ? "" : "(Status #{@code}) "
      request_str = @http_method && @http_path ? " [#{@http_method.to_s.upcase} #{@http_path}]" : ""
      "#{code_str}#{@message}#{request_str}"
    end
  end

  # As documented at https://pipedrive.readme.io/docs/core-api-concepts-http-status-codes
  class SettingError < PipedriveError; end
  class AuthenticationError < PipedriveError; end
  class NotFoundError < PipedriveError; end
  class BadRequestError < PipedriveError; end
  class UnauthorizedError < PipedriveError; end
  class PaymentRequiredError < PipedriveError; end
  class ForbiddenError < PipedriveError; end
  class MethodNotAllowedError < PipedriveError; end
  class GoneError < PipedriveError; end
  class UnsupportedMediaTypeError < PipedriveError; end
  class UnprocessableEntityError < PipedriveError; end
  class TooManyRequestsError < PipedriveError; end
  class InternalServerError < PipedriveError; end
  class NotImplementedError < PipedriveError; end
  class ServiceUnavailableError < PipedriveError; end
  class UnkownAPIError < PipedriveError; end

  ERROR_CLASS_MAP = {
    "400" => BadRequestError,
    "401" => UnauthorizedError,
    "402" => PaymentRequiredError,
    "403" => ForbiddenError,
    "404" => NotFoundError,
    "405" => MethodNotAllowedError,
    "410" => GoneError,
    "415" => UnsupportedMediaTypeError,
    "422" => UnprocessableEntityError,
    "429" => TooManyRequestsError,
    "500" => InternalServerError,
    "501" => NotImplementedError,
    "503" => ServiceUnavailableError,
  }.freeze

  def raise_error(status, response, http_method: nil, http_path: nil)
    return if [200, 201].include?(status)

    message =
      [response.dig(:error), response.dig(:error_info)]
      .compact
      .join(". ")

    error_data =
      response
        .fetch(:data, {})
        .inspect
        .concat(response.fetch(:additional_data, {}).inspect)

    opts = { http_method: http_method, http_path: http_path }

    error_class = ERROR_CLASS_MAP[status.to_s]
    raise error_class.new(message, status, error_data, **opts) if error_class

    raise UnkownAPIError.new(message, status, error_data, **opts)
  end

  module_function :raise_error
end
