# Validates that the given string is a valid custom short URL. This is used
# for cases when the user defines their custom URL string.
class CustomUrlValidator < ActiveModel::EachValidator
  # Validates a string as a valid short URL
  #
  # @param [ActiveRecord] record The model instance to validate
  # @param [String] attribute The name of the attribute being validated
  # @param [Object] value The value being validated
  # @return [Boolean] Either true if the record is valid or false otherwise.
  def validate_each(record, attribute, value)
    return true if (value =~ /[^a-zA-Z0-9]/).nil? || record.send(attribute.to_sym).blank?
    error = "can only contain alphanumeric (A-Z, a-z, 0-9) values"
    record.errors.add(attribute, error)
    false
  end
end
