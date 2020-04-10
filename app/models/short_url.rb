# Represents an object that stores URL information and its short counterpart
class ShortUrl < ApplicationRecord

  # Defines our base62 available character set for generating short URLs
  ALPHABET = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".split(//)

  # Defines the maximum length of a short URL
  CUSTOM_MAX_LENGTH = 25

  # @!expiration [rw]
  #   @return [String] The amount of time this url will expire in. Defaults to never.
  enum expiration: [
    :never,
    :hour,
    :day,
    :week,
    :month,
    :year
  ], _suffix: true

  validates :original, presence: true
  validates :original, regular_url: true
  validates :original, broken_link: true, on: :create
  validates :short, length: { maximum: CUSTOM_MAX_LENGTH, allow_blank: true }, uniqueness: true
  validates :short, presence: true, if: :persisted?
  validates :short, custom_url: true
  validates :ip_address,  presence: true
  validates :expiration,  inclusion: { in: expirations.keys }
  validates :visit_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  before_validation :default_expire, if: Proc.new { expiration.blank? }
  before_validation :format_url, if: Proc.new { original.present? }
  after_save :generate_short_url, if: Proc.new { short.blank? }
  after_create :pull_title, if: Proc.new { title.blank? }

  scope :top_visited, -> (max: ENV['MAX_TOP_RECORDS']) { order(visit_count: :desc).limit(max) }

  # Bumps the visit count number and updates the record
  def visited!
    update_attributes!(visit_count: visit_count+1)
  end

  private

  # Generates a short URL based on the record ID, stores it and saves the record
  #
  # @return [Boolean] Whether the record could or couldn't be updated successfully.
  def generate_short_url
    short = bijective_encode(id)

    # if someone stored a custom short that translates to an actual auto-generated
    # encoded ID then append the next number to it so it passes unique validation
    # the downside of course is that it makes the URL one character longer
    existing = self.class.where(short: short).count
    self.short = if existing.positive?
                   "#{short}#{existing+1}"
                 else
                   short
                 end
    save
  end

  # Returns a unique base62 encoded string representing the given numeric value
  # using a bijective function, that is, an exclusive mapping of values.
  #
  # @param [Integer] The ID or number to convert into a base62 string.
  # @return [String] The encoded string.
  def bijective_encode(i)
    return ALPHABET[0] if i == 0
    s = ''
    base = ALPHABET.length
    while i > 0
      s << ALPHABET[i.modulo(base)]
      i /= base
    end
    s.reverse
  end

  # Decodes the given base62 encoded string into its original ID number.
  #
  # @param [String] The encoded string.
  # @return [Integer] The ID or number to convert into a base62 string.
  def bijective_decode(s)
    i = 0
    base = ALPHABET.length
    s.each_char { |c| i = i * base + ALPHABET.index(c) }
    i
  end

  # Callback method that is used to set a default expiration if none is given.
  #
  # @return [ShortUrl.expirations] An expiration value.
  def default_expire
    self.expiration = self.class.expirations[:never]
  end

  # Formats the URL to have a valid protocol if none was given and also strips
  # any spaces
  def format_url
    # remove spaces
    original.gsub!(' ', '')

    # add http by default if no protocol given
    self.original = original.prepend("http://") unless %w[http https].include?(URI(original).scheme)
  end

  # Enqueues the record to have the URL title pulled from the title tag if any
  def pull_title
    # We are having race conditions, let's just wait one minute until this thing
    # is persisted so the the records is actually found
    UrlTitleGenerationJob.set(wait: 1.minutes).perform_later(self.id)
  end
end
