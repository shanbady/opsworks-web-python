require 'chef/log'
Chef::Log.level = :debug
script "set_permissions" do
  interpreter "bash"
  user "root"
  cwd "/home/deploy"
  code <<-EOC
    echo "set permissions for logging"
    echo "set permissions for logging" >> set-perms.txt
    sudo find /var/lib/aws/opsworks/chef/ -name "*.log" | xargs sudo chmod 777
  EOC
end