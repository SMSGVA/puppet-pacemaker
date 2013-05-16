Puppet::Type.newtype :pcmk_stonith_external_ipmi do
  @doc = 'Type to manage Pacemaker STONITH resources'

  ensurable do
    newvalue :present do
      provider.create
    end

    newvalue :absent do
      provider.destroy
    end

    defaultto :present
  end

  newparam :name do
    desc 'Name of STONITH resource'
    isnamevar
  end

  newparam :hostname do
    desc 'List of hosts this resource can manage'
  end

  newparam :ipaddr do
    desc 'The IP address of the STONITH device.'
  end

  newparam :userid do
    desc 'The username used for logging in to the STONITH device.'
  end

  newparam :passwd do
    desc 'The password used for logging in to the STONITH device.'
  end

  newparam :passwd_method do
    desc 'Method for passing the passwd parameter to ipmitool
param: pass as parameter (-P)
env:   pass via environment (-E)
file:  value of "passwd" is actually a file name, pass with (-f)'
  end

  newparam :interface do
    desc 'IPMI interface to use, such as "lan" or "lanplus".'
  end

  newparam :priv do
    desc 'The privilege level of the user, for instance OPERATOR. If
unspecified the privilege level is ADMINISTRATOR. See
ipmitool(1) -L option for more information.'
  end

  newparam :ipmitool do
    desc 'Specify the full path to IPMI command.'
  end

  newparam :stonith_timeout do
      desc 'How long to wait for the STONITH action to complete.
Overrides the stonith-timeout cluster property'
  end

  newparam :priority do
    desc 'Priority of resource'
  end

  newparam :start do
    desc  'Start timeout'
  end

  newparam :stop do
    desc 'Stop timeout'
  end

  newparam :status do
    desc 'Status timeout'
  end

  newparam :monitor do
    desc 'Monitor interval'
  end

  newparam :monitor_timeout do
    desc 'Monitor timeout'
  end

  newparam :pcmk_host_argument do
    desc 'Advanced use only: An alternate parameter to supply instead of \'port\'
Some devices do not support the standard \'port\' parameter or may provide additional ones.
Use this to specify an alternate, device-specific, parameter that should indicate the machine to be fenced.
A value of \'none\' can be used to tell the cluster not to supply any additional parameters.'
  end

  newparam :pcmk_host_map do
    desc 'A mapping of host names to ports numbers for devices that do not support host names.
    Eg. node1:1;node2:2,3 would tell the cluster to use port 1 for node1 and ports 2 and 3 for node2'
  end

  newparam :pcmk_host_list do
    desc' A list of machines controlled by this device (Optional unless pcmk_host_check=static-list).'
  end

  newparam :pcmk_host_check do
    desc 'How to determine which machines are controlled by the device.
    Allowed values: dynamic-list (query the device), static-list (check the pcmk_host_list attribute), none (assume every device can fence every machine)'
  end

  newparam :pcmk_reboot_action do
    desc 'Advanced use only: An alternate command to run instead of \'reboot\'
    Some devices do not support the standard commands or may provide additional ones.
    Use this to specify an alternate, device-specific, command that implements the \'reboot\' action.'
  end

  newparam :pcmk_poweroff_action do
    desc 'Advanced use only: An alternate command to run instead of \'poweroff\'
    Some devices do not support the standard commands or may provide additional ones.
    Use this to specify an alternate, device-specific, command that implements the \'poweroff\' action.'
  end

  newparam :pcmk_list_action do
    desc 'Advanced use only: An alternate command to run instead of \'list\'
    Some devices do not support the standard commands or may provide additional ones.
    Use this to specify an alternate, device-specific, command that implements the \'list\' action.'
  end

  newparam :pcmk_monitor_action do
    desc 'Advanced use only: An alternate command to run instead of \'monitor\'
    Some devices do not support the standard commands or may provide additional ones.
    Use this to specify an alternate, device-specific, command that implements the \'monitor\' action.'
  end

  newparam :pcmk_status_action do
    desc 'Advanced use only: An alternate command to run instead of \'status\'
    Some devices do not support the standard commands or may provide additional ones.
    Use this to specify an alternate, device-specific, command that implements the \'status\' action.'
  end
end
