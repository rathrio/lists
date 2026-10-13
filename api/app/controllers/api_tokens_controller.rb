# frozen_string_literal: true

# The current user's API token for the MCP server (see McpController). Only
# its digest is stored, so the plaintext token is part of the create response
# and nowhere else.
class ApiTokensController < ApplicationController
  def show
    render json: { active: current_user.api_token.present? }
  end

  def create
    render json: { token: current_user.regenerate_api_token! }, status: :created
  end

  def destroy
    current_user.revoke_api_token!
    head :no_content
  end
end
