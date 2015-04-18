# This is a puppet manifest
# Run it with: puppet apply install_dependencies.pp

package { 'perl-Sys-Virt': ensure => present }
package { 'perl-Test-Simple': ensure => present }
package { 'perl-Text-Template': ensure => present }
package { 'perl-XML-Simple': ensure => present }
package { 'perl-YAML-Tiny': ensure => present }
  # Ubuntu: libyaml-tiny-perl

$szVirmanEtcDir            = hiera('VirmanEtcDir', '/etc/virman')
$szVirmanVarDir            = hiera('VirmanVarDir', '/var/virman')
$szVirmanBaseStorageDir    = hiera('VirmanBaseStorageDir', '/var/virman/basestorage')
$szVirmanInstanceCfgDir    = hiera('VirmanInstanceCfgDir', '/var/virman/instanceconfigs')
$szVirmanSshDir            = hiera('VirmanSshDir', '/var/virman/.ssh' )
$szVirmanCloudInitIsoFiles = hiera('VirmanCloudInitIsoFilesDir', '/var/virman/cloud_init_iso_files')
$szVirmanInstallWrapperDir = hiera('VirmanInstallWrapperDir', '/var/virman/install_wrappers')
$szVirmanQcowFilePoolPath  = hiera('VirmanQcowFilePoolPath', '/virt_images')


file { "$szVirmanVarDir": ensure => directory }
file { "$szVirmanBaseStorageDir": ensure => directory, require => File [ "$szVirmanVarDir" ] }
file { "$szVirmanInstanceCfgDir": ensure => directory, require => File [ "$szVirmanVarDir" ] }
file { "$szVirmanCloudInitIsoFiles": ensure => directory, require => File [ "$szVirmanVarDir" ] }
file { "$szVirmanInstallWrapperDir": ensure => directory, require => File [ "$szVirmanVarDir" ] }

file { "$szVirmanSshDir":
  ensure => directory,
  mode    => 640,
  require => File [ "$szVirmanVarDir" ],
}

file { "$szVirmanEtcDir": 
  ensure => directory,
}

file { "$szVirmanEtcDir/default.xml":
  content => template('/opt/virman/templates/etc_default_xml.erb'),
  require => File [ "$szVirmanEtcDir" ],
}

