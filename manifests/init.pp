# = Class: pacemaker
# This class manages pacemaker and it's configuration
# 
# == Parameters:
# See pacemaker subclasses for more info on each parameter.
#
# == Sample Usage:
# This class is used to manage the whole of pacemaker through a single interface. Calling the class without any parameters will setup pacemaker for use with corosync, without any resources:
#   class { 'pacemaker': }
#
# Resources can be configured from this class:
#   class { 'pacemaker':
#     vips => {
#       'vip1' => {
#         'ip'      => '33.33.33.13'
#         'cidr'    => '32',
#         'op'      => 'monitor',
#         'interval => '5s'
#       }
#     }
#   }

class pacemaker (
  $additional_agents      = false,
  $clones                 = {},
  $colocations            = {},
  $default_action_timeout = '30',
  $generic_daemons        = {},
  $locations              = {},
  $ms                     = {},
  $prms                   = {},
  $orders                 = {},
  $package                = $package,
  $quorum                 = $quorum,
  $resource_stickiness    = false,
  $service                = $service,
  $stonith                = $stonith,
  $symmetric_cluster      = $symmetric_cluster,
  $transport              = $transport,
  $vips                   = {}
) inherits pacemaker::defaults {

  pacemaker::anchor { "${module_name}::begin": }
  ->
  class { "${module_name}::package":
    package => $package
  }
  ->
  class { "${module_name}::agents":
    additional_agents => $additional_agents
  }
  ->
  class { "${module_name}::properties":
    default_action_timeout => $default_action_timeout,
    quorum                 => $quorum,
    resource_stickiness    => $resource_stickiness,
    stonith                => $stonith,
    symmetric_cluster      => $symmetric_cluster
  }
  ->
  class { "${module_name}::resources":
    clones          => $clones,
    colocations     => $colocations,
    generic_daemons => $generic_daemons,
    locations       => $locations,
    ms              => $ms,
    prms            => $prms,
    orders          => $orders,
    vips            => $vips
  }
  ->
  pacemaker::anchor { "${module_name}::end": }
}
