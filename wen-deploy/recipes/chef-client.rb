directory '/etc/chef' do
  action :create
end

directory '/var/log/chef' do
  action :create
end

template '/etc/chef/solo.rb' do
  source 'solo.rb.erb'
end

template '/etc/chef/client.rb' do
  source 'client.rb.erb'
end

template '/etc/chef/chef.json' do
  source 'chef.json.erb'
end

cron 'chef-run' do
  minute '*/5'
  hour '*'
  command '/usr/bin/chef-solo -c /etc/chef/solo.rb -L /var/chef/client.log'
end

service 'chef-client' do
  provider Chef::Provider::Service::Systemd
  action :disable
end
