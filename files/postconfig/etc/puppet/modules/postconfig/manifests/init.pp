# == Class: postconfig
#
# Full description of class postconfig here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { postconfig:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2015 Your name here, unless otherwise noted.
#
class postconfig {

$arStaticNetconfigList = hiera('staticnetconfig', {})
$arDynamicNetconfigList   = hiera('dynamicnetconfig', {})


define implement_staticnetconfig($nic_name, $ip_addr, $netmask) {
  network::if::static { "$nic_name":
    ensure    => 'up',
    ipaddress => "$ip_addr", 
    netmask   => "$netmask",
  }    
}

define implement_dynamicnetconfig($nic_name) {
  network::if::dynamic { "$nic_name":
    ensure    => 'up',
  }    
}

$arStaticKeys = keys($arStaticNetconfigList)
if size($arStaticKeys) > 0 {
  create_resources( implement_staticnetconfig, $arStaticNetconfigList )
}

$arDynamicKeys = keys($arDynamicNetconfigList)
if size($arDynamicKeys) > 0 {
  create_resources( implement_dynamicnetconfig, $arDynamicNetconfigList )
}


}

