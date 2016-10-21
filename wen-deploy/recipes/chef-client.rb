#include_recipe 'chef-solo'

directory '/etc/chef' do
  action :create
end

directory '/var/log/chef' do
  action :create
end

file '/etc/chef/solo.rb' do
  content <<-EOF
  recipe_url 'http://pikesley.org/cookbooks/wen-deploy.tgz'
  json_attribs '/etc/chef/chef.json'
  local_mode true
  EOF
end

file '/etc/chef/client.rb' do
  content <<-EOF
  chef_zero.enabled true
  local_mode true
  EOF
end

file '/etc/chef/chef.json' do
  content "#{{
    run_list: [
      'recipe[wen-deploy]'
    ]
  }.to_json}"
end

file '/var/spool/cron/crontabs/root' do
  content "#{node['chef_client']['cron']['minute']} #{node['chef_client']['cron']['minute']} * * * /usr/bin/chef-solo -c /etc/chef/solo.rb"
end

service 'chef-client' do
  provider Chef::Provider::Service::Systemd
  action :disable
end
