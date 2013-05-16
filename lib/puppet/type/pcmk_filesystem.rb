Puppet::Type.newtype(:pcmk_filesystem) do
  @doc = 'Type to manage Pacemaker Filesystem resources'

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

  newparam :device do
    desc 'Filesystem device'
  end

  newparam :directory do
    desc 'Filesystem mount directory'
  end

#  newparam :op_start do
#    desc 'Filesystem Start operation'
#  end
#
#  newparam :op_stop do
#    desc 'Filesystem Stop operation'
#  end
#
#  newparam :interval do
#    desc 'Filesystem operation interval'
#  end

  newparam :fstype do
    desc 'Filesystem Type'
  end

  newparam :target_role do
    desc 'Target Role of resource'
  end
end
