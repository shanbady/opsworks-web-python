apt_repository "python3" do
    uri 'http://ppa.launchpad.net/deadsnakes/ppa/ubuntu'
    components ['trusty main']
end


execute "update" do
    command 'sudo apt-get update'
end

package 'python3.6' do
    options '--force-yes'
    action :install
end

package 'python3.6-dev' do
    options '--force-yes'
    action :install
end

alternatives 'python-set-version-3' do
    link_name 'python3'
    path '/usr/bin/python3.6'
    priority 100
    action :install
end