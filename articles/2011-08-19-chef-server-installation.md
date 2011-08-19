---
episode: 2
title: Chef Server Installation
date: 19/08/2011

Welcome back! This time we'll start in on Chef Server. It's a big topic, so we'll do this in two parts, in this first part we'll cover the installation then cover how to use it in the next episode.

<iframe width="425" height="349" src="http://www.youtube.com/embed/g_s8UFFowXI" frameborder="0" allowfullscreen></iframe>

~

# Prep

1. Make serverdemo kitchen
2. Prep VMWare VM, "Chef Server", upload keys, knife solo prepare
3. open slides
4. Move ~/.chef to ~/.chef.orig

# Script

(slide start)

Hi, I'm Mat Schaffer and welcome to DevOpsCasts where we go over topics that live in that nebulous space between development and operations.

(change)

Today we'll start in on Chef Server. As I mentioned last time, Chef Server is a larger, more scalable approach to using Chef.

(change)

Since Chef Server is a somewhat large topic, we'll be covering it in two parts. Today we'll do an overview of Chef Server and I'll show you how to install it.

(change)

Chef Server introduces another server to your architecture.

(change)

This is your Chef Server. And it serves as a central repository for cookbooks, recipes and other configuration information.

(change)

And your application servers will now have the chef-client daemon running on them.

(change)

Like last time, you'll develop your cookbooks on your local machine. But when we're finished, we'll use knife to upload them to the Chef server.

(change)

Since the chef-server and chef-client processes are in constant contract, the application servers will then pick up on the new cookbook and run through them in the same way we saw with chef solo.

(change)

Chef Server is especially useful if you have a large number of servers. With Chef Server you don't have to wait for each machine to run the recipes before moving on to the next one and tranfering cookbooks to the app servers is done for you.

(change)

It's also good if you have inter-dependent services. This is because Chef Server stores not only just cookbooks, but also serves as a system of record for configuration information. You can even search your infrastructure for nodes that serve certain roles or configuration. For example, your application recipe could search for any available database node and use that rather than hard-coding the database information in the recipe.

(change)

And finally it's useful in situations where you have multiple deployment
engineers. With Chef Solo you have to be careful to coordinate the
provisioning so that two people don't try to run cookbooks at the same
time. Since Chef Server runs cookbooks asynchronously, many people can
upload cookbooks as they work on them and the chef client daemon will
pick them up on the next run.

(virtualbox: ChefServer)

We'll be running Chef Server on this VM I have handy. I've already installed my ssh keys and prepare the box to run chef by using the "prepare" command from knife solo.

(overlay: knife prepare ubuntu@192.168.139.130)

I did this by running "knife prepare" and passing in the username and host of the VM. One thing to note is that I've also given this VM a bit more memory. Chef Server can be somewhat memory intensive as your cluster grows so I recommend giving it at least 1 gigabyte of memory for testing and at least 2 for production work.

There are a number of ways to install Chef Sever including options that use OS-specific packages. Today we'll use the "bootstrap" method which uses Chef Solo to build the Chef Server.

(terminal: ssh ubuntu@192.168.139.130)

The first thing our server will need is a proper host name. To set it on a running system we can use the hostname command and make a matching entry in /etc/hosts. To persist it across reboots on ubuntu we also need to set the hostname in /etc/hostname.

    $ sudo hostname chef.devops.mashion.net
    $ sudo vi /etc/hosts
        -127.0.0.1 ubuntu*
        +192.168.139.130 chef.devops.mashion.net chef
    $ sudo bash -c 'hostname > /etc/hostname'

If you got it set right, you should see the full hostname when you run `hostname -f`.

    $ hostname -f

Now since we're using chef solo we'll need a node config

    $ vi chef.json
        {
          "run_list": [ "recipe[chef-server::rubygems-install]" ],
          "chef_server": {
            "server_url": "http://localhost:4000",
            "webui_enabled": true
          }
        }

The run list will include the chef-server rubygems-install recipe. And we'll set two attributes that tell chef the expected server url and that we want the chef web UI to be installed and available.

    $ sudo chef-solo -c /etc/chef/solo.rb -j ~/chef.json -r http://s3.amazonaws.com/chef-solo/bootstrap-latest.tar.gz

And now we'll run chef solo using that config and pulling our cookbooks from the S3. Note that this will take some time since it installs a lot of packages.

You may have noticed that I'm using VMWare Fusion today. The reason for this is that VirtualBox on Mac OS Lion seems to over-consume resources when running large apt-get installations. One way I've found to work around this is the cputhrottle tool for Mac OS. If you run into similar issues check the show notes for some information.

(cputhrottle info)

Download from [http://www.willnolan.com/cputhrottle/cputhrottle.html](http://www.willnolan.com/cputhrottle/cputhrottle.html)

    # Grab the PID of the VM called "Chef Server"
    $ VMPID=`ps ux | grep '[C]hef Server' | awk '{print $2}'`
    # Limit it to 80 percent of total CPU
    $ /path/to/cputhrottle $VMPID 80

(Configuring knife)

Now that Chef is installed we'll configure the root user's knife utility. We'll use the local knife tool to create certificates that we can use on our own laptop.

    $ sudo su -
    $ knife configure -i --defaults -r .

To verify that it was configured correctly, we'll run knife client list. The "ubuntu" entry here tells us that it was configured correctly and it can talk to the Chef server:

    $ knife client list

To create a knife client entry for myself I'll use the knife client create
command. The options here tell Chef to create and admin account with default
settings called 'mat'. And to place the private auth certificate into /tmp/mat.pem

    $ knife client create -a -n -f /tmp/mat.pem mat

(close ssh)

Now back on my computer I'll scp that key over to my .chef folder and configure my knife client.

    $ mkdir .chef
    $ scp ubuntu@192.168.139.130:/tmp/mat.pem .chef/

To configure our local client we'll use knife configure. The options here specify 'mat' as our chef user name. This matches the client we created back on the server. The path to the certificate we copied over. The URL to the chef server, which defaults to port 4000. And finally defaults for the rest.

    $ knife configure -u mat -k .chef/mat.pem -s http://192.168.139.130:4000 --defaults -r .

To test that we have it configured correctly we run knife client list as we did before.

    $ knife client list

When running Chef Server on VMs it's easy to run into clock synchronization problems. If you encounter an authentication error that mentions synchronizing your clock, go back to the server and run ntpdate to fix it.

    $ ssh ubuntu@192.168.139.130
    $ sudo ntpdate pool.ntp.org

The happens because the authenication mechanism in Chef only allows for 15 minutes of difference between the clocks on the two systems.

Now that our clocks are in sync we should be able to run knife client list back on our laptop without any problems.

    $ knife client list

(browser)

One more thing I'll mention before we finish is that we've also installed the Chef web UI. If we go to our chef server on port 4040, we'll get a nice Web UI for all of the functions we talked about here. The default password is in the sidebar. Just enter it here, give it a new password and you can then browse around your chef configuration this way too.

(client tab)

If we look at the Clients tab we can see the "mat" and "ubuntu" clients that we've created.

(slides)

And that's it for today. Next episode we'll go over how to hook up the chef-client daemon to this chef server and upload cookbooks so they get run on our app servers. Thanks for watching and see you next time!
