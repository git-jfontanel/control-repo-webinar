# @summary This plan provisions Linux VM(s) in AWS
# 
# @param [TargetSpec] target 
#   The Terraform host used to deploy the VM(s)
# 
# @param [Enum['Gold', 'Silver', 'Bronze']] instance_type 
#   The instance type to be provisioned - Gold=t3.large Silver=t3.medium Bronze=t3.micro
# 
# @param [Enum['ubuntu-18.04', 'ubuntu-20.04']] os 
#   The operating System to be installed on the VMs
# 
# @param [Optional[Enum['francecentral','ukwest','uksouth']]] location 
#   The location where to provision the VM(s), by default francecentral
# 
# @param [String] name 
#   The name of the VM. If multiple VMs, the name will be incremented (ex: name1, name2,...)
# 
# @param [Optional[Enum['web-server', 'db-server']]] role 
#   The role of the server for Puppet classification
# 
# @param [Optional[Integer]] machines_count 
#   The number of VMs to deploy. By default only one
# 
# @param [Boolean]] autosigning 
#   Either to autosign or not the agent in PE
# 
plan cloud_provisioning::azure_deploy(
  Optional[TargetSpec]                                              $target         ='webinarnix0.se.automationdemos.com',
  Enum['Gold', 'Silver', 'Bronze']                                  $instance_type,
  Enum['ubuntu-18.04', 'ubuntu-20.04']                              $os,
  Optional[Enum['francecentral','ukwest','uksouth']]                $location       ='francecentral',
  String                                                            $name,
  Optional[Enum['web-server', 'db-server','']]                      $role           ='',
  Optional[Integer]                                                 $machines_count =1,
  Optional[Boolean]                                                 $autosigning    = false,
)
{
  $dir='/root/terraform/az'
  $domain="${location}.cloudapp.azure.com"

  # Preparing environment
  if $autosigning == true {
    $challengepassword = chomp(lookup(cloud_provisioning::challenge_password))
  } else {
    $challengepassword =''
  }

  run_task('cloud_provisioning::env_preparation', $target, 'Preparation of the environment ',
    name              => $name,
    dir               => $dir,
    instance_type     => $instance_type,
    os                => $os,
    machines_count    => $machines_count,
    region            => $location,
    role              => $role,
    challengepassword => $challengepassword,
  )

  # Terraform init
  run_task('terraform::initialize', $target, 'Run terraform init',
    dir => $dir
  )

  # Terraform apply
  $task = run_task('terraform::apply', $target, 'Run terraform apply',
    var   => {
      instance_type     => $instance_type,
      os                => $os,
      name              => $name,
      machines_count    => $machines_count,
      location          => $location,
      role              => $role,
      challengepassword => $challengepassword,
    },
    dir   => $dir,
    state => "${name}/${name}.tfstate",
  )
  $task.results[0]['stdout'].split('\n').each |$line| {
    if $line =~ '^Apply complete!' {
      return "Terraform: ${line}"
    }
  }


}
