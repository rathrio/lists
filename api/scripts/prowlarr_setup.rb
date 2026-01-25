#!/usr/bin/env ruby
# frozen_string_literal: true

# Automated Prowlarr setup - adds public indexers via API
#
# Run after starting Prowlarr:
#   docker compose -f docker-compose.dev.yml up -d prowlarr
#   ruby scripts/prowlarr_setup.rb

require "net/http"
require "json"
require "uri"

API_KEY = ENV.fetch("PROWLARR_API_KEY", "dev-prowlarr-api-key-12345")
HOST = ENV.fetch("PROWLARR_HOST", "localhost")
PORT = ENV.fetch("PROWLARR_PORT", "9696")
BASE_URL = "http://#{HOST}:#{PORT}"

def api_request(method, path, body: nil)
  uri = URI("#{BASE_URL}#{path}")

  http = Net::HTTP.new(uri.host, uri.port)

  request = case method
            when :get then Net::HTTP::Get.new(uri)
            when :post then Net::HTTP::Post.new(uri)
            end

  request["X-Api-Key"] = API_KEY
  request["Content-Type"] = "application/json"
  request.body = body.to_json if body

  response = http.request(request)

  return nil if response.body.nil? || response.body.empty?
  JSON.parse(response.body)
rescue JSON::ParserError
  response.body
end

def wait_for_prowlarr(timeout: 60)
  print "Waiting for Prowlarr to start"
  started = Time.now

  loop do
    api_request(:get, "/api/v1/health")
    puts " ready!"
    return true
  rescue Errno::ECONNREFUSED, Errno::ECONNRESET
    print "."
    sleep 2
    raise "Prowlarr did not start within #{timeout}s" if Time.now - started > timeout
  end
end

def get_indexer_schemas
  api_request(:get, "/api/v1/indexer/schema")
end

def existing_indexers
  api_request(:get, "/api/v1/indexer")
end

def add_indexer_from_schema(schema, custom_name: nil, field_overrides: {})
  name = custom_name || schema["name"]

  # Check if already exists
  if existing_indexers.any? { |i| i["name"] == name }
    puts "  #{name}: already exists, skipping"
    return
  end

  # Apply field overrides
  schema["fields"].each do |field|
    if field_overrides.key?(field["name"])
      field["value"] = field_overrides[field["name"]]
    end
  end

  indexer = {
    "name" => name,
    "implementation" => schema["implementation"],
    "implementationName" => schema["implementationName"],
    "configContract" => schema["configContract"],
    "definitionName" => schema["definitionName"],
    "protocol" => schema["protocol"],
    "privacy" => schema["privacy"],
    "supportsRss" => schema["supportsRss"],
    "supportsSearch" => schema["supportsSearch"],
    "supportsRedirect" => schema["supportsRedirect"],
    "supportsPagination" => schema["supportsPagination"],
    "enable" => true,
    "redirect" => false,
    "appProfileId" => 1,
    "priority" => 25,
    "fields" => schema["fields"],
    "tags" => []
  }

  result = api_request(:post, "/api/v1/indexer", body: indexer)

  if result.is_a?(Hash) && result["id"]
    puts "  #{name}: added (id: #{result["id"]})"
  elsif result.is_a?(Hash) && result["message"]
    puts "  #{name}: failed - #{result["message"]}"
  else
    puts "  #{name}: failed - #{result}"
  end
end

# Public indexers that work without accounts
# These names must match exactly what's in Prowlarr's schema list
PUBLIC_INDEXERS = [
  { name: "LimeTorrents" },
  { name: "YTS" },
  { name: "EZTV" },
  { name: "Nyaa.si" },
  { name: "RuTracker.RU" },
].freeze

def setup_indexers
  puts "Fetching available indexer schemas..."
  schemas = get_indexer_schemas

  puts "Adding public indexers..."

  PUBLIC_INDEXERS.each do |indexer_config|
    schema = schemas.find { |s| s["name"] == indexer_config[:name] }

    if schema.nil?
      puts "  #{indexer_config[:name]}: not found in schema list, skipping"
      next
    end

    add_indexer_from_schema(schema, field_overrides: indexer_config[:overrides] || {})
  end
end

if __FILE__ == $PROGRAM_NAME
  puts "Prowlarr Auto-Setup"
  puts "=" * 40
  puts "API Key: #{API_KEY}"
  puts ""

  wait_for_prowlarr
  puts ""

  setup_indexers
  puts ""
  puts "Done! Test with:"
  puts "  ruby scripts/prowlarr_search.rb \"Inception\" 2010"
end
