require File.dirname(__FILE__) + '/../../../puppet/provider/pacemaker.rb'
require 'rexml/document'

Puppet::Type.type(:pcmk_rsc_defaults).provide(:pcmk_rsc_defaults, :parent => Puppet::Provider::Pacemaker) do
  desc 'Pacemaker resource defaults provider'

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

    REXML::XPath.each(xml, "//cib/configuration/rsc_defaults/meta_attributes/nvpair") do |element|
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
    crm 'configure', 'rsc_defaults', "#{resource[:name]}=#{resource[:value]}"
  end

  def destroy
    debug 'Destroying resource %s' % resource[:name]
    debug 'No destroy for you!'
  end

  def exists?
    debug 'Checking status of %s' % resource[:name]
    properties[:ensure] != :absent
  end

  def value=(value)
    debug 'Changing value of %s' % resource[:name]
    crm 'configure', 'rsc_defaults', "#{resource[:name]}=#{value}"
  end
end
