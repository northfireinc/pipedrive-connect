# frozen_string_literal: true

module Pipedrive
  module Util
    def self.serialize_response(response, symbolize_names: true, http_method: nil, http_path: nil)
      if response.status == 204
        return {} unless Pipedrive.treat_no_content_as_not_found

        Pipedrive.raise_error(404, { error: "HTTP 204 status code received. No content" },
                              http_method: http_method, http_path: http_path)
      end

      json_body = JSON.parse(response.body, symbolize_names: symbolize_names)

      if response.success?
        json_body
      else
        Pipedrive.raise_error(response.status, json_body, http_method: http_method, http_path: http_path)
      end
    end

    def self.debug(message)
      Pipedrive.logger&.debug(message) if Pipedrive.debug
    end
  end
end
