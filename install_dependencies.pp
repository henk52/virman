# This is a puppet manifest
# Run it with: puppet apply install_dependencies.pp

package { 'perl-Text-Template': ensure => present }
package { 'perl-XML-Simple': ensure => present }
package { 'perl-Sys-Virt': ensure => present }
