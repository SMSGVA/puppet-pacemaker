require File.dirname(__FILE__) + '/../../../puppet/provider/pacemaker.rb'
require 'rexml/document'

Puppet::Type.type(:pcmk_location).provide(:pcmk_location, :parent => Puppet::Provider::Pacemaker) do
  desc 'Pacmaker resource location provider'

  optional_commands :crm => '/usr/sbin/crm'
  
  def self.instances(res_name)
    instances = []
    if res_name
      cmd = crm 'configure', 'show', 'xml', res_name
    else
      cmd = crm 'configure', 'show', 'xml'
    end
    xml = REXML::Document.new(cmd)
    basepath = "//cib/configuration/constraints/rsc_location"
    REXML::XPath.each(xml, basepath) do |e| 
      name = e.attributes['id']
      resource = e.attributes['rsc'] 
      if REXML::XPath.first(xml, basepath + "[@id='#{name}']").attributes['score']
        score = REXML::XPath.first(xml, basepath + "[@id='#{name}']").attributes['score']
      else
        score = REXML::XPath.first(xml, basepath + "[@id='#{name}']/rule").attributes['score']
      end
      property = {
        :name => name,
        :resource => resource,
        :score => score,
      }
      if REXML::XPath.first(xml, basepath + "[@id='#{name}']/rule")
        if REXML::XPath.first(xml, basepath + "[@id='#{name}']/rule/expression").attributes['attribute']
          attribute = REXML::XPath.first(xml, basepath + "[@id='#{name}']/rule/expression").attributes['attribute']
          property[:attribute] = attribute
        end
        if REXML::XPath.first(xml, basepath + "[@id='#{name}']/rule/expression").attributes['operation']
          operation = REXML::XPath.first(xml, basepath + "[@id='#{name}']/rule/expression").attributes['operation']
          property[:operation] = operation
        end
        if REXML::XPath.first(xml, basepath + "[@id='#{name}']/rule/expression").attributes['value']
          value = REXML::XPath.first(xml, basepath + "[@id='#{name}']/rule/expression").attributes['value']
          property[:value] = value
        end
      end

      instances << new(property)
    end
    instances
  end

  def create
    debug 'Creating resource %s' % resource[:name]
    crm 'configure', 'location', resource[:name], args
  end

  def destroy
    debug 'Destroying resource %s' % resource[:name]
    crm 'configure', 'delete', resource[:name]
  end

  def exists?
    debug 'Checking status of %s' % resource[:name]
    properties[:ensure] != :absent
  end

  def args
    debug 'Building args for %s' % resource[:name]
    args = [
      resource[:resource],
#      'rule',
      "#{resource[:score]}:",
      resource['node'],
#      resource['attribute'],
      resource['operation'],
      resource['value']
    ]
  end
end
