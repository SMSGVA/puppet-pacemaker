require 'puppet/provider/pacemaker'
require 'rexml/document'

Puppet::Type.type(:pcmk_vip).provide(:pcmk_vip, :parent => Puppet::Provider::Pacemaker) do 
  desc 'Pacemaker ocf::heartbeat:IPaddr2 provider'

  optional_commands({
    :crm          => '/usr/sbin/crm',
    :crmadmin     => '/usr/sbin/crmadmin',
    :crm_resource => '/usr/sbin/crm_resource'
  })

  def self.instances
    instances = []
    cmd = crm 'configure', 'show', 'xml'
    xml = REXML::Document.new(cmd)
    basepath = ["//cib/configuration/resources/primitive[@type='IPaddr2']", "//cib/configuration/resources/master/primitive[@type='IPaddr2']", "//cib/configuration/resources/clone/primitive[@type='IPaddr2']"]
    basepath.each do |path|
      begin
        REXML::XPath.each(xml, path) do |e|
          
          if ! name = e.attributes['id']
            next
          end

          ip = REXML::XPath.first(xml, path + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-ip']").attributes['value']
          cidr_netmask = REXML::XPath.first(xml, path + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-cidr_netmask']").attributes['value']
          nic = REXML::XPath.first(xml, path + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-nic']").attributes['value']
          if REXML::XPath.first(xml, path + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-clusterip_hash']")
            clusterip_hash = REXML::XPath.first(xml, path + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-clusterip_hash']").attributes['value']
          end
          op = REXML::XPath.first(xml, path + "[@id='#{name}']/operations/op").attributes['name']
          interval = REXML::XPath.first(xml, path + "[@id='#{name}']/operations/op").attributes['interval']
          
          property = {}
          property[:name] = name
          property[:ip] = ip
          property[:cidr_netmask] = cidr_netmask
          property[:nic] = nic
          if clusterip_hash
            property[:clusterip_hash] = clusterip_hash
          end
          property[:op] = op
          property[:interval] = interval

          instances << new(property)
        end
      end
    end
    instances
  end

  def create 
    debug 'Creating VIP %s' % resource[:name]
    crm 'configure', 'primitive', resource[:name], 'ocf:heartbeat:IPaddr2', 'params', args
  end

  def destroy
    debug 'Destroying resource %s' % resource[:name]
    crm 'resource', 'stop', resource[:name]
    crm 'configure', 'delete', resource[:name]
  end

  def exists?
    debug 'Checking existence of %s' % resource[:name]
    properties[:ensure] != :absent
  end

  def args
    debug 'Building args for %s' % resource[:name]
    args = []
    args << "ip=#{resource[:ip]}"
    args << "cidr_netmask=#{resource[:cidr]}"
    args << "nic=#{resource[:nic]}" if resource[:nic]
    args << "clusterip_hash=#{resource[:clusterip_hash]}" if resource[:clusterip_hash]
    args << "op"
    args << resource[:op]
    args << "interval=#{resource[:interval]}"
  end
end
