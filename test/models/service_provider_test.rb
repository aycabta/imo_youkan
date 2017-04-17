require 'test_helper'

class ServiceProviderTest < ActiveSupport::TestCase
  test '#add_user_as_owner is well-behaved' do
    sp = ServiceProvider.create!(name: 'a web service')
    assert_equal(0, sp.users.size)
    assert_equal(0, sp.owners.size)
    sp.add_user_as_owner(User.create!(name: 'the owner'))
    sp.reload
    assert_equal(1, sp.users.size)
    assert_equal(1, sp.owners.size)
  end

  test '#add_owner is well-behaved' do
    sp = ServiceProvider.create!(name: 'a web service')
    assert_equal(0, sp.users.size)
    assert_equal(0, sp.owners.size)
    sp.add_user(User.create!(name: 'a user'))
    sp.reload
    assert_equal(1, sp.users.size)
    assert_equal(0, sp.owners.size)
  end
end
