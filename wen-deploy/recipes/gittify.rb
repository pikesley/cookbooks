package 'git' do
  action :nothing
end.run_action(:install)
chef_gem 'git' do
  compile_time true
end
require 'git'
