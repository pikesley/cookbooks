# Let's build a clock

To get [Wen](http://sam.pikesley.org/projects/wen/) up and running from a clean install of [NOOBS](https://www.raspberrypi.org/downloads/noobs/) 1.9 [Raspbian Jessie Lite](https://www.raspberrypi.org/downloads/raspbian/) on a Pi Zero, you should be able to just do this from the `wen-deploy` directory

    knife bootstrap --ssh-user pi -t template <node ip>

(this relies on you having Chef installed, `gem install chef` will probably work)

Your clock will now check for new _Wen_ code every five minutes, and download and install whatever it finds.

# Let's host our cookbooks on Github Pages

This is all intended to run with [Chef Solo](https://docs.chef.io/chef_solo.html), to avoid the need for me to run my own Chef server, but I still need to be able to get updated cookbooks out to clients. I wondered about Heroku, or even serving them up from my VPS, but it occurred to me that Github Pages might be just the thing.

So I now have [a Rake task](https://github.com/pikesley/cookbooks/blob/gh-pages/wen-deploy/Rakefile#L8-L19) which packages up the cookbook into the form expected by chef-solo, then publishes to the _gh-pages_ branch. The cookbook [looks here for any updates](https://github.com/pikesley/cookbooks/blob/313193191d45ab7f8eeec2031ac8615ce2972919/wen-deploy/templates/default/solo.rb.erb#L1) on every Chef run, and I somehow seem to have lashed together a Tesco Value Chef Server.

I have no idea how this aligns with Github's Terms of Use.
