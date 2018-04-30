require 'chef/log'
Chef::Log.level = :debug
script "mount_volume" do
  interpreter "bash"
  user "deploy"
  cwd "/home/deploy"
  environment node['deploy']['mc']['environment']
  code <<-EOH
    mkdir /mnt/www/
    sudo ln -d /mnt/www/ /srv/www/
  EOH
end
