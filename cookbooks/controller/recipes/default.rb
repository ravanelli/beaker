#
# Cookbook:: controller
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.
#

include_recipe 'firewall::default'


firewall_rule 'http/https' do
  port     [80, 443, 8000, 69]
  command   :allow
end

firewall_rule 'ssh' do
  port     22
  command  :allow
end

['beaker-lab-controller', 'tftp', 'tftp-server', 'xinetd', 'dnsmasq'].each do |packages|
    package packages do
        action :install
    end
end

['tftp', 'xinetd', 'dnsmasq', 'beaker-proxy', 'beaker-watchdog',
'beaker-provision'  ].each do |services|
    execute services do
        command "chkconfig #{services} on"
    end
    service services do 
        action [:enable]
    end 
end

cookbook_file '/etc/dnsmasq.conf' do
  source 'dnsmasq.conf'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

cookbook_file '/etc/beaker/labcontroller.conf' do
  source 'labcontroller.conf'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

cookbook_file '/etc/beaker/power-scripts/lpar' do
  source 'lpar'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

cookbook_file '/usr/sbin/fence_lpar' do
  source 'fence_lpar'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

directory '/var/lib/tftpboot/boot/' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

cookbook_file '/var/lib/tftpboot/boot/grub2-BE-2.02-0.13.el7.ppc64.tar.gz' do
  source 'grub2-BE-2.02-0.13.el7.ppc64.tar.gz'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end


execute 'GRUB-set' do
    command 'cd /var/lib/tftpboot/boot &&
             tar -xzf /var/lib/tftpboot/boot/grub2-BE-2.02-0.13.el7.ppc64.tar.gz &&
             mv grub2-BE-2.02-0.13.el7.ppc64 grub2 &&
             cd grub2 &&
             echo exit > grub.cfg'
end 
