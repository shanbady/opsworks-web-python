require 'chef/log'
Chef::Log.level = :debug
impact_environment = node['deploy']['mc']['environment']['IMPACT_ENVIRONMENT']
ecs_secret_access_key = node['deploy']['mc']['environment']['ECS_SECRET_ACCESS_KEY']
ecs_access_key_id = node['deploy']['mc']['environment']['ECS_ACCESS_KEY_ID']
ecs_default_region = node['deploy']['mc']['environment']['AWS_DEFAULT_REGION']
script "install_keys" do
  interpreter "bash"
  user "deploy"
  cwd "/home/deploy"
  environment node['deploy']['mc']['environment']
  code <<-EOH
    # trigger a deploy of impact-api
    echo "INSTALLING KEYS"
    export IMPACT_ENVIRONMENT=#{impact_environment}
    export AWS_DEFAULT_REGION=#{ecs_default_region}
    export ECS_SECRET_ACCESS_KEY=#{ecs_secret_access_key}
    export ECS_ACCESS_KEY_ID=#{ecs_access_key_id}
    export AWS_ACCESS_KEY_ID=#{ecs_access_key_id}
    export AWS_SECRET_ACCESS_KEY=#{ecs_secret_access_key}
    if [ -z "$IMPACT_ENVIRONMENT" ]; then 
    	echo "IMPACT_ENVIRONMENT not set. install keys skipped";
    else
        virtualenv --no-site-packages .venv && source .venv/bin/activate
        pip install awscli --upgrade
        .venv/local/bin/aws s3api get-object --bucket masschallenge-deployment --key secure/ecs-key.pem ~/.ssh/ecs-key.pem
        export ECS_PEM_FILE=~/.ssh/ecs-key.pem
        export ECS_INSTANCES=`.venv/local/bin/aws ecs list-container-instances --cluster $IMPACT_ENVIRONMENT | grep arn | cut -b 64-99 | xargs`
        export EC2INSTANCES=`.venv/local/bin/aws ecs describe-container-instances --container-instances $ECS_INSTANCES --cluster $IMPACT_ENVIRONMENT --query "containerInstances[].ec2InstanceId" --output text`
        export EC2_INSTANCE_IP=`.venv/local/bin/aws ec2 describe-instances --instance-ids $EC2INSTANCES --query "Reservations[].Instances[].PublicIpAddress" --output text`
        IFS=' ' read  -a users <<< $(aws opsworks --region us-east-1 describe-user-profiles --query "UserProfiles[].SshUsername" --output text)
        for user in ${users[@]}; do
              echo $user
              .venv/local/bin/aws iam list-ssh-public-keys --user-name "${user}" --query "SSHPublicKeys[?Status == 'Active'].[SSHPublicKeyId]" --output text | while read KeyId; do
              export SSHKEY=$(.venv/local/bin/aws iam get-ssh-public-key --user-name "${user}" --ssh-public-key-id "$KeyId" --encoding SSH --query "SSHPublicKey.SSHPublicKeyBody" --output text)
              echo "echo $SSHKEY >> /home/ec2-user/.ssh/authorized_keys" | ssh -i $ECS_PEM_FILE ec2-user@$EC2_INSTANCE_IP  /bin/bash
            done
        done
     fi
  EOH
end
