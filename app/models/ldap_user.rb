class LdapUser < ActiveLdap::Base
  ldap_mapping dn_attribute: 'uid', prefix: '', classes: ['inetOrgPerson']
end
