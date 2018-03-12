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
    opsworks-agent-cli get_json | grep    "\\"revision\\":" | sed -E "s/\\"revision\\"\\: \\"(.*?)\\",/\\1/" | head -n 1 | sed "s/ //g")
    echo $DEPLOY_TARGET >> /home/deploy/latest_release
  EOH
end