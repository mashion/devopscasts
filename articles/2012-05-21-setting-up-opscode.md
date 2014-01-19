---
episode:
title: Setting up the OpsCode Chef
date: 05/21/2012

Welcome back, folks! Since things have settled down a bit, I thought it was time to re-start the DevopsCasts.

As a warm up, I'll be taking you through how to get set up on the Opscode hosted Chef platform. Since Opscode does most of the work for you, set up isn't particularly complicated, but I've seen a few common stumbling blocks that I'll help you through with this screencast.

~

# Prep

# Script

Hello everyone and welcome back to DevOpsCasts where we go over topics that help tear down the wall between development and operations.

In this episode, we'll go over how to get up and running with Opscode Chef and EC2. This pair of tools is a great combo that I've used a lot recently to help get projects rolling.

The Opscode Chef platform is the same Chef server that we've talked about before, but Opscode manages it for you so there's no machine to keep running or maintain. It's also free for up to 5 nodes. With EC2, you can create and destroy servers quickly and easily and as long as you terminate them when you're done you can do a lot of prototyping for less than your lunch probably cost you.

http://wiki.opscode.com/display/chef/Workstation+Setup

The first thing you'll need is a working Ruby environment and the Chef gem. Opscode has a "Workstation setup" wiki page that talks about how to do this on various operating systems. I'm using Windows today because Opscode ships a very nice one-click installer that makes getting your workstation set up very simple. Simply download the installer from the Opscode wiki and run it. To enable the knife edit commands you'll also want to set up an EDITOR environment variable. I have it set up here to use a copy of gvim I have installed, but you should be able to adjust this to fit your editor of choice.

Now we'll set up an OpsCode account. This account works a lot like a github account in that it can be used across many organizations and it's free to register. All the billing happens at the organization level. We'll go to manage.opscode.com and click the sign up link, fill out the signup form. You'll then have to click the link in the verification email to activate your account. Once you've verified your email, you'll need to reset your API key. This can be done on the change password tab of your profile page. Take this key and put it into a `.chef` directory in your home directory. And keep it safe. This key is what grants all your permissions on the opscode platform.

Next we'll create an organization. We can do this from the OpsCode platform's home page. Choose a unique name for your organization and select the free plan for now. Once you've created the organization you can download an organization key and knife configuration file. Put these with your user key.

At this point you should be able to run `knife client list` and see your organization's validator client. This client is used by knife when creating new nodes in your infrastructure. You won't need to do anything with it manually, but seeing it is a good way to know that your client is set up and you're attached to the right organization.

If you run into trouble check out the [Setup Opscode User and Organization](http://wiki.opscode.com/display/chef/Setup+Opscode+User+and+Organization) wiki page that walks through these same steps.

Next we'll spin up some nodes on EC2. So you'll need to set up an account on Amazon Web Services if you haven't already. Head to aws.amazon.com and click the "Sign up" link. Fill in your email address and click the "new user" radio option. Then fill in the rest of the sign up form. You'll also need to provide a credit card number here, but don't worry, what we're doing won't cost more than a couple of dollars which is well worth the experience gained. Finally AWS will have you verify your phone number by giving you a call and having you enter a PIN they provide.

Shortly after doing this you'll get an email with a link to download your access keys. Click that link and copy the Access Key ID below. Put this into the knife.rb file you downloaded from Opscode's site. And do the same thing with the secret access key.

    knife[:aws_access_key_id]     = "AKIAIX6HYA..."
    knife[:aws_secret_access_key] = "secret..."

This will let us manage our ec2 instances from knife, but first we'll need the knife-ec2 plugin. Install this by typing `gem install knife-ec2`.

We can make sure our setup is working by running `knife ec2 server list`. We won't see any servers yet, but the empty list means the connection is working.

Now before creating a server, we'll need to set up an ssh keypair. We'll go to the ec2 console to create one. I'll call it default. This will download a private key to your browser. I'll put it with my chef keys for now, but you may want to store it in your .ssh directory or project directory.

So let's create a server! To do this we run knife ec2 server create and pass an AMI ID for ubuntu 12.04, and tell knife to use the default keypair and key file we just set up.

    knife ec2 server create -I ami-3c994355 -d ubuntu12.04-gems -S default -i .chef/default.pem

http://wiki.opscode.com/display/chef/Fast+Start+Guide
