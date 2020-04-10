require 'uri'
require 'net/http'

# Validates that the given string URL is not a dead host.
class BrokenLinkValidator < ActiveModel::EachValidator
  # Validates that a given link is not broken if the VALIDATE_BROKEN_LINKS env
  # var is set to a truthy value.
  #
  # @param [ActiveRecord] record The model instance to validate
  # @param [String] attribute The name of the attribute being validated
  # @param [Object] value The value being validated
  # @return [Boolean] Either true if the record is valid or false otherwise.
  def validate_each(record, attribute, value)
    # We only want to
    validate = ENV['VALIDATE_BROKEN_LINKS'].try(:downcase)
    return true unless %w(1 yes true).include?(validate)

    valid = false
    begin
      # Anything 4xx or 5xx will be treated as an error
      uri = URI(value)

      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = ENV['LINK_TIMEOUT'].to_i
      http.open_timeout = ENV['LINK_TIMEOUT'].to_i
      http.use_ssl = true if uri.port == 443

      response = http.start { |http| http.get(uri.to_s) }
      code = response.code.split(//).first
      valid = true unless ["4", "5"].include?(code)
    rescue StandardError
      valid = false
    end

    error = "the given URL seems to be broken!"
    record.errors.add(attribute, error) unless valid

    valid
  end
end
