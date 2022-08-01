# frozen_string_literal: true

require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "signing in with invalid credentials results in 401" do
    post sign_in_url
    assert_response 401
    assert_nil cookies[:jwt]
  end

  test "signing in with valid credentials responds with JWT cookie" do
    user = User.create!(email: "spongebob@bottom.com", password: "gary")
    post sign_in_url, params: { email: user.email, password: user.password }
    assert_response :success
    refute_nil cookies[:jwt]
  end
end
