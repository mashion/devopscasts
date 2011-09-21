---
episode: 3
title: Chef Server Usage
date: 20/09/2011

Welcome back! Sorry for delay in getting this episode out. I'm currently on vacation overseas so it's taken a bit more time to prepare everything.

In todays episode we'll go over how to upload cookbooks to your Chef Server as well as connect and provision a node. This episode is a continuation of our [last episode](/2011/08/19/chef-server-installation) so you'll want to follow along with that before trying out this one.

<iframe width="425" height="349" src="http://www.youtube.com/embed/g_s8UFFowXI" frameborder="0" allowfullscreen></iframe>

~

# Prep

1. Chef server VM at "Pre Part 2" snapshot
2. Move ~/.chef to ~/.chef.orig
3. Copy ~/.chef.part1 to ~/.chef
4. open slides

# Script

(slide start)

Hi, I'm Mat Schaffer and welcome to DevOpsCasts where we go over topics that help tear down the wall between development and operations.

(change)

Previously on DevOpsCasts we talked about Chef Server. If you followed along you should now have a functioning Chef Server that we'll build on in this episode.

(change)

Now we're in Part 2 where we'll talk about how to upload cookbooks to your Chef Server and attach application nodes so that they can run your cookbooks and provision themselves on demand. So let's get to it.

(terminal)

    $ knife client list

First, run a quick knife client list to make sure you can talk to your chef server. If you have any trouble getting a list back, you may need to debug a bit. One common problem that we saw last time was clock skew, so make sure your laptop and server are in sync with a time server.

(overlap: sudo ntpdate pool.ntp.org)

Remember we used the ntpdate command to fix the the clock.

(terminal)

    $ vi ~/.chef/knife.rb
    # show chef server URL

If you still can't get a list, check your knife.rb. If you're running Chef on a VM, double check that the server URL is correct. Some VMs will rotate IP addresses between boots.

(overlay: mat@mashion.net)

If you're still having trouble, feel free to email me or comment on the show notes.

