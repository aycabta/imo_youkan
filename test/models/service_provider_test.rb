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

  test '#consumers_by_user is well-behaved' do
    sp = ServiceProvider.create!(name: 'a web service')
    user = User.create!(name: 'a user')
    consumer = Consumer.create!(name: 'a consumer', service_provider: sp, owner: user)
    Consumer.create!(name: '2nd consumer', service_provider: sp, owner: user)
    Consumer.create!(name: '3rd consumer', service_provider: sp, owner: User.create!(name: '2nd user'))
    consumers = sp.consumers_by_user(user)
    assert_equal(2, consumers.size)
    consumer_names = ['a consumer', '2nd consumer']
    consumers.each do |consumer|
      assert_not_nil(consumer_names.delete(consumer.name))
    end
    assert_empty(consumer_names)
  end

  test '#unknown_scopes is well-behaved' do
    scopes = %w(basic profile data, post, comment)
    unknown_scopes = %w(dummy unidentified)
    redirect_uri = 'http://foo.com/'
    state = 'teststate'
    sp = ServiceProvider.create!(name: 'a web service')
    scopes.each { |name| sp.scopes.create!(name: name) }
    consumer = Consumer.create!(name: 'a consumer', service_provider: sp, owner: User.create!)
    consumer.redirect_uris.create!(uri: redirect_uri)
    token = Token.new(consumer: consumer)
    result = sp.unknown_scopes(scopes)
    assert_empty(result)
    result = sp.unknown_scopes(scopes[0, 2])
    assert_empty(result)
    result = sp.unknown_scopes(scopes[0, 2].concat(unknown_scopes))
    assert_equal(unknown_scopes, result)
  end
end
