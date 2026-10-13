# frozen_string_literal: true

require "test_helper"
require "minitest/mock"

class McpControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @token = @user.regenerate_api_token!
    @movies = create(:list, name: "Movies", scraper: "MovieScraper", user: @user)

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
    assert_equal %w[list_lists search_items journal get_item stats check_availability
                    search_catalog add_item update_item], names
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

  test "searches the catalog and flags titles already in the library" do
    @watchlist.update!(metadata: { tmdb_id: 2 })

    result = with_catalog { call_tool("search_catalog", list: "Movies", query: "x") }

    perfect_days, submarine = result["results"]
    assert_equal "Perfect Days", perfect_days["name"]
    assert_equal 2023, perfect_days["year"]
    assert_nil perfect_days["in_library"]
    assert_equal({ "id" => @watchlist.id, "status" => "todo" }, submarine["in_library"])
  end

  test "adds a catalog title with personal details" do
    result = with_catalog do
      call_tool("add_item", list: "Movies", name: "perfect days", year: 2023,
                            recommended_by: "Mia", tags: ["horror", "Cannes"], status: "done")
    end

    item = @user.items.find(result["id"])
    assert_equal "Perfect Days", item.name
    assert_equal @movies, item.list
    assert_equal 1, item.tmdb_id
    assert item.scraped
    assert_equal "Mia", item.recommended_by
    assert_equal %w[Cannes Drama Horror], item.tags.map(&:name).sort
    assert_equal ["https://www.themoviedb.org/movie/1"], item.links.map(&:url)
    assert_equal Date.today, item.first_done_at
  end

  test "lists what the catalog has when the name doesn't match" do
    error = with_catalog do
      call_tool_error("add_item", list: "Movies", name: "Perfect Days", year: 1999)
    end

    assert_match "Found: Perfect Days (2023), Submarine (2023)", error
  end

  test "refuses to add a title twice" do
    error = with_catalog { call_tool_error("add_item", list: "Movies", name: "Submarine") }

    assert_match "Already added as Movies item #{@watchlist.id}", error
  end

  test "adds a custom item" do
    result = call_tool("add_item", list: "movies", name: "Home Movie", custom: true,
                                   year: 1999, notes: "Shot by my uncle")

    assert_equal "Home Movie", result["name"]
    assert_equal 1999, result["year"]
    assert_equal "todo", result["status"]
    assert_equal "Shot by my uncle", result["notes"]
    refute @user.items.find(result["id"]).scraped
  end

  test "updates only the given fields" do
    @watchlist.update!(notes: "From the trailer", rating: 3, recommended_by: "Reddit")

    result = call_tool("update_item", id: @watchlist.id, status: "done", rating: nil,
                                      append_note: "Loved the soundtrack.")

    @watchlist.reload
    assert_equal "done", @watchlist.status
    assert_equal Date.today, @watchlist.first_done_at
    assert_nil @watchlist.rating
    assert_equal "Reddit", @watchlist.recommended_by
    assert_equal "From the trailer\n\nLoved the soundtrack.", @watchlist.notes
    assert_equal "Loved the soundtrack.", result["notes"].split("\n\n").last
  end

  test "replaces tags and keeps the spelling of existing ones" do
    call_tool("update_item", id: @watchlist.id, tags: %w[horror Coming-of-age])

    assert_equal %w[Coming-of-age Horror], @watchlist.reload.tags.map(&:name).sort
  end

  test "can't update someone else's item" do
    other = create(:item, name: "Not mine either")

    assert_match "not found", call_tool_error("update_item", id: other.id, status: "done")
  end

  private

  def with_catalog(&)
    results = [
      catalog_result("Perfect Days", tmdb_id: 1, tags: ["Drama"]),
      catalog_result("Submarine", tmdb_id: 2, tags: ["Comedy"])
    ]
    scraper = Object.new
    scraper.define_singleton_method(:scrape) { |limit: nil| results.first(limit) }

    MovieScraper.stub(:new, scraper, &)
  end

  def catalog_result(name, tmdb_id:, tags:)
    {
      name:,
      original_name: nil,
      description: "About #{name}",
      remote_image_url: nil,
      remote_backdrop_image_url: nil,
      date: Date.new(2023, 1, 1),
      links: [Link.new(url: "https://www.themoviedb.org/movie/#{tmdb_id}")],
      tags:,
      language: "en",
      metadata: { tmdb_id: },
    }
  end

  def call_tool(name, **arguments)
    result = call_tool_raw(name, **arguments)
    refute result["isError"], result.dig("content", 0, "text")
    JSON.parse(result.dig("content", 0, "text"))
  end

  def call_tool_error(name, **arguments)
    result = call_tool_raw(name, **arguments)
    assert result["isError"], "expected #{name} to fail"
    result.dig("content", 0, "text")
  end

  def call_tool_raw(name, **arguments)
    post mcp_url, params: rpc("tools/call", name:, arguments:).to_json, headers: headers
    assert_response :success
    response.parsed_body["result"]
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
