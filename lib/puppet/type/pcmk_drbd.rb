Puppet::Type.newtype(:pcmk_drbd) do
  @doc = 'Type to manage Pacemaker DRBD resources'

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

  newparam :op do
    desc 'DRBD operation'
  end

  newparam :interval do
    desc 'DRBD operation interval'
  end

  newparam :drbd_resource do
    desc 'DRBD Resource name'
  end

  newparam :target_role do
    desc 'Target Role of resource'
  end
end
