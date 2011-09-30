#
# Cookbook Name:: reconnoiter
# Recipe:: default
#
# Copyright 2011, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

dependencies = %w(autoconf build-essential git-core
                  zlib1g-dev uuid-dev libpcre3-dev libssl-dev libpq-dev
                  libxslt-dev libapr1-dev libaprutil1-dev xsltproc
                  libncurses5-dev python libssh2-1-dev libsnmp-dev
                  libprotobuf-c0-dev
                  openjdk-6-jdk)

dependencies.each do |dependency|
  package dependency
end

git "/usr/local/src/reconnoiter" do
  repository "git://github.com/omniti-labs/reconnoiter.git"
  reference "master"
  action :sync
end

bash "build and install reconnoiter" do
  cwd "/usr/local/src/reconnoiter"
  code <<-BASH
    autoconf
    ./configure
    make
    make install
  BASH
  action :nothing
  subscribes :run, resources("git[/usr/local/src/reconnoiter]"), :immediately
end
