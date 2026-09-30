Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.formatter = Lograge::Formatters::Json.new

  # request_id as a JSON field, not a TaggedLogging text prefix (which would break the JSON).
  config.lograge.custom_options = lambda do |event|
    { request_id: event.payload[:headers]["action_dispatch.request_id"] }
  end
end
