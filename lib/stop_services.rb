#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), 'common/base')
require File.join(File.dirname(__FILE__), 'common/service')
require File.join(File.dirname(__FILE__), 'common/process')

# pre-deploy hook library
class StopServices
  include Base
  include Service
  include Process

  # entry point
  def execute
    @dry_run = false
    services_regexp = %r{nova|cinder|glance|keystone|neutron|sahara|murano|ceilometer|heat|swift|apache2|httpd}
    stop_services_by_regexp services_regexp
    kill_pids_by_regexp services_regexp
  end
end # class

if __FILE__ == $0
  me = StopServices.new
  me.execute
end
