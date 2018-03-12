require 'chef/log'
Chef::Log.level = :debug
revision = node["deploy"]["mc"]["scm"]["revision"]
impact_environment = node['deploy']['mc']['environment']['IMPACT_ENVIRONMENT']
script "set_release" do
  interpreter "bash"
  user "deploy"
  cwd "/srv/www/mc/current"
  environment node['deploy']['mc']['environment']
  code <<-EOH
    export DEPLOY_TARGET=#{revision}
    make deploy IMAGE_TAG=$DEPLOY_TARGET
  EOH
end