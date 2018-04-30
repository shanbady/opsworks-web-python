name "impact_deploy"
version "0.1.0"


recipe 'impact_deploy', 'deploys a version of the impact api that has the same release tag being deployed to accelerate'
recipe 'impact_deploy::mount_volume', 'create a symlink to EBS volume'
