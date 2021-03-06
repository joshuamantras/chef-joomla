#
# Cookbook Name:: joomla
# Recipe:: mysql
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
#

include_recipe "mysql::ruby"
include_recipe "mysql::server"

mysql_connection_info = {
  :host     => 'localhost',
  :username => 'root',
  :password => node['mysql']['server_root_password']
}

template "/root/.my.cnf" do
  source "dotmy.cnf.erb"
  owner "root"
  group "root"
  mode "0600"
  variables ({
    :rootpasswd => node['mysql']['server_root_password']
  })
end

# Create Joomla Database
mysql_database node['joomla']['db']['database'] do
  connection mysql_connection_info
  action     :create
end

# Create Joomla Database User
mysql_database_user node['joomla']['db']['user'] do
  connection mysql_connection_info
  password   node['joomla']['db']['pass']
  action     :create
end

# Grant Joomla
node['joomla']['db']['network_acl'].each do |network|
  mysql_database_user node['joomla']['db']['user'] do
    connection    mysql_connection_info
    password      node['joomla']['db']['pass']
    database_name node['joomla']['db']['database']
    host          network
    privileges    [:all]
    action        :grant
  end
end
