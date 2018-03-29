require 'chef/log'
Chef::Log.level = :debug
revision = node["deploy"]["mc"]["scm"]["revision"]
impact_environment = node['deploy']['mc']['environment']['IMPACT_ENVIRONMENT']
docker_registry = node['deploy']['mc']['environment']['DOCKER_REGISTRY']
ecs_secret_access_key = node['deploy']['mc']['environment']['ECS_SECRET_ACCESS_KEY']
ecs_access_key_id = node['deploy']['mc']['environment']['ECS_ACCESS_KEY_ID']
script "set_release" do
  interpreter "bash"
  user "deploy"
  cwd "/srv/www/mc/current"
  environment node['deploy']['mc']['environment']
  code <<-EOH
    export DEPLOY_TARGET=#{revision}
    export IMPACT_ENVIRONMENT=#{impact_environment}
    export DOCKER_REGISTRY=#{docker_registry}
    export DOCKER_REGISTRY=#{docker_registry}
    export ECS_SECRET_ACCESS_KEY=#{ecs_secret_access_key}
    export ECS_ACCESS_KEY_ID=#{ecs_access_key_id}
    if [ -z "$IMPACT_ENVIRONMENT" ]; then 
    	echo "IMPACT_ENVIRONMENT not set. deploy skipped";
    else
        virtualenv --no-site-packages .venv && source .venv/bin/activate
        pip install ecs-deploy
        ecs deploy --ignore-warnings $IMPACT_ENVIRONMENT impact --image web $DOCKER_REGISTRY/impact-api:$DEPLOY_TARGET --image redis $DOCKER_REGISTRY/redis:$DEPLOY_TARGET --access-key-id $ECS_ACCESS_KEY_ID --secret-access-key $ECS_SECRET_ACCESS_KEY 2>/dev/null
     fi
  EOH
end
