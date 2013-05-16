# = Class: pacemaker::service
# This class manages the pacemaker service and the corosync
# service file
#
# == Parameters:
# $service:: Pacemaker service name [String]
# $corosync_service_file:: Pacemaker service file for corosync [String]
# $transport:: Pacemaker transport system [String]
#
# == Sample Usage
# You can override all parameters from the main interface:
#   class { 'pacemaker':
#     transport => 'heartbeat',
#     service   => 'pacemakerd'
#   }

class pacemaker::service (
  $service,
  $transport
) {
  
  service { $service:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Exec['pcmk-stack-restart']
  }

  exec { 'pcmk-stack-restart':
    #command     => "service pacemaker stop && service ${transport} restart && service pacemaker start",
    command => "service corosync restart",
    path    => ['/bin', '/sbin', '/usr/sbin'],
    onlyif  => "/usr/bin/test ! -e /var/run/pacemaker.pid",
  } 
}
