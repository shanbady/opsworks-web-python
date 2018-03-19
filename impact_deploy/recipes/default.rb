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
    if [ -z "$IMPACT_ENVIRONMENT" ]; then 
    	echo "IMPACT_ENVIRONMENT not set. deploy skipped";
    else
        make impact-deploy IMAGE_TAG=$DEPLOY_TARGET;
     fi
  EOH
end
