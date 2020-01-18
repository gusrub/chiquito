require 'uri'

# Validates that the given string is a valid URL containing the procol and such.
class RegularUrlValidator < ActiveModel::EachValidator
  # Validates a string as a valid URL
  #
  # @param [ActiveRecord] record The model instance to validate
  # @param [String] attribute The name of the attribute being validated
  # @param [Object] value The value being validated
  # @return [Boolean] Either true if the record is valid or false otherwise.
  def validate_each(record, attribute, value)
    valid = false
    begin
      uri = URI.parse(value)
      valid = uri.host.present?
    rescue URI::InvalidURIError
      valid = false
    end

    error = "you must provide a valid URL"
    record.errors.add(attribute, error) unless valid

    valid
  end
end
