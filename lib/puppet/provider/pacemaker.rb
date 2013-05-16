class Puppet::Provider::Pacemaker < Puppet::Provider
  # Prefetch our rule list. This is ran once every time before any other
  # action (besides initialization of each object).

  # Corosync takes a while to build the initial CIB configuration once the
  # service is started for the first time.  This provides us a way to wait
  # until we're up so we can make changes that don't disappear in to a black
  # hole.
  def self.ready?
    cmd =  [
      'crm_attribute',
      '--type',
      'crm_config',
      '--query',
      '--name',
      'dc-version'
    ]
    raw, status = Puppet::Util::SUIDManager.run_and_capture(cmd)
    if status == 0
      return true
    else
      return false
    end
  end

  def self.block_until_ready(timeout = 120)
    Timeout::timeout(timeout) do
      until ready?
        debug('Pacemaker not ready, retrying')
        sleep 2
      end
      # Sleeping a spare two since it seems that dc-version is returning before
      # It is really ready to take config changes, but it is close enough.
      # Probably need to find a better way to check for reediness.
      sleep 2
    end
  end

  # Look up the current status. This allows us to conventiently look up
  # existing status with properties[:foo].
  def properties
    if @property_hash.empty?
      @property_hash = query || {:ensure => :absent}
      @property_hash[:ensure] = :absent if @property_hash.empty?
    end
    @property_hash.dup
  end

  # Pull the current state of the list from the full list.  We're
  # getting some double entendre here....
  def query
    self.class.instances(self.name).each do |instance|
      if instance.name == self.name or instance.name.downcase == self.name
        return instance.properties
      end
    end
    nil
  end
end
