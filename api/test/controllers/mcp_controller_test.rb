# frozen_string_literal: true

require "test_helper"

class McpControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @token = @user.regenerate_api_token!
    @movies = create(:list, name: "Movies", user: @user)

    @watched = create(:item, user: @user, list: @movies, name: "The Wailing",
                             status: :done, rating: 5, first_done_at: Date.new(2024, 3, 1))
    @watchlist = create(:item, user: @user, list: @movies, name: "Submarine", status: :todo)
    @watched.tags = ["Horror"]

    # Someone else's item must never show up.
    create(:item, name: "Not mine", status: :done, first_done_at: Date.new(2024, 3, 2))
  end

  test "rejects requests without a valid token" do
    post mcp_url, params: rpc("tools/list").to_json, headers: headers(token: "nope")
    assert_response 401
  end

  test "lists tools" do
    post mcp_url, params: rpc("tools/list").to_json, headers: headers
    assert_response :success

    names = response.parsed_body.dig("result", "tools").map { |tool| tool["name"] }
    assert_equal %w[list_lists search_items journal get_item stats check_availability], names
  end

  test "searches the user's items" do
    result = call_tool("search_items", list: "movies", status: "todo")

    assert_equal 1, result["total"]
    assert_equal "Submarine", result.dig("items", 0, "name")
  end

  test "journal lists finished items of the user" do
    result = call_tool("journal", from: "2024-01-01", to: "2024-12-31")

    assert_equal(["The Wailing"], result["items"].map { |item| item["name"] })
  end

  test "stats groups items" do
    result = call_tool("stats", group_by: "tag")

    assert_equal [{ "key" => "Horror", "count" => 1, "avg_rating" => 5.0 }], result["groups"]
  end

  test "gets an item" do
    result = call_tool("get_item", id: @watched.id)

    assert_equal "The Wailing", result["name"]
    assert_equal ["Horror"], result["tags"]
  end

  private

  def call_tool(name, **arguments)
    post mcp_url, params: rpc("tools/call", name:, arguments:).to_json, headers: headers
    assert_response :success

    result = response.parsed_body["result"]
    refute result["isError"], result.dig("content", 0, "text")
    JSON.parse(result.dig("content", 0, "text"))
  end

  def rpc(method, **params)
    { jsonrpc: "2.0", id: 1, method:, params: }
  end

  def headers(token: @token)
    {
      "Authorization" => "Bearer #{token}",
      "Content-Type" => "application/json",
      "Accept" => "application/json, text/event-stream",
    }
  end
end
