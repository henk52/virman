# == Class: gls
#
# Full description of class gls here.
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
#  class { gls:
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
class gls {

$arNetconfigList = hiera('netconfig')


define implement_netconfig($nic_name, $ip_addr, $netmask) {
  network::if::static { "$nic_name":
    ensure    => 'up',
    ipaddress => "$ip_addr", 
    netmask   => "$netmask",
  }    
}

create_resources( implement_netconfig, $arNetconfigList )


}
