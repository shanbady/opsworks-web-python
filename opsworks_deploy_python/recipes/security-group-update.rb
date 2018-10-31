#
# Cookbook Name:: opsworks_deploy_python
# Recipe:: security-group-update
#
require 'chef/log'
Chef::Log.level = :debug

node[:deploy].each do |application, deploy|
    script "update-security-group" do
        interpreter "bash"
        user "root"
        cwd "/srv/www/mc/current"
        environment node['deploy']['mc']['environment']
        code <<-EOH
            # installed to stop a "InsecurePlatformWarning: A true SSLContext object is not available." warning
            # This prevents urllib3 from configuring SSL appropriately
            pip install pyOpenSSL ndg-httpsclient pyasn1 --no-cache-dir

            rds_address="$DJANGO_DB_HOST"
            security_group=$(bin/aws rds describe-db-instances --query "DBInstances[?Endpoint.Address=='${rds_address}'].DBSecurityGroups[0].DBSecurityGroupName" --output text)
            private_ip=$(hostname -I | xargs)
            security_group_exists=$(bin/aws rds  describe-db-security-groups --db-security-group-name ${security_group} --query "DBSecurityGroups[*].IPRanges[*].CIDRIP" --output json | grep "${private_ip}/32" | xargs )
            if [ -z "$security_group_exists" ]; then
                bin/aws rds authorize-db-security-group-ingress --db-security-group-name ${security_group} --cidrip "${private_ip}/32"
            fi
        EOH
    end
end
