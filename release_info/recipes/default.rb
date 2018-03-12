require 'chef/log'
Chef::Log.level = :debug
revision = node[:deploy][:mc][:scm][:revision]
script "set_release" do
  interpreter "bash"
  user "root"
  cwd "/tmp"
  code <<-EOH
    export DEPLOY_TARGET=#{revision}
    echo "test"
    echo $DEPLOY_TARGET >> /home/deploy/latest_release
  EOH
end