(browser: https://github.com/opscode/chef-repo)

(terminal)

    $ git clone https://github.com/opscode/chef-repo.git devopscasts
    $ cd devopscasts

First we'll need space to keep our cookbooks. When using chef server we'll use the Opscode chef-repo as a base. This allows us to use some built-in knife commands to manage our cookbooks and their dependencies.

(browser: opscode mysql cookbook page)

In this episode we'll be installing a mysql server. We'll use the off-the-shelf mysql cookbook this time instead of writing our own. This is a much more complex cookbook than the nginx cookbook we wrote in episode 1 so it'll serve as a good base for upcoming screencasts on the more advanced features of chef.

(terminal)

    $ knife cookbook site install mysql -o `pwd`/cookbooks
    $ ls cookbooks

Knife comes with a built in tool for downloading these cookbooks. The command to run here is knife cookbook site install mysql and we specify the dash-O option with the full path to the cookbooks folder. This will download the mysql cookbook from opscode as well as the cookbooks it depends on. In this case there's only one cookbook dependency, openssl. The mysql cookbook uses the openssl cookbook to generate random secure passwords for the mysql server.

(terminal)

    $ vi ~/.chef/knife.rb
      cookbook_path [ '/Users/mat/devopscasts/cookbooks' ]

To avoid setting the cookbook path every time we run a command, we can change the cookbook path listed in knife.rb.

We can use these cookbooks as-is, so next we'll upload them to the chef server using the knife cookbook upload command.

    $ knife cookbook upload mysql -d

Here we specify the dash-D option so that the openssl dependency will also be uploaded.

Now that we've uploaded the cookbooks we'll attach a node to this chef server that we can run them on. I have another VM ready here but it hasn't been prepared yet.

    $ ssh ubuntu@192.168.139.132
    $ sudo hostname mysql
    $ sudo vi /etc/hosts
        192.168.139.132 mysql mysql.devops.mashion.net
    $ hostname -f

Like we did with our Chef server, we'll set the hostname first. Chef uses host names as the unique identifier for each node so it's important to set this early on. While you can change the host name later it's somewhat involed, so better to have it set right from the beginning.

The last gotcha before we bootstrap our host is that we'll also need the validation key from our chef server so we can upload it to our new node. This key is used by the node to ensure it's talking to the expected chef server.

    $ ^D
    $ ssh ubuntu@192.168.139.130
    $ sudo cat /etc/chef/validation.pem

We'll do this simply by copying the text and pasting it into a file in our local chef directory.

    $ ^D
    $ vi ~/.chef/validation.pem
    $ vi ~/.chef/knife.rb
      validation_key '/Users/mat/.chef/validation.pem'

Then we fix our knife.rb to reference the file we've just created

    $ knife bootstrap -x ubuntu -P ubuntu -d ubuntu10.04-gems --sudo -r 'recipe[mysql::server]' 192.168.139.132

Now to prepare the node for running Chef server recipes we'll use the knife bootstrap command. This command is provided with Chef. It's a little less automatic than the knife prepare command that comes with the knife solo gem, but it works in a way that fits a bit more closely with Chef Server.

The first arguments are my username and password followed by the dash-D option which tells the bootstrap command what distro I'm using and how I'd like to install chef. In this case it's ubuntu using rubygems to install chef. The sudo argument tells knife to preface any commands with sudo since the ubuntu user doesn't have root privileges.

The bootstrap command will install the components necessary to run Chef, configure the node to talk to the same server in our local knife config and set up a node configuration that includes the mysql server recipe.

    $ knife node list

Once this is done we can run knife node list and see the node we just set up in the list.

Now let's try connecting to our new mysql server.

    $ ssh ubuntu@192.168.139.132
    $ mysql -u root

As you can see, we need a password to connect. That password was generated randomly and stored safely in Chef's node database.

    $ ^D
    $ knife node show mysql -m

To access it we use the knife node command with the dash-M option to show normal attribute data. This will show us the node data that was created during a recipe run but skip all the system information that was discovered by ohai.

So here's our password which I'll copy so we can connected to our server.

    $ ssh ubuntu@192.168.139.132
    $ mysql -u root -p

And now we're in. Normally you won't need to copy and paste this around since you can access that data from inside the chef recipes. We'll talk more about how to do that in later episodes.

Let's say we want to make a change a configuration setting on mysql, for example the max allowed packet size. Since our configuration is controlled by chef now, we'll look in our mysql cookbook to see how it's getting set up.

(redcar, cookbooks/mysql)

In the mysql cookbook directory there's a templates/default folder that contains the my.cnf.erb that gets used to generate the mysql configuration on the server.

(redcar, cookbooks/mysql/templates/default/my.cnf.erb)
Show line 141

We can see here that the max allowed packet size gets set from the mysql tunable max allowed packet node attribute.

(redcar, cookbooks/mysql/attributes)

The default values for node attributes are read from the attributes file that matches the recipe we ran on this node. In this case server.rb.

(redcar, cookbooks/mysql/attributes/server.rb)
Show line 45

If we scroll down to find the max packet size, we can see the default here is 16MB. Now we could change it here, but that would increase the size for any node we used this cookbook on. I'd rather have this parameter default to 16MB but be 32MB on our new mysql node.

(terminal)
    $ knife node edit mysql

To do that we can use the knife node edit command. This will open the node configuration file in our preferred editor. For me this is vim.

(overlay: export EDITOR=vim)

To set your editor place a line like this in your bashrc or local user profile.

(vim)

    "tunable": {
      "max_allowed_packet": "32MB"
    }

Now in the mysql section, we can add the tunable max allowed packet attribute, save and quit the editor and the node configuration will be fixed the next time chef runs. Now we could use the knife ssh command to explicitly invoke the chef client on our node. But that's not nearly as much fun as having our node continuously update itself.

To set up our node to continuously update itself we'll need to install the chef client. Of course, there's a cookbook for this.

(terminal)

    $ knife cookbook site install chef-client
    $ knife cookbook upload chef-client -d

We'll use knife again to download it from opscode and upload it to our own chef server.

    $ knife node edit mysql

Then we'll use the knife node edit command to add the chef-client recipe to the node's run list.

    # Add chef-client to run list
    # Add attributes
      "chef_client": {
        "interval": "5"
      }

Now by default the chef client checks in once every half hour. For this demo we'll set it to check in every 5 seconds. So we can see the effects of our work more quickly.

    $ knife ssh -m 192.168.139.132 -x ubuntu -P ubuntu sudo chef-client

And finally we'll use the knife ssh command to run the chef-client manually. The knife ssh command can also be used search for nodes and execute commands on all node of a given type, but we'd have to take a bit more time to properly set up DNS and SSH to allow for that. So today we'll just specify the host and authentication information manually.

    $ knife ssh -m 192.168.139.132 -x ubuntu -P ubuntu cat /etc/mysql/my.cnf | grep max

We can use knife ssh again to show that our max packet size has indeed been increased to 32MB.

    $ knife node edit mysql
    $ # Change max to 64MB

Now we can edit the node again and change it to 64 MB. If we wait 5 or so seconds, the chef client will come around again, find the updated configuration and update the max allowed packet size.

    $ knife ssh -m 192.168.139.132 -x ubuntu -P ubuntu cat /etc/mysql/my.cnf | grep max

Of course, this gets even more exciting as you add more nodes to your Chef server. But to really make use of it we'll have to cover a bit about how recipes, roles and attributes work together to coordinate nodes across your environment. So we'll save those topics for next time.

(keynote)

For our next episode I'm planning to take a break from Chef and talk about some monitoring packages that you can use to help make sure your environment is operating correctly. Of course if you have any feedback, feel free to leave a comment on the show notes.

Thanks for watching!
