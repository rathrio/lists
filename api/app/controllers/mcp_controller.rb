# frozen_string_literal: true

# Model Context Protocol endpoint giving MCP clients (e.g. Claude Desktop)
# read access to the library of the user owning the bearer API token. See
# `rails api_token:generate` for issuing one.
#
# Stateless: every POST builds a fresh server scoped to the authenticated
# user, so it works across multiple Puma workers.
class McpController < ActionController::API
  TOOLS = [
    ListListsTool,
    SearchItemsTool,
    JournalTool,
    GetItemTool,
    StatsTool,
    CheckAvailabilityTool
  ].freeze

  INSTRUCTIONS = <<~TEXT
    Read access to the user's personal media library from Lists: movies, TV
    shows, books, games, music and whatever other lists they keep. Each item
    has a status (todo = backlog/watchlist, doing = in progress, done =
    finished), an optional rating from 0 to 5, tags, personal notes, who
    recommended it, and the date it was first finished (the journal).
    Archived items were removed from their list, often because the user lost
    interest. Ground recommendations and answers about the user's taste or
    history in this data rather than guessing.
  TEXT

  before_action :authenticate

  def handle
    server = MCP::Server.new(
      name: "lists",
      title: "Lists",
      version: "1.0.0",
      instructions: INSTRUCTIONS,
      tools: TOOLS,
      server_context: { user: @user },
    )
    transport = MCP::Server::Transports::StreamableHTTPTransport.new(
      server,
      stateless: true,
      serve_subscriptions_listen: false,
      # Host/Origin checks guard unauthenticated local servers against DNS
      # rebinding. Every request here carries a bearer token a rebinding
      # page can't know, and the Host is whatever the reverse proxy sends.
      dns_rebinding_protection: false,
    )

    status, headers, body = transport.handle_request(request)
    response.headers.merge!(headers)
    self.status = status
    self.response_body = body
  end

  private

  def authenticate
    token = request.authorization.to_s[/\ABearer (.+)\z/, 1]
    @user = User.find_by_api_token(token)
    return if @user

    response.headers["WWW-Authenticate"] = 'Bearer realm="lists"'
    render json: { message: "Invalid or missing API token" }, status: 401
  end
end
