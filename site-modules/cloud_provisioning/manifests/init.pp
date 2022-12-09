class cloud_provisioning::init(
  Sensitive[String] $aws_access_key_id      = undef,
  Sensitive[String] $aws_secret_access_key  = undef,
  Sensitive[String] $az_sub_id              = undef,
  String            $az_sub_user            = undef,
  Sensitive[String] $az_sub_tenant_id       = undef,
  Sensitive[String] $az_installation_id     = undef,
  Hash              $packages               ={}
)
{
  # Add azure cli repo
  yumrepo {'azure-cli':
    ensure  => 'present',
    name    => 'azure-cli',
    descr   => 'repo for azure-cli',
    baseurl => 'https://packages.microsoft.com/yumrepos/azure-cli',
    gpgkey  => 'https://packages.microsoft.com/keys/microsoft.asc',
    enabled => '1',
    target  => 'etc/yum.repo.d/azure-cli.repo'
  }

  yumrepo {'hashicorp':
    ensure  => 'present',
    name    => 'hashicorp',
    descr   => 'repo for hashicorp',
    baseurl => 'https://rpm.releases.hashicorp.com/RHEL/$releasever/$basearch/stable',
    gpgkey  => 'https://rpm.releases.hashicorp.com/gpg',
    enabled => '1',
    target  => 'etc/yum.repo.d/hashicorp.repo'
  }

  # install packages
  $packages.each |$pkg, $data| {
    package { $pkg:
      * => $data
    }
  }

  # Install awscli
  include awscli2

  # Configure aws credentials
  file { '/root/.aws':
    ensure => directory,
    mode   => '0700',
  }

  file { '/root/.aws/credentials':
    ensure  => present,
    mode    => '0600',
    content => epp('cloud_provisioning/aws_credentials.epp', {
      'aws_access_key_id'     => $aws_access_key_id,
      'aws_secret_access_key' => $aws_secret_access_key
    }),
    require => File['/root/.aws'],
  }

  # Configure az credentials
  file { '/root/.azure':
    ensure => directory,
    mode   => '0700',
  }

  file { '/root/.azure/azureProfile.json':
    ensure  => present,
    mode    => '0600',
    content => epp('cloud_provisioning/az_credentials.epp', {
      'az_sub_id'          => $az_sub_id,
      'az_sub_user'        => $az_sub_user,
      'az_sub_tenant_id'   => $az_sub_tenant_id,
      'az_installation_id' => $az_installation_id
    }),
    require => File['/root/.azure'],
  }

  # Configure Terraform directory for aws and az
  file { ['/root/terraform', '/root/terraform/aws', '/root/terraform/aws/templates', '/root/terraform/az', '/root/terraform/az/templates' ]:
    ensure => directory,
  }

  $tf_files_aws = ['main.tf', 'outputs.tf', 'security-group.tf', 'terraform.tfvars', 'variables.tf', 'vpc.tf']
  $tf_files_aws.each | String $file | {
    file { "/root/terraform/aws/${file}":
      ensure => present,
      source => "puppet:///modules/cloud_provisioning/aws/terraform/${file}",
    }
  }

  $tf_files_aws_tpl = ['init-lnx.tftpl', 'init-win.tftpl']
  $tf_files_aws_tpl.each | String $file | {
    file { "/root/terraform/aws/templates/${file}":
      ensure => present,
      source => "puppet:///modules/cloud_provisioning/aws/terraform/templates/${file}",
    }
  }

  $tf_files_az = ['main.tf', 'locals.tf', 'network.tf', 'outputs.tf', 'terraform.tfvars', 'variables.tf']
  $tf_files_az.each | String $file | {
    file { "/root/terraform/az/${file}":
      ensure => present,
      source => "puppet:///modules/cloud_provisioning/azure/terraform/${file}",
    }
  }

  $tf_files_az_tpl = ['init-lnx.tftpl']
  $tf_files_az_tpl.each | String $file | {
    file { "/root/terraform/az/templates/${file}":
      ensure => present,
      source => "puppet:///modules/cloud_provisioning/azure/terraform/templates/${file}",
    }
  }

  $tf_key = 'tf_key.pub'
  file { "/root/terraform/${tf_key}":
    ensure => present,
    source => "puppet:///modules/cloud_provisioning/${tf_key}",
  }


}
