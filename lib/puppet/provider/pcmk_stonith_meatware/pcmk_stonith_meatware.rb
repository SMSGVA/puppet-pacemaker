require File.dirname(__FILE__) + '/../../../puppet/provider/pacemaker.rb'
require 'rexml/document'

Puppet::Type.type(:pcmk_stonith_meatware).provide(:pcmk_stonith_meatware, :parent => Puppet::Provider::Pacemaker) do
  desc 'Pacemaker stonith provider'
  defaultfor :operatingsystem => :linux

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
    basepath = "//cib/configuration/resources/primitive[@class='stonith',@type='meatware']"

    REXML::XPath.each(xml, basepath) do |e|
      property = {}
      name = e.attributes['id']

      if REXML::XPath.first(xml, basepath + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-hostlist']")
        hostlist = REXML::XPath.first(xml, basepath + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-hostlist']")
      end
      if REXML::XPath.first(xml, basepath + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-priority']")
        priority = REXML::XPath.first(xml, basepath + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-priority']")
      end

      if REXML::XPath.first(xml, basepath + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-pcmk_host_argument']")
        pcmk_host_argument = REXML::XPath.first(xml, basepath + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-pcmk_host_argument']")
      end
       if REXML::XPath.first(xml, basepath + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-pcmk_host_map']")
        pcmk_host_map = REXML::XPath.first(xml, basepath + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-pcmk_host_map']")
      end
       if REXML::XPath.first(xml, basepath + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-pcmk_host_list']")
        pcmk_host_list = REXML::XPath.first(xml, basepath + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-pcmk_host_list']")
      end
       if REXML::XPath.first(xml, basepath + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-pcmk_host_check']")
        pcmk_host_check = REXML::XPath.first(xml, basepath + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-pcmk_host_check']")
      end
       if REXML::XPath.first(xml, basepath + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-pcmk_reboot_action']")
        pcmk_reboot_action = REXML::XPath.first(xml, basepath + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-pcmk_reboot_action']")
      end
       if REXML::XPath.first(xml, basepath + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-pcmk_poweroff_action']")
        pcmk_poweroff_action = REXML::XPath.first(xml, basepath + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-pcmk_poweroff_action']")
      end
       if REXML::XPath.first(xml, basepath + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-pcmk_list_action']")
        pcmk_list_action = REXML::XPath.first(xml, basepath + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-pcmk_list_action']")
      end
       if REXML::XPath.first(xml, basepath + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-pcmk_monitor_action']")
        pcmk_monitor_action = REXML::XPath.first(xml, basepath + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-pcmk_monitor_action']")
      end
       if REXML::XPath.first(xml, basepath + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-pcmk_status_action']")
        pcmk_status_action = REXML::XPath.first(xml, basepath + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-pcmk_status_action']")
      end

      if REXML::XPath.first(xml, basepath + "[@id='#{name}']/operations/op[@name='monitor']")
        if REXML::XPath.first(xml, basepath + "[@id='#{name}']/operations/op[@name='monitor'].attributes['interval']")
          monitor = REXML::XPath.first(xml, basepath + "[@id='#{name}']/operations/op[@name='monitor']").attributes['interval']
        end
        if REXML::XPath.first(xml, basepath + "[@id='#{name}']/operations/op[@name='monitor'].attributes['timeout']")
          monitor_timeout = REXML::XPath.first(xml, basepath + "[@id='#{name}']/operations/op[@name='monitor']").attributes['timeout']
        end
      end

      property[:name] = name

      property[:hostlist] = hostlist
      property[:priority] = priority

      property[:pcmk_host_argument] = pcmk_host_argument
      property[:pcmk_host_map] = pcmk_host_map
      property[:pcmk_host_list] = pcmk_host_list
      property[:pcmk_host_check] = pcmk_host_check
      property[:pcmk_reboot_action] = pcmk_reboot_action
      property[:pcmk_poweroff_action] = pcmk_poweroff_action
      property[:pcmk_list_action] = pcmk_list_action
      property[:pcmk_monitor_action] = pcmk_monitor_action
      property[:pcmk_status_action] = pcmk_status_action

      property[:start] = start
      property[:stop] = stop
      property[:status] = status
      property[:monitor] = monitor
      property[:monitor_timeout] = monitor_timeout

      instances << new(property)
    end
    instances
  end

  def create
    debug 'Creating stonith %s' % resource[:name]
    crm 'configure', 'primitive', resource[:name], 'stonith:meatware', args
  end

  def destroy
    debug 'Destroying resource %s' % resource[:name]
#    crm 'resource', 'stop', resource[:name]
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
    args << "params"
    args << "hostlist=#{resource[:hostlist]}" if resource[:hostlist]
    args << "priority=#{resource[:priority]}" if resource[:priority]

    args << "pcmk_host_argument=#{resource[:pcmk_host_argument]}" if resource[:pcmk_host_argument]
    args << "pcmk_host_map=#{resource[:pcmk_host_map]}" if resource[:pcmk_host_map]
    args << "pcmk_host_list=#{resource[:pcmk_host_list]}" if resource[:pcmk_host_list]
    args << "pcmk_host_check=#{resource[:pcmk_host_check]}" if resource[:pcmk_host_check]
    args << "pcmk_reboot_action=#{resource[:pcmk_reboot_action]}" if resource[:pcmk_reboot_action]
    args << "pcmk_poweroff_action=#{resource[:pcmk_poweroff_action]}" if resource[:pcmk_poweroff_action]
    args << "pcmk_list_action=#{resource[:pcmk_list_action]}" if resource[:pcmk_list_action]
    args << "pcmk_monitor_action=#{resource[:pcmk_monitor_action]}" if resource[:pcmk_monitor_action]
    args << "pcmk_status_action=#{resource[:pcmk_status_action]}" if resource[:pcmk_status_action]

    if resource[:monitor] or resource[:monitor_timeout]
      args << "op monitor"
      args << "interval=#{resource[:monitor]}" if resource[:monitor]
      args << "timeout=#{resource[:monitor_timeout]}" if resource[:monitor_timeout]
    end
    args << "op start timeout=#{resource[:start]}" if resource[:start]
    args << "op stop timeout=#{resource[:stop]}" if resource[:stop]
    args << "op status timeout=#{resource[:status]}" if resource[:status]
    info args
  end
end
