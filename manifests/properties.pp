# = Class: pacemaker::properties
# This class manages pacemaker properties via the crmproperty resource
# type (which relies on `crm configure properties`.
#
# == Parameters:
# $quorum:: Configure quorum policy. Possbile values are: 'ignore', 'freeze', 'stop', 'suicide'. Defaults to 'ignore' [String]
# $stonith:: Enable or disable stonith. Defaults to disabled. [String]
# $symmetric_cluster:: Start resources only when you set a location. Defaults to 'true' [String]
# $resource_stickiness:: Set default resource-stickiness value. [Integer]
#
# == Sample Usage:
# All parameters can be set from the main interface:
#   class { 'pacemaker':
#     stonith             => true,
#     quorum              => 'suicide',
#     resource_stickiness => '150',
#     symmetric_cluster   => false
#   }

class pacemaker::properties (
  $default_action_timeout,
  $quorum,
  $resource_stickiness,
  $stonith,
  $symmetric_cluster
) {
  
  pcmk_property { 'stonith-enabled':
    value  => $stonith
  }

  pcmk_property { 'no-quorum-policy':
    value  => $quorum
  }

  pcmk_property { 'symmetric-cluster':
    value  => $symmetric_cluster
  }

  if($resource_stickiness) {
    pcmk_rsc_defaults { 'resource-stickiness':
      value  => $resource_stickiness
    }
  }

  pcmk_property { 'default-action-timeout':
    value => $default_action_timeout
  }
}
