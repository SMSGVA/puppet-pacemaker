require File.dirname(__FILE__) + '/../../../puppet/provider/pacemaker.rb'
require 'rexml/document'

Puppet::Type.type(:pcmk_generic_daemon).provide(:pcmk_generic_daemon, :parent => Puppet::Provider::Pacemaker) do
  desc 'Pacemaker ocf::heartbeat::generic-daemon provider'

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
    basepath = "//cib/configuration/resources/primitive[@type='generic-daemon']"

    REXML::XPath.each(xml, basepath) do |e|
      property = {}
      name = e.attributes['id']

      initd = REXML::XPath.first(xml, basepath + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-initd']").attributes['value']
      pidfile = REXML::XPath.first(xml, basepath + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-pidfile']").attributes['value']
      monitor = REXML::XPath.first(xml, basepath + "[@id='#{name}']/operations/op[@name='monitor']").attributes['interval']

      property[:name] = name
      property[:initd] = initd
      property[:pidfile] = pidfile
      property[:monitor] = monitor

      instances << new(property)
    end
    instances
  end

  def create
    debug 'Creating generic-daemon %s' % resource[:name]
    crm 'configure', 'primitive', resource[:name], 'ocf:heartbeat:generic-daemon', args
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
    args << 'params'
    args << "name=#{resource[:name]}"
    args << "initd=#{resource[:initd]}" if resource[:initd]
    args << "pidfile=#{resource[:pidfile]}" if resource[:pidfile]
    args << "op monitor"
    args << "interval=#{resource[:monitor]}"
  end
end
