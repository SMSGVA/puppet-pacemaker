require File.dirname(__FILE__) + '/../../../puppet/provider/pacemaker.rb'
require 'rexml/document'

Puppet::Type.type(:pcmk_drbd).provide(:pcmk_drbd, :parent => Puppet::Provider::Pacemaker) do
  desc 'Pacemaker ocf:linbit:drbd provider'

  optional_commands({
    :crm          => '/usr/sbin/crm',
    :crm_resource => '/usr/sbin/crm_resource'
  })

  def self.instances(res_name)
    instances = []
    if res_name
      cmd = crm 'configure', 'show', 'xml', res_name
    else
      cmd = crm 'configure', 'show', 'xml'
    end
    xml = REXML::Document.new(cmd)
    basepath = ["//cib/configuration/resources/primitive[@type='drbd']", "//cib/configuration/resources/master/primitive[@type='drbd']", "//cib/configuration/resources/clone/primitive[@type='drbd']"]
    basepath.each do |path|
      REXML::XPath.each(xml, path) do |e|

        if ! name = e.attributes['id']
          next
        end
        drbd_resource = REXML::XPath.first(xml, path + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-drbd_resource']").attributes['value']
        op = REXML::XPath.first(xml, path + "[@id='#{name}']/operations/op").attributes['name']
        interval = REXML::XPath.first(xml, path + "[@id='#{name}']/operations/op").attributes['interval']
        if target_role = REXML::XPath.first(xml, path + "[@id='#{name}']/meta_attributes/nvpair[@id='#{name}-meta_attributes-target-role']")
          target_role = REXML::XPath.first(xml, path + "[@id='#{name}']/meta_attributes/nvpair[@id='#{name}-meta_attributes-target-role']").attributes['value']
        end

        property = {}
        property[:name] = name
        property[:drbd_resource] = drbd_resource
        property[:op] = op
        property[:interval] = interval
        property[:target_role] = target_role

        instances << new(property)
      end
    end
    instances
  end

  def create
    debug 'Creating DRBD resource %s' % resource[:name]
    crm 'configure', 'primitive', resource[:name], 'ocf:linbit:drbd', 'params', args
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
    info 'Building args for %s' % resource[:name]
    args = []
    args << "drbd_resource=#{resource[:drbd_resource]}"
    args << "op"
    args << resource[:op]
    args << "interval=#{resource[:interval]}"
    args << 'meta'
    args << "target-role=#{resource[:target_role]}"
  end
end
