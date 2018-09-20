require 'chef/log'
Chef::Log.level = :debug
script "mount_volume" do
  interpreter "bash"
  user "root"
  cwd "/home/deploy"
  environment node['deploy']['mc']['environment']
  code <<-EOH
    bin/django algolia_clearindex && bin/django algolia_reindex
  EOH
end
