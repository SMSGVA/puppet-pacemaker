Puppet::Type.newtype(:pcmk_xen) do
  @doc = 'Type to manage Pacemaker Xen resources'

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
    desc 'Name of the resource'
    isnamevar
  end

#  newparam :op do
#    desc 'Xen operation'
#  end

  newparam :monitor do
    desc 'Monitor interval'
  end

  newparam :monitor_timeout do
    desc 'Monitor timeout'
  end

  newparam :stop do
    desc 'Stop interval'
  end

  newparam :stop_timeout do
    desc 'Stop timeout'
  end

  newparam :start do
    desc 'Start interval'
  end

  newparam :start_timeout do
    desc 'Start timeout'
  end

#  newparam :interval do
#    desc 'Xen operation interval'
#  end

  newparam :xmfile do
    desc 'DomU config file'
  end

  newparam :target_role do
    desc 'Target Role of resource'
  end

  newparam :allow_migrate do
    desc 'Allow resource migration'
  end
end
