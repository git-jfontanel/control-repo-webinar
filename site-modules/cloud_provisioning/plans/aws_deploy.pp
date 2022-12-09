# @summary This plan provisions Linux VM(s) in AWS
# 
# @param [TargetSpec] target 
#   The Terraform host used to deploy the VM(s)
# 
# @param [Enum['Gold', 'Silver', 'Bronze']] instance_type 
#   The isntance type to be provisioned Gold=t3.large Silver=t3.medium Bronze=t3.micro
# 
# @param [Enum['centos-7', 'centos-8', 'windows-2016', 'windows-2019']] os 
#   The operating System you want to provisionbe installed on the VMs
# 
# @param [Optional[Enum['eu-west-3','eu-west-2','eu-west-1']]] region 
#   The region where to provisioned the VM(s), by default eu-west-3
# 
# @param [String] name 
#   The name of the VM. If multiple VMs, the name will be incremented (ex: name1, name2,...)
# 
# @param [Optional[Enum['web-server', 'db-server']]] role 
#   The role of the server for Puppet classification
# 
# @param [Optional[Integer]] machines_count 
#   The number of VM to deploy. By default only one
# 
# @param [Boolean]] autosigning 
#   Either to autosign or not the agent in PE
# 
plan cloud_provisioning::aws_deploy(
  Optional[TargetSpec]                                              $target         ='webinarnix0.se.automationdemos.com',
  Enum['Gold', 'Silver', 'Bronze']                                  $instance_type,
  Enum['centos-7', 'centos-8', 'windows-2016', 'windows-2019']      $os,
  Optional[Enum['eu-west-3','eu-west-2','eu-west-1']]               $region         ='eu-west-3',
  String                                                            $name,
  Optional[Enum['web-server', 'db-server','']]                      $role           ='',
  Optional[Integer]                                                 $machines_count =1,
  Optional[Boolean]                                                 $autosigning    = false,
)
{
  $dir='/root/terraform/aws'
  $domain='aws.tsedemos.com'

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
    region            => $region,
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
      region            => $region,
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
