require 'test_helper'

class ItemFlowTest < ActionDispatch::IntegrationTest
  setup do
    @user1 = create(:user, email: 'user1@email.com')
    @user2 = create(:user, email: 'user2@email.com')

    @item = create(:item, name: 'Foobar')
  end

  test 'can see items on homepage' do
    get '/', params: { as: @user1.id }
    assert_response :success
    assert_select 'a', 'Foobar'
  end
end
