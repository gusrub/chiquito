module Helpers
  extend ActiveSupport::Concern

  def json(json_string = response.body)
    @json ||= JSON.parse(json_string)
    @json = @json.with_indifferent_access if @json.is_a?(Hash)
    @json
  end
end
