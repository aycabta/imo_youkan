Fabricator(:ldap_user) do
end

Fabricator(:great_user, from: :ldap_user) do
  uid 'great_user'
  cn 'Great User'
  sn 'The Great'
  mail 'great_user@great_mail.com'
  userPassword 'foobar'
end

Fabricator(:little_user, from: :ldap_user) do
  uid 'little_user'
  cn 'Little User'
  sn 'The Little'
  mail 'little_user@great_mail.com'
  userPassword 'foobar'
end
