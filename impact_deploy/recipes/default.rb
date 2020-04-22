require 'chef/log'
Chef::Log.level = :debug
revision = node["deploy"]["mc"]["scm"]["revision"]
impact_environment = node['deploy']['mc']['environment']['IMPACT_ENVIRONMENT']
impact_service = node['deploy']['mc']['environment']['IMPACT_SERVICE']
docker_registry = node['deploy']['mc']['environment']['DOCKER_REGISTRY']
ecs_secret_access_key = node['deploy']['mc']['environment']['ECS_SECRET_ACCESS_KEY']
ecs_access_key_id = node['deploy']['mc']['environment']['ECS_ACCESS_KEY_ID']
ecs_default_region = node['deploy']['mc']['environment']['AWS_DEFAULT_REGION']
script "set_release" do
  interpreter "bash"
  user "deploy"
  cwd "/home/deploy"
  environment node['deploy']['mc']['environment']
  code <<-EOH
    # trigger a deploy of impact-api
    export DEPLOY_TARGET=#{revision}
    export IMPACT_ENVIRONMENT=#{impact_environment}
    export IMPACT_SERVICE=#{impact_service}
    export DOCKER_REGISTRY=#{docker_registry}
    export AWS_DEFAULT_REGION=#{ecs_default_region}
    export DOCKER_REGISTRY=#{docker_registry}
    export ECS_SECRET_ACCESS_KEY=#{ecs_secret_access_key}
    export ECS_ACCESS_KEY_ID=#{ecs_access_key_id}
    if [ -z "$IMPACT_ENVIRONMENT" ]; then 
    	echo "IMPACT_ENVIRONMENT not set. deploy skipped";
    else
        virtualenv .venv && source .venv/bin/activate
        pip install --upgrade certifi pyopenssl requests[security] ndg-httpsclient pyasn1 pip
        pip install ecs-deploy
        .venv/bin/ecs deploy --ignore-warnings $IMPACT_ENVIRONMENT $IMPACT_SERVICE --image web $DOCKER_REGISTRY/impact-api:$DEPLOY_TARGET --image redis $DOCKER_REGISTRY/redis:$DEPLOY_TARGET --access-key-id $ECS_ACCESS_KEY_ID --secret-access-key $ECS_SECRET_ACCESS_KEY --region $AWS_DEFAULT_REGION --timeout 600
        rm -rf .venv/
     fi
  EOH
end
