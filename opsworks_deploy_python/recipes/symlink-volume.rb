require 'chef/log'
Chef::Log.level = :debug
script "mount_volume" do
  interpreter "bash"
  user "deploy"
  cwd "/home/deploy"
  environment node['deploy']['mc']['environment']
  code <<-EOH
    cd /vol/www/
    mkdir mc
    cd /srv/www/
    if [ -d mc ]; then
      mv mc mc_bak
      ln -s /vol/www/mc/ mc
      mv mc_bak/current mc/current
      mv mc_bak/releases mc/releases
      mv mc_bak/shared mc/shared
      rm -r mc_bak
    else
      ln -s /vol/www/mc/ mc
    fi
  EOH
end
