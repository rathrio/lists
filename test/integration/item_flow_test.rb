require 'test_helper'

class ItemFlowTest < ActionDispatch::IntegrationTest
  setup do
    @user1 = create(:user, email: 'user1@email.com')
    @user2 = create(:user, email: 'user2@email.com')

    @item1 = create(:item, name: 'user1 item', user: @user1)
    @item2 = create(:item, name: 'user2 item', user: @user2)
  end

  test 'can see items on homepage' do
    get '/', params: { as: @user1.id }
    assert_response :success
    assert_select 'a', 'user1 item'
    assert_select 'a', { count: 0, text: 'user2 item' },
      "Page must not show another user's items"
  end
end
