# frozen_string_literal: true

namespace :api_token do
  desc "Generate a user's API token for the MCP server, revoking the previous " \
       "one. Usage: rails 'api_token:generate[me@example.com]'"
  task :generate, [:user] => :environment do |_, args|
    user = find_user!(args[:user])
    puts user.regenerate_api_token!
  end

  desc "Revoke a user's API token. Usage: rails 'api_token:revoke[me@example.com]'"
  task :revoke, [:user] => :environment do |_, args|
    user = find_user!(args[:user])
    user.revoke_api_token!
    puts "Revoked API token of #{user.email}"
  end

  # @param id_or_email [String]
  def find_user!(id_or_email)
    abort "Pass a user id or email, e.g. rails 'api_token:generate[1]'" if id_or_email.blank?

    User.find_by(email: id_or_email) || User.find(id_or_email)
  end
end
