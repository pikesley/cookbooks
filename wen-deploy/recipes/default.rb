PROJECT_ROOT = '/home/pi/wen'
USER = 'pi'

user USER do
  home "/home/#{USER}"
  shell '/bin/bash'
  manage_home true
end

file "/etc/sudoers.d/#{USER}" do
  content "#{USER} ALL=(ALL) NOPASSWD: ALL"
  mode '0440'
  action :create
end

[
  'build-essential',
  'zlib1g-dev',
  'curl',
  'vim',
  'git',
  'ruby2.1',
  'ruby2.1-dev',
  'redis-server',
  'nginx'
].each do |package|
  package package do
    action :install
  end
end

bash 'set default ruby' do
  code <<-EOF
    update-alternatives --install /usr/bin/ruby ruby `which ruby2.1` 1
    update-alternatives --install /usr/bin/gem gem `which gem2.1` 1
  EOF
end

gem_package 'bundle' do
  action :install
end

package 'nano' do
  action :remove
end

bash 'set timezone' do
  code <<-EOF
    timedatectl set-timezone Europe/London
  EOF
end

deploy_revision PROJECT_ROOT do
  repo 'https://github.com/pikesley/wen'
  revision 'master'
  migrate false
  action :deploy
  user USER
  group USER

  before_restart do
    bash 'bundle' do
      cwd release_path
      user USER
      code <<-EOF
        bundle
      EOF
    end

    remote_file '/etc/nginx/sites-enabled/wen' do
      source "file://#{release_path}/scripts/vhost"
    end

    remote_file '/etc/nginx/sites-enabled/default' do
      action :delete
    end

    bash 'generate startup scripts' do
      cwd release_path
      user USER
      code <<-EOF
        sudo bundle exec foreman export systemd \
          -u #{USER} -a wen /etc/systemd/system/
      EOF
    end

    remote_file '/etc/systemd/system/timekeeper.service' do
      source "file://#{release_path}/scripts/timekeeper.service"
    end

    remote_file '/etc/systemd/system/pivertiser.service' do
      source "file://#{release_path}/scripts/pivertiser.service"
    end

    [
      'nginx',
      'wen.target',
      'timekeeper.service',
      'pivertiser.service'
    ].each do |service|
      service service do
        action [:enable, :restart]
      end
    end
  end
end
