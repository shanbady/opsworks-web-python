bash "set_release" do
  user "root"
  cwd "/tmp"
  code <<-EOH
    export DEPLOY_TARGET=$(sudo opsworks-agent-cli get_json | grep    "\"revision\":" | sed -E "s/\"revision\"\: \"(.*?)\",/\1/" | head -n 1 | sed "s/ //g")
    sudo opsworks-agent-cli get_json | grep    "\"revision\":" | sed -E "s/\"revision\"\: \"(.*?)\",/\1/" | head -n 1 | sed "s/ //g"
    echo "test"
    echo $DEPLOY_TARGET > /home/deploy/latest_release
  EOH
end