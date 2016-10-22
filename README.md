# Let's build a clock

To get [Wen](http://sam.pikesley.org/projects/wen/) up and running from a clean install of [NOOBS](https://www.raspberrypi.org/downloads/noobs/) 1.9 [Raspbian Jessie Lite](https://www.raspberrypi.org/downloads/raspbian/) on a Pi Zero, you should be able to just do this from the `wen-deploy` directory

    knife bootstrap --ssh-user pi -t template <node ip>

(this relies on you having Chef installed, `gem install chef` will probably work)
