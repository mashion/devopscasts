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
                  libprotoc-dev
                  protobuf-compiler
                  openjdk-6-jdk)

dependencies.each do |dependency|
  package dependency
end

cookbook_file "/usr/local/src/protobuf-c-0.15.tar.gz"

bash "install protobuf-c-0.15" do
  cwd "/usr/local/src"
  code <<-BASH
    tar -zxf protobuf-c-0.15.tar.gz
    cd protobuf-c-0.15
    ./configure
    make
    make install
  BASH
  action :nothing
  subscribes :run, resources("cookbook_file[/usr/local/src/protobuf-c-0.15.tar.gz]"), :immediately
end

git "/usr/local/src/reconnoiter" do
  repository "git://github.com/omniti-labs/reconnoiter.git"
  # master as of Fri Sep 30 03:56:25 UTC 2011
  reference "623e0ea7c0460f481fea40517710c30ab62914fc"
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
