require File.dirname(__FILE__) + '/../../../puppet/provider/pacemaker.rb'
require 'rexml/document'

Puppet::Type.type(:pcmk_lsb).provide(:pcmk_lsb, :parent => Puppet::Provider::Pacemaker) do
  desc 'Pacemaker lsb provider'

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
    basepath = "//cib/configuration/resources/primitive[@class='lsb']"

    REXML::XPath.each(xml, basepath) do |e|
      property = {}
      name = e.attributes['id']

      service = REXML::XPath.first(xml, basepath + "[@id='#{name}']").attributes['type']
      if REXML::XPath.first(xml, basepath + "[@id='#{name}']/meta_attributes/nvpair[@id='#{name}-meta_attributes-target-role']")
        target_role = REXML::XPath.first(xml, basepath + "[@id='#{name}']/meta_attributes/nvpair[@id='#{name}-meta_attributes-target-role']").attributes['value']
      end
      if monitor = REXML::XPath.first(xml, basepath + "[@id='#{name}']/operations/op[@name='monitor']")
        monitor = REXML::XPath.first(xml, basepath + "[@id='#{name}']/operations/op[@name='monitor']").attributes['interval']
      end

      property[:name] = name
      property[:service] = service
      property[:target_role] = target_role
      property[:monitor] = monitor

      instances << new(property)
    end
    instances
  end

  def create
    debug 'Creating lsb %s' % resource[:name]
    crm 'configure', 'primitive', resource[:name], 'lsb:' + resource[:service], args
  end

  def destroy
    debug 'Destroying resource %s' % resource[:name]
    crm 'resource', 'stop', resource[:name]
    crm 'configure', 'delete', resource[:name]
  end

  def exists?
    debug 'Checking existence of %s' % resource[:name]
    status = crm_resource '--list'
    if status =~ /^\s+#{resource[:name]}/
      true
    else
      false
    end
  end

  def args
    debug 'Building args for %s' % resource[:name]
    args = []
    args << "meta target-role=#{resource[:target_role]}" if resource[:target_role]
    args << "op monitor interval=#{resource[:monitor]}" if resource[:monitor]
  end
end
