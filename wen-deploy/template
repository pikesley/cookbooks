sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq chef

sudo chmod a+r /etc/chef/client.rb

sudo systemctl stop chef-client
sudo systemctl disable chef-client

echo '{"run_list":["recipe[wen-deploy]"]}' > /tmp/chef.json

sudo chef-solo --recipe-url="http://pikesley.org/cookbooks/wen-deploy.tgz" -j /tmp/chef.json
