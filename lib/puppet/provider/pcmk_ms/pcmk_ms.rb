require File.dirname(__FILE__) + '/../../../puppet/provider/pacemaker.rb'
require 'rexml/document'

Puppet::Type.type(:pcmk_ms).provide(:pcmk_ms, :parent => Puppet::Provider::Pacemaker) do 
  desc 'Pacmaker resource ms provider'

  optional_commands :crm => '/usr/sbin/crm'

  def self.instances(res_name)
    instances = []
    if res_name
      cmd = crm 'configure', 'show', 'xml', res_name
    else
      cmd = crm 'configure', 'show', 'xml'
    end
    xml = REXML::Document.new(cmd)

    basepath = "//cib/configuration/resources/master"
    REXML::XPath.each(xml, basepath) do |e|
      name = e.attributes['id']
      resource = REXML::XPath.first(xml, basepath + "[@id='#{name}']/primitive").attributes['id']
      if master_max = REXML::XPath.first(xml, basepath + "[@id='#{name}']/meta_attributes/nvpair[@id='#{name}-meta_attributes-master-max']")
        master_max = REXML::XPath.first(xml, basepath + "[@id='#{name}']/meta_attributes/nvpair[@id='#{name}-meta_attributes-master-max']").attributes['value']
      end
      if master_node_max = REXML::XPath.first(xml, basepath + "[@id='#{name}']/meta_attributes/nvpair[@id='#{name}-meta_attributes-master-node-max']")
        master_node_max = REXML::XPath.first(xml, basepath + "[@id='#{name}']/meta_attributes/nvpair[@id='#{name}-meta_attributes-master-node-max']").attributes['value']
      end
      if clone_max = REXML::XPath.first(xml, basepath + "[@id='#{name}']/meta_attributes/nvpair[@id='#{name}-meta_attributes-clone-max']")
        clone_max = REXML::XPath.first(xml, basepath + "[@id='#{name}']/meta_attributes/nvpair[@id='#{name}-meta_attributes-clone-max']").attributes['value']
      end
      if clone_node_max = REXML::XPath.first(xml, basepath + "[@id='#{name}']/meta_attributes/nvpair[@id='#{name}-meta_attributes-clone-node-max']")
        clone_node_max = REXML::XPath.first(xml, basepath + "[@id='#{name}']/meta_attributes/nvpair[@id='#{name}-meta_attributes-clone-node-max']").attributes['value']
      end
      if notification = REXML::XPath.first(xml, basepath + "[@id='#{name}']/meta_attributes/nvpair[@id='#{name}-meta_attributes-notify']")
        notification = REXML::XPath.first(xml, basepath + "[@id='#{name}']/meta_attributes/nvpair[@id='#{name}-meta_attributes-notify']").attributes['value']
      end
      if globally_unique = REXML::XPath.first(xml, basepath + "[@id='#{name}']/meta_attributes/nvpair[@id='#{name}-meta_attributes-globally-unique']")
        globally_unique = REXML::XPath.first(xml, basepath + "[@id='#{name}']/meta_attributes/nvpair[@id='#{name}-meta_attributes-globally-unique']").attributes['value']
      end
      if target_role = REXML::XPath.first(xml, basepath + "[@id='#{name}']/meta_attributes/nvpair[@id='#{name}-meta_attributes-target-role']")
        target_role = REXML::XPath.first(xml, basepath + "[@id='#{name}']/meta_attributes/nvpair[@id='#{name}-meta_attributes-target-role']").attributes['value']
      end
      if REXML::XPath.first(xml, basepath + "[@id='#{name}']/meta_attributes/nvpair[@id='#{name}-meta_attributes-is-managed']")
        manage = REXML::XPath.first(xml, basepath + "[@id='#{name}']/meta_attributes/nvpair[@id='#{name}-meta_attributes-is-managed']").attributes['value']
      else
        manage = nil
      end

      property = {
        :name => name,
        :resource => resource,
        :master_max => master_max,
        :master_node_max => master_node_max,
        :clone_max => clone_max,
        :clone_node_max => clone_node_max,
        :notification => notification,
        :globally_unique => globally_unique,
        :target_role => target_role,
        :manage => manage
      }
      instances << new(property)
    end
    instances
  end

  def create
    debug 'Creating resource %s' % resource[:name]
    crm 'configure', 'ms', resource[:name], args
  end

  def destroy
    debug 'Destroying resource %s' % resource[:name]
    crm 'resource', 'stop', resource[:name]
    crm 'configure', 'delete', resource[:name]
  end

  def exists?
    debug 'Checking status of %s' % resource[:name]
    properties[:ensure] != :absent
  end

  def args
    debug 'Building args for %s' % resource[:name]
    puts resource[:resource]
    args = [
      resource[:resource],
      'meta',
      "master-max=\"#{resource[:master_max]}\"",
      "master-node-max=\"#{resource[:master_node_max]}\"",
      "clone-max=\"#{resource[:clone_max]}\"",
      "clone-node-max=\"#{resource[:clone_node_max]}\"",
      "notify=\"#{resource[:notification]}\"",
      "globally-unique=\"#{resource[:globally_unique]}\"",
      "target-role=\"#{resource[:target_role]}\""
    ]
    args
  end
end
