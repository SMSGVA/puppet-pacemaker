require 'puppet/provider/pacemaker'
require 'rexml/document'

Puppet::Type.type(:pcmk_property).provide(:pcmk_property, :parent => Puppet::Provider::Pacemaker) do
  desc 'Pacemaker property provider'

  optional_commands :crm => '/usr/sbin/crm'

  mk_resource_methods

  def self.instances(res_name)
    instances = []
    if res_name
      cmd = crm 'configure', 'show', 'xml', res_name
    else
      cmd = crm 'configure', 'show', 'xml'
    end
    xml = REXML::Document.new(cmd)
   
    REXML::XPath.each(xml, "//cib/configuration/crm_config/cluster_property_set/nvpair") do |element|
      property = {
        :name => element.attributes['name'],
        :value => element.attributes['value']
      }
      instances << new(property)
    end
    instances
  end

  def create
    debug 'Creating resource %s' % resource[:name]
    crm 'configure', 'property', "#{resource[:name]}=#{resource[:value]}"
  end

  def destroy
    debug 'Destroying property %s' % resource[:name]
    debug 'No destroy for you!'
  end

  def exists?
    debug 'Checking status of %s' % resource[:name]
    properties[:ensure] != :absent
  end

  def value=(value)
    debug 'Changing value of %s' % resource[:name]
    crm 'configure', 'property', "#{resource[:name]}=#{value}"
  end
end
