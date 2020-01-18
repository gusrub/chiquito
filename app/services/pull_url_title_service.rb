require 'net/http'
require 'open-uri'

# Pulls the page title from a given URL
class PullUrlTitleService

  # @return [Array<string>] A list of errors if the service failed to perform.
  attr_reader :errors

  # @return [Array<string>] A list of useful messages that may be returned by
  #   the service for informational or debugging purposes
  attr_reader :messages

  # @return [Object] The output object of this service in case it returns
  #   anything at all
  attr_reader :output

  # @return [String] The URL object to pull data from
  attr_reader :url

  # Initializes a new instance of the service.
  #
  # @param [ShortUrl] The short URL object to pull data from
  def initialize(url)
    @url = url
    @errors = []
    @messages = []
  end

  # Performs the action that this service is defined to do and returns a boolean
  # response indicating whether it succeeded or not.
  #
  # @return [Boolean] Whether the service succeeded in completing its action or
  #   not.
  def perform
    reinitialize

    begin
     @output = pull_title
     @messages << "Tried to pull title from #{url} but it seems to be empty" if output.blank?
    rescue StandardError => e
      handle_error(e)
    end
    @errors.empty?
  end

  private

  # Resets the service status
  def reinitialize
    @errors.clear
    @messages.clear
    @output = nil
  end

  # Pulls the title tag from a given URL if it has one.
  #
  # @return [string] The short URL title, if any.
  def pull_title
    request = open(URI(url), read_timeout: ENV['TITLE_URL_TIMEOUT'].to_i)
    doc = Nokogiri::HTML::Document.parse(request.read)
    doc.title
  end


  # Handles any error that is raised throughout the service and fills the errors
  # collection accordingly.
  #
  # @param [StandardError] error Any type of error to be handled.
  def handle_error(error)
    case error.class.name
    when SocketError.name, Errno::ECONNREFUSED.name, Errno::ENOENT.name
      @errors << 'Could not connect to host'
    else
      Rails.logger.error("[error: #{log_id}] #{error.message}")
      @errors << "A problem has ocurred in our systems and we have been notified. Please report it with the following code: '#{log_id}'"
    end
  end

  # Generates a dummy log ID based on an hex random string
  #
  # @param [Integer] max_length max number of digits to expose. Defaults to 7.
  # @return [String] The log ID.
  def log_id(max_length: 7)
    log_id = SecureRandom.hex.first(max_length)
  end
end
