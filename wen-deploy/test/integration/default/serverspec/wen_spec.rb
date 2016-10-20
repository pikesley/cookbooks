[
  'redis',
  'httparty'
].each do |gem|
  begin
    Gem::Specification.find_by_name(gem)
  rescue Gem::LoadError
    require 'rubygems/dependency_installer'
    Gem::DependencyInstaller.new(Gem::DependencyInstaller::DEFAULT_OPTIONS).install(gem)
  end
  require gem
end

require 'serverspec'
set :backend, :exec

context 'user' do
  describe user 'pi' do
    it { should exist }
  end

  describe file '/home/pi' do
    it { should be_directory }
    it { should be_owned_by 'pi' }
  end

  describe file '/etc/sudoers.d/pi' do
    it { should be_file }
    it { should contain 'pi ALL=(ALL) NOPASSWD: ALL' }
  end
end

context 'packages' do
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
    describe package package do
      it { should be_installed }
    end
  end

  describe package 'nano' do
    it { should_not be_installed }
  end
end

context 'ruby' do
  describe file '/usr/bin/ruby' do
    it { should be_symlink }
  end

  describe command 'ruby -v' do
    its(:stdout) { should match /2.1/ }
  end

  describe file '/usr/bin/gem' do
    it { should be_symlink }
  end
end

context 'gems' do
  describe file '/usr/local/bin/bundle' do
    it { should be_file }
  end
end

context 'timezone' do
  describe file '/etc/timezone' do
    its(:content) { should contain 'Europe/London' }
  end
end

context 'code' do
  describe file '/home/pi/wen' do
    it { should be_directory }
    it { should be_owned_by 'pi' }
  end

  describe file '/home/pi/wen/current/scripts/hit-clock.sh' do
    it { should be_file }
    it { should be_executable }
  end
end

context 'nginx' do
  describe file '/etc/nginx/sites-enabled/wen' do
    it { should be_file }
    its(:content) { should match /upstream wen {
  server 127.0.0.1:8080;
}/}
    its(:content) { should contain 'root /home/pi/wen/public;' }
    its(:content) { should match /location \@wen {
    include proxy_params;

    proxy_pass http:\/\/wen;
  }/}
  end

  describe file '/etc/nginx/sites-enabled/default' do
    it { should_not exist }
  end

  describe service 'nginx' do
    it { should be_enabled }
    it { should be_running }
  end
end

context 'wen services' do
  context 'wen' do
    describe file '/etc/systemd/system/wen.target' do
      it { should be_file }
      its(:content) { should contain 'Wants=wen-web.target wen-worker.target' }
    end

    describe file '/etc/systemd/system/wen-worker.target.wants' do
      it { should be_directory }
    end

    describe file '/etc/systemd/system/multi-user.target.wants/wen.target' do
      it { should be_symlink }
    end

    describe service 'wen.target' do
      it { should be_enabled }
      it { should be_running }
    end
  end

  context 'timekeeper' do
    describe file '/etc/systemd/system/timekeeper.service' do
      it { should be_file }
      its(:content) { should contain 'ExecStart    = /home/pi/wen/scripts/hit-clock.sh' }
    end

    describe file '/etc/systemd/system/multi-user.target.wants/timekeeper.service' do
      it { should be_symlink }
    end

    describe service 'timekeeper.service' do
      it { should be_enabled }
    end
  end

  context 'pivertiser' do
    describe file '/etc/systemd/system/pivertiser.service' do
      it { should be_file }
      its(:content) { should contain 'After       = network-online.target' }
    end

    describe service 'pivertiser.service' do
      it { should be_enabled }
    end
  end
end

context 'operating clock' do
  describe port(8080) do
    it { should be_listening }
  end

  describe port(80) do
    it { should be_listening }
  end

  describe 'web service' do
    it 'is running' do
      response = HTTParty.get 'http://localhost/colours'
      expect(response).to match /<title>Colours<\/title>/
    end
  end
end
