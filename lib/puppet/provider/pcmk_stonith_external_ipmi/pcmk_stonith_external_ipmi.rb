require File.dirname(__FILE__) + '/../../../puppet/provider/pacemaker.rb'
require 'rexml/document'

Puppet::Type.type(:pcmk_stonith_external_ipmi).provide(:pcmk_stonith_external_ipmi, :parent => Puppet::Provider::Pacemaker) do
  desc 'Pacemaker stonith provider'

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
    basepath = "//cib/configuration/resources/primitive[@class='stonith',@type='external/ipmi']"

    REXML::XPath.each(xml, basepath) do |e|
      property = {}
      name = e.attributes['id']

      if REXML::XPath.first(xml, basepath + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-hostname']")
        hostname = REXML::XPath.first(xml, basepath + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-hostname']")
      end
      if REXML::XPath.first(xml, basepath + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-ipaddr']")
        ipaddr = REXML::XPath.first(xml, basepath + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-ipaddr']")
      end
      if REXML::XPath.first(xml, basepath + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-userid']")
        userid = REXML::XPath.first(xml, basepath + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-userid']")
      end
      if REXML::XPath.first(xml, basepath + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-passwd']")
        passwd = REXML::XPath.first(xml, basepath + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-passwd']")
      end
      if REXML::XPath.first(xml, basepath + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-passwd_method']")
        passwd_method = REXML::XPath.first(xml, basepath + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-passwd_method']")
      end
      if REXML::XPath.first(xml, basepath + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-interface']")
        interface = REXML::XPath.first(xml, basepath + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-interface']")
      end
      if REXML::XPath.first(xml, basepath + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-priv']")
        priv = REXML::XPath.first(xml, basepath + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-priv']")
      end
      if REXML::XPath.first(xml, basepath + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-ipmitool']")
        ipmitool = REXML::XPath.first(xml, basepath + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-ipmitool']")
      end
      if REXML::XPath.first(xml, basepath + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-stonith-timeout']")
        stonith_timeout = REXML::XPath.first(xml, basepath + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-stonith-timeout']")
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
      property[:ipaddr] = ipaddr
      property[:userid] = userid
      property[:passwd] = passwd
      property[:passwd_method] = passwd_method
      property[:interface] = interface
      property[:priv] = priv
      property[:ipmitool] = ipmitool
      property[:stonith_timeout] = stonith_timeout
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
    crm 'configure', 'primitive', resource[:name], 'stonith:external/ipmi', args
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
    debug 'Hostname: %s' % resource[:hostname]
    args = []
    args << "params"
    args << "hostname=#{resource[:hostname]}" if resource[:hostname]
    args << "ipaddr=#{resource[:ipaddr]}" if resource[:ipaddr]
    args << "userid=#{resource[:userid]}" if resource[:userid]
    args << "passwd=#{resource[:passwd]}" if resource[:passwd]
    args << "passwd_method=#{resource[:passwd_method]}" if resource[:passwd_method]
    args << "interface=#{resource[:interface]}" if resource[:interface]
    args << "priv=#{resource[:priv]}" if resource[:priv]
    args << "ipmitool=#{resource[:ipmitool]}" if resource[:ipmitool]
    args << "stonith-timeout=#{resource[:stonith_timeout]}" if resource[:stonith_timeout]
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
    debug args
  end
end
