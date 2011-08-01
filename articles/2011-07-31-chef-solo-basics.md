---
episode: 1
title: Chef Solo Basics
date: 31/07/2011

Welcome to our first episode! In this episode we'll cover the basics you'll need to get started with Chef Solo.

<iframe src="http://player.vimeo.com/video/14577555?title=1&amp;byline=1&amp;portrait=1" width="720" height="540" frameborder="0"></iframe>

~

# Prep

1. start virtual box
2. open ubuntu vm, don't start it
3. start redcar
4. open slides

# Script

(slide start)

Hi, I'm Mat Schaffer and this is the DevOps Screencast. This is the first episode of the screencast, so while I haven't nailed down the format yet, I plan to cover a range of topics including infrastructure automation, systems-level concepts and unix utility tutorials.

(slide change)

In this episode we'll be looking at the basics of using Chef Solo.

Chef is an server configuration framework written in Ruby. Using chef, we can configure various software packages automatically and uniformly. Chef works in two modes, chef server and chef solo. Today we'll talk about Chef solo and we'll cover Chef server in future screencasts.

(slide change)

When using chef solo you develop your cookbooks and recipes locally on your development machine.

(change)

You then copy these cookbooks and any other configuration information up to your server using SCP or Rsync.

(change)

Then you invoke the chef-solo command on the server. The Chef-solo command will then run through all the recipes you've specified in your node configuration file.

As you can see, this is somewhat manual. But there are a handful of tools that you can use to make building and running your recipes a little easier.

(slide change)

Today we'll use knife-solo, a gem I just recently released.

(change)

Of course since it's new software, you may encounter some bugs. If you do, please let me know. There are also other tools that help with this job that you might want to try out like spatula, soloist or littlechef.

(virtualbox, start it)

Now to demonstrate Chef solo I'll need a machine to configure. So I've prepared a minimal Ubuntu system running on VirtualBox. If you need pointers on creating your own I have a blog post that goes over the process. Or you can download it from the link you see here.

(terminal)

    $ gem install knife-solo

Knife solo is based on chef's own knife helper tool. It gives you a few extra commands that make working with chef solo a bit easier. If this is the first time you're using knife, you'll need to generate a configuration file.

    $ knife configure -r . --defaults

While this isn't strictly necesary for this demo, having a knife configuration file avoids some warnings that you'll see if you don't configure knife. Now I can use the knife kitchen command to make a place to hold my recipes.

    $ knife kitchen solodemo
    $ cd solodemo
    $ tree

This will create the standard layout for a chef repository. We'll go over these in more detail in future screen casts. For today, we'll focus on the cookbooks and nodes directories.

(chrome: github.com/opscode/cookbooks)

Often you can find cookbooks for various packages online. Opscode, the company that created chef maintains a cookbook repository on github. 37signals and other companies are beginning to do the same. While these cookbooks don't always work for your particular environment they at least provide good examples and starting points.

(terminal)

Today we'll keep things simple and just install a redis server. We could use the opcode cookbook, but we'll make one from scratch to get some practice working with cookbooks.

To create a cookbook, use the knife cookbook command.

    $ knife cookbook create redis -o cookbooks

We specify the name of the cookbook, redis. And use the -o option to tell knife to store it in the cookbooks directory. Each cookbook contains a default recipe. We'll use this recipe to install and start the redis server.

(redcar: cookbooks/redis/recipes/default.rb)

Chef uses a Ruby DSL to define recipes. To install redis from the ubuntu package we use the package resource. Then to ensure that redis is started on every boot, we use the service resource. Since redis comes with a regular SysV control script, we'll tell chef that it supports restart and status. This tells chef to use the SysV script rather than trying to inspect the process table to check if redis is running or not.

(terminal)

Now before we can run this recipe on our VM, we have to install chef solo on it.

    $ knife prepare ubuntu@ip

To do that we run knife prepare. This is a knife-solo command that will install ruby and chef so that we can run chef solo. It should handle most major linux distros but has only been extensively tested on Ubuntu so far. It also generates an empty node configuration.

(redcar: nodes/ip.json)

This file is what tells chef which recipes should run on a given host. To include the redis recipe we just wrote, we add `recipe[redis]` to the run list.

(terminal)

    $ knife cook ubuntu@ip

Now to install redis on our VM using chef solo we run the knife cook command. This will copy our cookbooks over to the VM and run chef solo using the node configuration that matches the IP of the box.

    $ redis-cli -h ip

And now let's use the redis CLI to make sure we can use our new redis server.

And that's it! We'll go over more of the details in upcoming sceencasts, but hopefully this is enough to get you started exploring chef for your own servers. Thanks for watching!
