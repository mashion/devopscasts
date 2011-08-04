---
episode: 1
title: Chef Solo Basics
date: 31/07/2011

Welcome to our first episode! In this episode we'll cover the basics you'll need to get started with Chef Solo.

<iframe width="425" height="349" src="http://www.youtube.com/embed/1G6bd4b91RU" frameborder="0" allowfullscreen></iframe>

~

# Prep

1. Prep virtualbox VM: get IP and upload keys, snapshot, then shutdown
2. Remove ~/.chef/knife.rb
3. Switch to empty gemset
4. start redcar
5. open chrome to github.com/opscode/cookbooks
6. open slides

# Script

(slide start)

Hi, I'm Mat Schaffer and this is the DevOps Screencast.  This is the first
episode of the screencast, so while I haven't nailed down the format yet, I
plan to cover a range of topics including infrastructure automation,
systems-level concepts and unix utility tutorials.

(slide change)

In this episode we'll be looking at the basics of using Chef Solo.

Chef is an server configuration framework written in Ruby. Using chef, we can
configure various software packages automatically. The recipes we build can
then be reused across many machines to ensure uniformity across all your
servers.

Chef works in two modes, chef server and chef solo. Today we'll talk about Chef
solo and we'll cover Chef server in future screencasts.

(slide change)

In chef solo, there's no separate chef server. You only have your development
machine and your application server. You develop your cookbooks and recipes
locally on your development machine.

(change)

You then copy these cookbooks and any other configuration information up to
your server using SCP or Rsync.

(change)

Then you invoke the chef-solo command on the server. The Chef-solo command will
then run through all the recipes you've specified in your node configuration
file.

As you can see, this is somewhat manual. But there are a handful of tools that
you can use to make building and running your recipes a little easier.

(slide change)

Today we'll use knife-solo. Knife-solo is a plugin for Knife, the main command
line utility that drives Chef.

(change)

I just recently released knife-solo, you may encounter some bugs. If you do,
please let me know. There are also other tools that help with this job that you
might want to try out like spatula, soloist or littlechef. Writing your own is
also fairly straight forward.

(terminal)

    $ gem install knife-solo

Knife solo is based on chef's own knife helper tool. It gives you a few extra
commands that make working with chef solo a bit easier. If this is the first
time you're using chef, the install make take a bit of time since it will also
install the chef gem. You'll need to generate a configuration file.

    $ knife configure -r . --defaults

The options I specified here just set up some defaults. Since we're only using
chef solo we don't need this configuration, but knife is a bit noisy if the
file doesn't exist. Now I can use the knife kitchen command to make a place to
hold my recipes.

    $ knife kitchen solodemo $ cd solodemo $ tree

This will create the standard layout for a chef repository. We'll go over these
in more detail in future screen casts. For today, we'll focus on the cookbooks
and nodes directories.

(chrome: github.com/opscode/cookbooks)

Often you can find cookbooks for various packages online. Opscode, the company
that created chef maintains a cookbook repository on github. 37signals and
other companies are beginning to do the same. While these cookbooks don't
always work for your particular environment they at least provide good examples
and starting points.

(terminal)

Today we'll keep things simple and just install a nginx server. We could use
the opcode cookbook, but we'll make one from scratch to get some practice
working with cookbooks.

To create a cookbook, use the knife cookbook command.

    $ knife cookbook create nginx -o cookbooks

We specify the name of the cookbook, nginx. And use the -o option to tell knife
to store it in the cookbooks directory. Each cookbook contains a default
recipe. We'll use this recipe to install and start the nginx server.

(redcar: cookbooks/nginx/recipes/default.rb)

Chef uses a Ruby DSL to define recipes. But before we start coding it we'll
have a look at what we want to do.

(virtualbox, start it)

I've prepared a minimal Ubuntu system running on VirtualBox that we'll use to
work through this installation. If you need pointers on creating your own I
have a blog post that goes over the process. Or you can download it from the
link you see here.

(terminal)

Now before we can run any recipes on our VM, we have to install chef solo on
it.

    $ knife prepare ubuntu@ip

To do that we run knife prepare. This is a knife-solo command that will install
ruby and chef so that we can run chef solo. It also generates an empty node
configuration.

(redcar: nodes/ip.json)

This file is what tells chef which recipes should run on a given host. To
include the nginx recipe we just wrote, we add `recipe[nginx]` to the run list.

(terminal)

    $ knife cook ubuntu@ip

Now to install nginx on our VM using chef solo we run the knife cook command.
This will copy our cookbooks over to the VM and run chef solo using the node
configuration that matches the IP of the box.

Now of course this didn't do anything because we haven't written the recipe. We
first want to install nginx, so we'll take a look at the machine and find out
what the package name is.

(virtualbox: logged in)

    $ apt-cache search nginx

As you can see it's just "nginx", so we'll add a package statement to our
recipe for that and cook again.

(redcar: default.rb)

    package 'nginx'

(terminal)

    $ knife cook ubuntu@ip

(chrome: ip)

Now nginx is installed, but it's not yet running.

(virtualbox)

    $ ls /etc/init.d/

As we can see here, the nginx package installs a standard init script. We can
tell chef to use that by defining a service that supports the 'status' command.
This tells chef to use the init script rather than trying to inspect the
process table directly. Then we cook again.

(redcar: default.rb)

    service 'nginx' do supports [:status] end

(terminal)

    $ knife cook ubuntu@ip

(chrome: ip)

As we can see, it's still not running. All we've done here is defined a service
that chef now knows about. To start it, we add the :start action and cook
again.

(redcar: default.rb)

    service 'nginx' do
      supports [:status]
      action :start
    end

(terminal)

    $ knife cook ubuntu@ip

And now if we open a browser to the VM's IP. We'll get a nice welcome message.

Now to demonstrate that we can reuse this recipe, we'll roll back the VM and
run the whole thing in one sweep.

(virtualbox: rollback)

(terminal)

    $ knife prepare ubuntu@ip $ knife cook ubuntu@ip

(chrome: ip)

Now if we open that IP again, we have Nginx just as we did before with the same
configuration.

And that's it! We'll go over more of the details in upcoming sceencasts, but
hopefully this is enough to get you started exploring chef for your own
servers. Thanks for watching!
