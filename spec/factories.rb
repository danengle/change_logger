require 'user'
require 'permission'

Factory.define :user do |f|
  f.name "bob"
end

Factory.define :permission do |f|
  f.name "admin"
end