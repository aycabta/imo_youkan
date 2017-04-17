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

  test '#owner? is well-behaved' do
    sp = ServiceProvider.create!(name: 'a web service')
    user = User.create!(name: 'a user')
    owner = User.create!(name: 'the owner')
    sp.add_user(user)
    sp.add_user_as_owner(owner)
    sp.reload
    assert_not(sp.owner?(user))
    assert(sp.owner?(owner))
  end

  test '#user_belongs? is well-behaved' do
    sp = ServiceProvider.create!(name: 'a web service')
    sp_2nd = ServiceProvider.create!(name: 'second service')
    user = User.create!(name: 'a user')
    user_2nd = User.create!(name: 'secound user')
    sp.add_user(user)
    sp_2nd.add_user(user_2nd)
    sp.reload
    sp_2nd.reload
    assert(sp.user_belongs?(user))
    assert_not(sp.user_belongs?(user_2nd))
  end
end
