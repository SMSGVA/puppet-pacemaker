require File.dirname(__FILE__) + '/../../../puppet/provider/pacemaker.rb'
require 'rexml/document'

Puppet::Type.type(:pcmk_colocation).provide(:pcmk_colocation, :parent => Puppet::Provider::Pacemaker) do 
  desc 'Pacmaker resource colocation provider'

  optional_commands :crm => '/usr/sbin/crm'

  def self.instances(res_name)
    instances = []
    if res_name
      cmd = crm 'configure', 'show', 'xml', res_name
    else
      cmd = crm 'configure', 'show', 'xml'
    end
    xml = REXML::Document.new(cmd)

    REXML::XPath.each(xml, '//cib/configuration/constraints/rsc_colocation') do |e|
      property = {
        :name      => e.attributes['id'],
        :score     => e.attributes['score-attribute'],
        :resources => [e.attributes['rsc'], e.attributes['with-rsc']]
      }
      instances << new(property)
    end
    instances
  end

  def create
    debug 'Creating resource %s' % resource[:name]
    crm 'configure', 'colocation', resource[:name], "#{resource[:score]}:", resource[:resources].join(' ')
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
