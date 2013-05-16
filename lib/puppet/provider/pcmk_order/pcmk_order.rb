require 'puppet/provider/pacemaker'
require 'rexml/document'

Puppet::Type.type(:pcmk_order).provide(:pcmk_order, :parent => Puppet::Provider::Pacemaker) do 
  desc 'Pacmaker resource order provider'

  optional_commands :crm => '/usr/sbin/crm'

  def self.instances(res_name)
    instances = []
    if res_name
      cmd = crm 'configure', 'show', 'xml', res_name
    else
      cmd = crm 'configure', 'show', 'xml'
    end
    xml = REXML::Document.new(cmd)

    REXML::XPath.each(xml, '//cib/configuration/constraints/rsc_order') do |e|
      property = {
        :name  => e.attributes['id'],
        :score => e.attributes['score'],
        :order => [e.attributes['first'], e.attributes['then']]
      }
      instances << new(property)
    end
    instances
  end

  def create
    debug 'Creating resource %s' % resource[:name]
    crm 'configure', 'order', resource[:name], "#{resource[:score]}:", resource[:order].join(' ')
  end

  def destroy
    debug 'Destroying resource %s' % resource[:name]
    crm 'configure', 'delete', resource[:name]
  end

  def exists?
    debug 'Checking status of %s' % resource[:name]
    properties[:ensure] != :absent
  end
end
