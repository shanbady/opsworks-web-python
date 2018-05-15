name "impact_deploy"
version "0.1.0"


recipe 'impact_deploy', 'deploys a version of the impact api that has the same release tag being deployed to accelerate'
recipe 'impact_deploy::install_keys', 'injects ssh keys for users authorized on the associated opsworks stack into the ECS container instance'