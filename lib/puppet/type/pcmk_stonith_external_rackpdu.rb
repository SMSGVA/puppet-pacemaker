Puppet::Type.newtype :pcmk_stonith_external_rackpdu do
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

  newparam :hostlist do
    desc 'The list of hosts that the STONITH device controls (comma or space separated).
If you set value of this parameter to AUTO, list of hosts will be get from Rack PDU device.'
  end

  newparam :pduip do
    desc 'Name or IP address of Rack PDU device.'
  end

  newparam :community do
    desc 'Name of write community'
  end

  newparam :oid do
    desc 'The SNMP OID for the PDU. minus the outlet number.
    Try .1.3.6.1.4.1.318.1.1.12.3.3.1.1.4 (default value)
    or use mib from ftp://ftp.apcc.com/apc/public/software/pnetmib/mib/
    Varies on different APC hardware and firmware.
    Warning! No dot at the end of OID'
  end

  newparam :names_oid do
    desc 'The SNMP OID for getting names of outlets.
    It is required to recognize outlet number by nodename.
    Try ".1.3.6.1.4.1.318.1.1.12.3.3.1.1.2" (default value)
    or use mib from ftp://ftp.apcc.com/apc/public/software/pnetmib/mib/
    Names of nodes must be equal names of outlets, in other way use outlet_config parameter.
    If you set \'names_oid\' parameter then parameter outlet_config must not be use.
    Varies on different APC hardware and firmware.
    Warning! No dot at the end of OID'
  end

  newparam :outlet_config do
    desc 'Configuration file. Other way to recognize outlet number by nodename.
    Configuration file which contains
    node_name=outlet_number
    strings.

    Example:
    server1=1
    server2=2

    If you use outlet_config parameter then names_oid parameter can have any value and it is not uses.'
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
