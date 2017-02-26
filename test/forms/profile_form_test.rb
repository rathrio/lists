require 'test_helper'

class ProfileFormTest < ActiveSupport::TestCase
  test '#update requires fields to be present' do
    form = ProfileForm.new
    assert_equal false, form.update

    form.user = create(:user, password: '123')
    assert_equal false, form.update

    form.current_password = '123'
    assert_equal false, form.update

    form.new_password = '1234'
    assert_equal false, form.update

    form.new_password_confirmation = '1234'
    assert_equal true, form.update
  end

  test "#update requires current_password to be the user's password" do
    user = create(:user, password: '123')
    form = ProfileForm.new(
      user: user,
      current_password: 'foobar',
      new_password: '1234',
      new_password_confirmation: '1234'
    )

    assert_equal false, form.update

    form.current_password = '123'
    assert_equal true, form.update
  end

  test "#update requires new_password to equal new_password_confirmation" do
    user = create(:user, password: '123')
    form = ProfileForm.new(
      user: user,
      current_password: '123',
      new_password: '1234',
      new_password_confirmation: 'chello'
    )

    assert_equal false, form.update

    form.new_password_confirmation = '1234'
    assert_equal true, form.update
  end
end
