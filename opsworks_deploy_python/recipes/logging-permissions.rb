require 'chef/log'
Chef::Log.level = :debug
script "set_permissions" do
  interpreter "bash"
  user "root"
  cwd "/home/deploy"
  code <<-EOC
    echo "set permissions for logging"
    sudo find /var/lib/aws/opsworks/chef/ -name "*.log" | xargs sudo chmod 555
  EOC
end