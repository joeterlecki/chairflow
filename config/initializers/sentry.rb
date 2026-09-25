# frozen_string_literal: true

Sentry.init do |config|
  # Tests and image asset builds never send telemetry, even if a DSN is inherited.
  config.dsn = Rails.env.test? || ENV["SECRET_KEY_BASE_DUMMY"].present? ? nil : ENV["SENTRY_DSN"]
  config.environment = ENV.fetch("SENTRY_ENVIRONMENT", Rails.env)
  config.release = ENV.fetch("SENTRY_RELEASE", "chairflow@poc")
  config.breadcrumbs_logger = [ :active_support_logger, :http_logger ]
  # SDK 7 equivalent of send_default_pii = true, retaining built-in scrubbing.
  config.data_collection = Sentry::DataCollection.new

  # SDK 7 enables structured logs by default (enable_logs was removed).
  # Preserve the default HTTP/Puma patches while forwarding Ruby/Rails logs.
  config.enabled_patches << :logger

  config.traces_sample_rate = Float(ENV.fetch("SENTRY_TRACES_SAMPLE_RATE", "1.0"))
  config.profiles_sample_rate = Float(ENV.fetch("SENTRY_PROFILES_SAMPLE_RATE", "1.0"))
  config.traces_sampler = lambda do |context|
    # Docker calls this endpoint every 10 seconds; keep it out of performance data.
    context.dig(:env, "PATH_INFO") == "/up" ? 0.0 : config.traces_sample_rate
  end
end
