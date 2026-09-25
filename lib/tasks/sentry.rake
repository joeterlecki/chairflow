namespace :sentry do
  desc "Send a tagged verification error, message, log, trace, and profile through the Rails SDK"
  task verify: :environment do
    abort "Set SENTRY_DSN outside the test environment first." unless Sentry.configuration.dsn

    marker = "chairflow-sentry-verification-#{SecureRandom.hex(6)}"
    receipts = []
    transport = Sentry.get_current_client.transport
    original_request = transport.method(:do_request)
    # Observe the actual SDK transport response without logging request contents.
    transport.define_singleton_method(:do_request) do |endpoint, headers, body|
      payload = headers["Content-Encoding"] == "gzip" ? Zlib.gunzip(body) : body
      types = payload.lines.drop(1).each_slice(2).map { |item| JSON.parse(item.first).fetch("type") }
      response = original_request.call(endpoint, headers, body)
      receipts << { status: response.code, types: types, rate_limits: response["x-sentry-rate-limits"] }
      puts "Sentry ingestion HTTP #{response.code}: #{types.join(', ')}#{response['x-sentry-rate-limits'].present? ? ' (rate limits returned)' : ''}"
      response
    rescue StandardError
      receipts << { status: "transport error" }
      raise
    end

    puts "Verification marker: #{marker}"
    Sentry.with_scope do |scope|
      scope.set_tags(verification: marker)
      transaction = Sentry.start_transaction(name: "sentry:verify", op: "task")
      scope.set_span(transaction)
      begin
        # A real Active Record call adds a database span through sentry-rails.
        Stylist.count
        # Allow enough sampling time for StackProf to produce a useful profile.
        sleep 0.15
        begin
          1 / 0
        rescue ZeroDivisionError => exception
          puts "Exception event ID: #{Sentry.capture_exception(exception)&.event_id}"
        end
        puts "Message event ID: #{Sentry.capture_message('test message', tags: { verification: marker })&.event_id}"
        Rails.logger.info("Sentry verification log: #{marker}")
        puts "Trace ID: #{transaction.trace_id}"
      ensure
        transaction.finish
      end
    end
    # This is a one-shot Rails task; close drains logs/events and joins the worker.
    Sentry.close
    abort "Sentry did not accept every envelope. Inspect SDK errors above." if receipts.empty? || receipts.any? { |receipt| !receipt[:status].start_with?("2") || receipt[:rate_limits].present? }
    puts "SDK envelopes accepted by Sentry ingestion. Account-side issue lookup requires authenticated Sentry access."
  end
end
