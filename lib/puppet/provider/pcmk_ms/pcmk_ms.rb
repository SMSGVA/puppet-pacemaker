require 'puppet/provider/pacemaker'
require 'rexml/document'

Puppet::Type.type(:pcmk_ms).provide(:pcmk_ms, :parent => Puppet::Provider::Pacemaker) do 
  desc 'Pacmaker resource ms provider'

  optional_commands :crm => '/usr/sbin/crm'

  def self.instances
    instances = []
    cmd = crm 'configure', 'show', 'xml'
    xml = REXML::Document.new(cmd)

    basepath = "//cib/configuration/resources/master"
    REXML::XPath.each(xml, basepath) do |e|
      name = e.attributes['id']
      resource = REXML::XPath.first(xml, basepath + "[@id='#{name}']/primitive").attributes['id']
      master_max = REXML::XPath.first(xml, basepath + "[@id='#{name}']/meta_attributes/nvpair[@id='#{name}-meta_attributes-master-max']").attributes['value']
      master_node_max = REXML::XPath.first(xml, basepath + "[@id='#{name}']/meta_attributes/nvpair[@id='#{name}-meta_attributes-master-node-max']").attributes['value']
      clone_max = REXML::XPath.first(xml, basepath + "[@id='#{name}']/meta_attributes/nvpair[@id='#{name}-meta_attributes-clone-max']").attributes['value']
      clone_node_max = REXML::XPath.first(xml, basepath + "[@id='#{name}']/meta_attributes/nvpair[@id='#{name}-meta_attributes-clone-node-max']").attributes['value']
      notification = REXML::XPath.first(xml, basepath + "[@id='#{name}']/meta_attributes/nvpair[@id='#{name}-meta_attributes-notify']").attributes['value']
      globally_unique = REXML::XPath.first(xml, basepath + "[@id='#{name}']/meta_attributes/nvpair[@id='#{name}-meta_attributes-globally-unique']").attributes['value']
      target_role = REXML::XPath.first(xml, basepath + "[@id='#{name}']/meta_attributes/nvpair[@id='#{name}-meta_attributes-target-role']").attributes['value']
      manage = REXML::XPath.first(xml, basepath + "[@id='#{name}']/meta_attributes/nvpair[@id='#{name}-meta_attributes-is-managed']").attributes['value']

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
