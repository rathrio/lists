# frozen_string_literal: true

# The MCP SDK answers tool exceptions with an opaque "Internal error" and
# swallows the original by default. Log it instead.
MCP.configure do |config|
  config.exception_reporter = lambda do |exception, _server_context|
    error = exception.respond_to?(:original_error) && exception.original_error || exception
    backtrace = error.backtrace&.first(10)&.join("\n")
    Rails.logger.error("[MCP] #{error.class}: #{error.message}\n#{backtrace}")
  end
end
