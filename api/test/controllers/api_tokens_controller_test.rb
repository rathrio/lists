# frozen_string_literal: true

require "test_helper"

class ApiTokensControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email: "spongebob@bottom.com", password: "gary")
    post sign_in_url, params: { email: @user.email, password: "gary" }
  end

  test "generating and revoking a token" do
    get api_token_url
    assert_equal({ "active" => false }, response.parsed_body)

    post api_token_url
    assert_response :created
    assert_equal @user, User.find_by_api_token(response.parsed_body["token"])

    get api_token_url
    assert_equal({ "active" => true }, response.parsed_body)

    delete api_token_url
    assert_response :no_content
    assert_nil @user.reload.api_token
  end
end
