require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test 'gets an API token on create' do
    user = create(:user, email: 'sponge@bob.com', password: 'burgerz')
    refute_nil user.api_token
    refute_empty user.api_token
  end

end
