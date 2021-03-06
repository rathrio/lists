require 'test_helper'

class ItemFlowTest < ActionDispatch::IntegrationTest
  setup do
    @user1 = create(:user, email: 'user1@email.com')
    @user2 = create(:user, email: 'user2@email.com')

    @item1 = create(:item, name: 'user1 item', user: @user1)
    @item2 = create(:item, name: 'user2 item', user: @user2)

    @list = create(:list, user: @user1)
  end

  test 'redirect to first list when requesting homepage' do
    get '/', params: { as: @user1.id }
    assert_redirected_to "/items?list_ids=#{@list.id}"
  end

  test 'can create item with list id in session' do
    get "/items?list_ids=#{@list.id}", params: { as: @user1.id }

    assert_difference 'Item.count', 1 do
      post '/items', params: { item: { name: 'spiderman', as: @user1.id } }
    end
  end
end
