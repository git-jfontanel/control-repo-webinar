# @summary This plan provisions Linux VM(s) in AWS
# 
# @param [TargetSpec] target 
#   The Terraform host used to deploy the VM(s)
# 
# @param [String] name 
#   The name of the VM. If multiple VMs, the name will be incremented (ex: name1, name2,...)
# 
plan cloud_provisioning::aws_destroy(
  Optional[TargetSpec]         $target='webinarnix0.se.automationdemos.com',
  String                       $name
)
{
  $dir='/root/terraform/aws'
  $domain='aws.tsedemos.com'
  $primary_server = 'puppet.se.automationdemos.com'

  # Find the number of machines to be decommissioned in PE
  $command = run_command("terraform -chdir=${dir} output -json -state=${dir}/${name}/${name}.tfstate | jq '.[] | .value | length'", $target, 'Check the number of VMs to destroy')
  $machines_count = $command.results[0]['stdout'].scanf('%d')[0]

  # Terraform destroy
  $task = run_task('terraform::destroy', $target, 'Run Terraform destroy',
    var_file => ["${dir}/terraform.tfvars", "${dir}/${name}/${name}.tfvars"],
    dir      => $dir,
    state    => "${name}/${name}.tfstate",
  )

  run_task('cloud_provisioning::remove_nodes_pe', $primary_server, 'Remove the nodes in PE',
    name           => $name,
    domain         => $domain,
    machines_count => $machines_count
  )

  $task.results[0]['stdout'].split('\n').each |$line| {
  if $line =~ '^Destroy complete!' {
    return "Terraform: ${line}"
  }
  }
}
