require 'puppet/provider/pacemaker'
require 'rexml/document'

Puppet::Type.type(:pcmk_prm).provide(:pcmk_prm, :parent => Puppet::Provider::Pacemaker) do
  desc 'Pacemaker ocf::percona:mysql provider'
  
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
    basepath = ["//cib/configuration/resources/primitive[@type='mysql']", "//cib/configuration/resources/master/primitive[@type='mysql']", "//cib/configuration/resources/clone/primitive[@type='mysql']"]
    basepath.each do |path|
      REXML::XPath.each(xml, path) do |e|
        
        name = e.attributes['id']
        config = REXML::XPath.first(xml, path + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-config']").attributes['value']
        pid = REXML::XPath.first(xml, path + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-pid']").attributes['value']
        socket = REXML::XPath.first(xml, path + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-socket']").attributes['value']
        replication_user = REXML::XPath.first(xml, path + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-replication_user']").attributes['value']
        replication_passwd = REXML::XPath.first(xml, path + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-replication_passwd']").attributes['value']
        max_slave_lag = REXML::XPath.first(xml, path + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-max_slave_lag']").attributes['value']
        evict_outdated_slaves = REXML::XPath.first(xml, path + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-evict_outdated_slaves']").attributes['value']
        binary = REXML::XPath.first(xml, path + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-binary']").attributes['value']
        test_user = REXML::XPath.first(xml, path + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-test_user']").attributes['value']
        test_passwd = REXML::XPath.first(xml, path + "[@id='#{name}']/instance_attributes/nvpair[@id='#{name}-instance_attributes-test_passwd']").attributes['value']
        master_monitor_interval = REXML::XPath.first(xml, path + "[@id='#{name}']/operations/op[@role='Master']").attributes['interval']
        slave_monitor_interval = REXML::XPath.first(xml, path + "[@id='#{name}']/operations/op[@role='Slave']").attributes['interval']
        
        property = {
          :name => name,
          :config => config,
          :pid => pid,
          :socket => socket,
          :replication_user => replication_user,
          :replication_passwd => replication_passwd,
          :max_slave_lag => max_slave_lag,
          :evict_outdated_slaves => evict_outdated_slaves,
          :binary => binary,
          :test_user => test_user,
          :test_passwd => test_passwd,
          :master_monitor_interval => master_monitor_interval,
          :slave_monitor_interval => slave_monitor_interval
        }
        
        instances << new(property)
      end
    end
    instances
  end

  def create
    debug 'Creating Percona Replication Manager resource %s' % resource[:name]
    crm 'configure', 'primitive', resource[:name], 'ocf:percona:mysql', args
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
    args = [
      'params',
      "config=\"#{resource[:config]}\"",
      "pid=\"#{resource[:pid]}\"",
      "socket=\"#{resource[:socket]}\"",
      "replication_user=\"#{resource[:replication_user]}\"",
      "replication_passwd=\"#{resource[:replication_passwd]}\"",
      "max_slave_lag=\"#{resource[:max_slave_lag]}\"",
      "evict_outdated_slaves=\"#{resource[:evict_outdated_slaves]}\"",
      "binary=\"#{resource[:binary]}\"", 
      "test_user=\"#{resource[:test_user]}\"",
      "test_passwd=\"#{resource[:test_passwd]}\"",
      "op monitor interval=\"#{resource[:master_monitor_interval]}\" role='Master' OCF_CHECK_LEVEL='1'",
      "op monitor interval=\"#{resource[:slave_monitor_interval]}\" role='Slave' OCF_CHECK_LEVEL='1'",
    ]
    args
  end
end
