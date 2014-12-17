#
# Cookbook Name:: aem
# Recipe:: dispatcher
#
# Copyright 2012, Tacit Knowledge, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

node.default[:apache][:enable_default_site] = false

include_recipe "apache2"
include_recipe "apache2::mod_ssl"
include_recipe "apache2::mod_expires"

aem_dispatcher 'mod_dispatcher.so' do
  package_install          node[:aem][:use_yum]
  dispatcher_uri           node[:aem][:dispatcher][:mod_dispatcher_url]
  dispatcher_checksum      node[:aem][:dispatcher][:mod_dispatcher_checksum]
  dispatcher_version       node[:aem][:dispatcher][:version]
  dispatcher_file_cookbook node[:aem][:dispatcher][:dispatcher_file_cookbook]
  webserver_type           node[:aem][:dispatcher][:webserver_type]
  apache_libexecdir        node[:apache][:libexecdir] || node[:apache][:libexec_dir]
  action :install
end

#because apache_module does not create .load file for debian because they are normally installed with apt-get
if platform_family?('ubuntu', 'debian')
  file "#{node['apache']['dir']}/mods-available/dispatcher.load" do
      content "LoadModule dispatcher_module #{node['apache']['libexecdir']}/mod_dispatcher.so\n"
      mode    '0644'
    end  
end

#if we want to support non-apache, we'll need to do some more work here
apache_module "dispatcher" do
  #this will use the template mods/dispatcher.conf.erb
  conf true
end

farm_dir = "#{node[:aem][:dispatcher][:farm_dir]}"

directory farm_dir do
  owner "root"
  group node[:apache][:root_group]
  mode "0775"
  action :create
  recursive true
  not_if { ::File.exists?(farm_dir) }
end

#directory for sessionmanagement
directory "#{node[:apache][:dir]}/dispatcher/sessions" do
  owner node[:apache][:user]
  group node[:apache][:root_group]
  mode "0775"
  recursive true
  action :create
end

conf_dir = File.dirname("#{node[:aem][:dispatcher][:conf_file]}")
directory conf_dir do
  owner "root"
  group node[:apache][:root_group]
  mode "0775"
  action :create
  recursive true
  not_if { ::File.exists?(conf_dir) }
end

log_dir = File.dirname("#{node[:aem][:dispatcher][:log_file]}")
directory log_dir do
  owner "root"
  group node[:apache][:root_group]
  mode "0775"
  action :create
  recursive true
  not_if { ::File.exists?(log_dir) }
end

template "#{node[:aem][:dispatcher][:conf_file]}" do
  source "dispatcher.any.erb"
  owner "root"
  group node[:apache][:root_group]
  mode "0664"
  action :create
  notifies :restart, "service[apache2]"
end

#if we are including from another cookbook, we likely want to configure our own.
default_farm = node[:aem][:dispatcher][:farm_name]
aem_farm default_farm do
  action :add
end if default_farm

include_recipe "iptables"

iptables_rule "10apache" do
  source "iptables.erb"
end
