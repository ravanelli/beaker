#
# Cookbook:: beaker
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.
#

user 'beaker' do
    manage_home true
    comment 'User Beaker'
    home '/home/beaker'
    shell '/bin/bash'
    password 'beaker'
end

group 'wheel' do
    action :modify
    members 'beaker'
    append true
end

execute 'get_repo' do
    user 'root'
    command 'cd /etc/yum.repos.d/ && wget https://beaker-project.org/yum/beaker-server-RedHatEnterpriseLinux.repo'
end


['mariadb-server', 'mariadb', 'beaker-server', 'ansible', 'dnsmasq', 
'beaker-lab-controller', 'tftp', 'tftp-server', 'xinetd', 
'dnsmasq', 'python-itsdangerous', 'python-pygments', 'cracklib-python',
'python-webob', 'python-webtest', 'python-flask'].each do |packages|
    package packages do
        action :install
    end
end

['mariadb', 'beakerd', 'httpd', 'tftp', 'xinetd', 'dnsmasq', 'beaker-proxy', 'beaker-watchdog',
'beaker-provision' ].each do |services|
    execute services do
        command "chkconfig #{services} on"
    end
    service services do 
        action [:enable]
    end 
end

execute 'create_db' do
    user 'root'
    command 'echo "create database beaker ;" | mysql; echo "create user beaker ;" | mysql
    echo "grant all on beaker.* to beaker IDENTIFIED BY \'password\';"| mysql'
end

execute 'beaker-init' do
    command 'beaker-init -u admin -p password -e user@yourservername'
end 

cookbook_file '/etc/dnsmasq.conf' do
  source 'dnsmasq.conf'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

