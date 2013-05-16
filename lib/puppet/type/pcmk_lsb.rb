Puppet::Type.newtype :pcmk_lsb do
  @doc = 'Type to manage Pacemaker lsb resources'

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
    desc 'Name of lsb resource'
    isnamevar
  end

  newparam :service do
    desc 'Name of initd script'
  end

  newparam :target_role do
    desc 'Target Role of resource'
  end

  newparam :monitor do
    desc 'Monitor interval'
  end
end
