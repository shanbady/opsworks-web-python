require 'chef/log'
Chef::Log.level = :debug
revision = node["deploy"]["mc"]["scm"]["revision"]
script "set_release" do
  interpreter "bash"
  user "deploy"
  cwd "/srv/www/mc/current"
  code <<-EOH
    export DEPLOY_TARGET=#{revision}
    make deploy IMAGE_TAG=$DEPLOY_TARGET
  EOH
end