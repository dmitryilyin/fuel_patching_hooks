#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), 'common/base')
require File.join(File.dirname(__FILE__), 'common/service')
require File.join(File.dirname(__FILE__), 'common/process')

# pre-deploy hook library
class StopServices
  include Base
  include Service
  include Process

  def initialize
    @stop_services_regexp = %r{nova|cinder|glance|keystone|neutron|sahara|murano|ceilometer|heat|swift|apache2|httpd}
    @dry_run = false
  end

  # entry point
  def execute
    stop_services
    kill_pids_by_stop_regexp
  end
end # class

if __FILE__ == $0
  stop_services = StopServices.new
  stop_services.execute
end
