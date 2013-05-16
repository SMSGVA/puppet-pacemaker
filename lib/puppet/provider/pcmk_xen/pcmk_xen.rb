require File.dirname(__FILE__) + '/../../../puppet/provider/pacemaker.rb'
require 'rexml/document'

Puppet::Type.type(:pcmk_xen).provide(:pcmk_xen, :parent => Puppet::Provider::Pacemaker) do
  desc 'Pacemaker ocf:heartbeat:xen provider'

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
    basepath = ["//cib/configuration/resources/primitive[@type='Xen']"]
    #, "//cib/configuration/resources/master/primitive[@type='Xen']", "//cib/configuration/resources/clone/primitive[@type='Xen']"]
    basepath.each do |path|
      REXML::XPath.each(xml, path) do |e|

        if ! name = e.attributes['id']
          next
        end
        xmfile = REXML::XPath.first(xml, path + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-xmfile']").attributes['value']
#        op = REXML::XPath.first(xml, path + "[@id='#{name}']/operations/op").attributes['name']
#        interval = REXML::XPath.first(xml, path + "[@id='#{name}']/operations/op").attributes['interval']
        if target_role = REXML::XPath.first(xml, path + "[@id='#{name}']/meta_attributes/nvpair[@id='#{name}-meta_attributes-target-role']")
          target_role = REXML::XPath.first(xml, path + "[@id='#{name}']/meta_attributes/nvpair[@id='#{name}-meta_attributes-target-role']").attributes['value']
        end
        if allow_migrate = REXML::XPath.first(xml, path + "[@id='#{name}']/meta_attributes/nvpair[@id='#{name}-meta_attributes-allow-migrate']")
          allow_migrate = REXML::XPath.first(xml, path + "[@id='#{name}']/meta_attributes/nvpair[@id='#{name}-meta_attributes-allow-migrate']").attributes['value']
        end

      if REXML::XPath.first(xml, path + "[@id='#{name}']/operations/op[@name='monitor']")
        if REXML::XPath.first(xml, path + "[@id='#{name}']/operations/op[@name='monitor'].attributes['interval']")
          monitor = REXML::XPath.first(xml, path + "[@id='#{name}']/operations/op[@name='monitor']").attributes['interval']
        end
        if REXML::XPath.first(xml, path + "[@id='#{name}']/operations/op[@name='monitor'].attributes['timeout']")
          monitor_timeout = REXML::XPath.first(xml, path + "[@id='#{name}']/operations/op[@name='monitor']").attributes['timeout']
        end
      end

      if REXML::XPath.first(xml, path + "[@id='#{name}']/operations/op[@name='start']")
        if REXML::XPath.first(xml, path + "[@id='#{name}']/operations/op[@name='start'].attributes['interval']")
          start = REXML::XPath.first(xml, path + "[@id='#{name}']/operations/op[@name='start']").attributes['interval']
        end
        if REXML::XPath.first(xml, path + "[@id='#{name}']/operations/op[@name='start'].attributes['timeout']")
          start_timeout = REXML::XPath.first(xml, path + "[@id='#{name}']/operations/op[@name='start']").attributes['timeout']
        end
      end

      if REXML::XPath.first(xml, path + "[@id='#{name}']/operations/op[@name='stop']")
        if REXML::XPath.first(xml, path + "[@id='#{name}']/operations/op[@name='stop'].attributes['interval']")
          stop = REXML::XPath.first(xml, path + "[@id='#{name}']/operations/op[@name='stop']").attributes['interval']
        end
        if REXML::XPath.first(xml, path + "[@id='#{name}']/operations/op[@name='stop'].attributes['timeout']")
          stop_timeout = REXML::XPath.first(xml, path + "[@id='#{name}']/operations/op[@name='stop']").attributes['timeout']
        end
      end

        property = {}
        property[:name] = name
        property[:xmfile] = xmfile
#        property[:op] = op
#        property[:interval] = interval
        property[:target_role] = target_role
        property[:allow_migrate] = allow_migrate
        property[:start] = start
        property[:start_timeout] = start_timeout
        property[:stop] = stop
        property[:stop_timeout] = stop_timeout
        property[:monitor] = monitor
        property[:monitor_timeout] = monitor_timeout

        instances << new(property)
      end
    end
    instances
  end

  def create
    debug 'Creating Xen resource %s' % resource[:name]
    crm 'configure', 'primitive', resource[:name], 'ocf:heartbeat:Xen', 'params', args
    info "crm configure primitive #{resource[:name]} ocf:heartbeat:Xen params #{args}"
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
    debug 'Building args for %s' % resource[:name]
    args = []
    args << "xmfile=#{resource[:xmfile]}"
    if resource[:monitor] or resource[:monitor_timeout]
      args << "op monitor"
      args << "interval=#{resource[:monitor]}" if resource[:monitor]
      args << "timeout=#{resource[:monitor_timeout]}" if resource[:monitor_timeout]
    end
    if resource[:start] or resource[:start_timeout]
      args << "op start"
      args << "interval=#{resource[:start]}" if resource[:start]
      args << "timeout=#{resource[:start_timeout]}" if resource[:start_timeout]
    end
    if resource[:stop] or resource[:stop_timeout]
      args << "op stop"
      args << "interval=#{resource[:stop]}" if resource[:stop]
      args << "timeout=#{resource[:stop_timeout]}" if resource[:stop_timeout]
    end

#    args << "op"
#    args << resource[:op]
#    args << "interval=#{resource[:interval]}"
#    args << "op start timeout=#{resource[:start]}" if resource[:start]
#    args << "op stop timeout=#{resource[:stop]}" if resource[:stop]
    args << 'meta'
    args << "target-role=#{resource[:target_role]}"
    args << "allow-migrate=#{resource[:allow_migrate]}"
  end
end
