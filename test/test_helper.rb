ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'active_ldap_fabrication'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...

  # LDAP: start
  setup do
    @dumped_data = nil
    begin
      @dumped_data = ActiveLdap::Base.dump(scope: :one)
    rescue ActiveLdap::ConnectionError
    end
    ActiveLdap::Base.delete_all(nil, scope: :one)
    populate_ldap
  end

  teardown do
    if @dumped_data
      ActiveLdap::Base.setup_connection
      ActiveLdap::Base.delete_all(nil, scope: :one)
      ActiveLdap::Base.load(@dumped_data)
    end
  end

  def populate_ldap
    populate_ldap_base
    populate_ldap_ou
  end

  def populate_ldap_base
    ActiveLdap::Populate.ensure_base
  end

  def populate_ldap_ou
    ActiveLdap::Populate.ensure_ou('LdapUsers')
  end
  # LDAP: end
end
