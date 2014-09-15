#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), 'common/base')
require File.join(File.dirname(__FILE__), 'common/service')
require File.join(File.dirname(__FILE__), 'common/process')

# pre-deploy hook library
class StartServices
  include Base
  include Service
  include Process

  # entry point
  def execute
    @dry_run = false
    services_regexp = %r{nova|cinder|glance|keystone|neutron|sahara|murano|ceilometer|heat|swift|apache2|httpd}
    start_services_by_regexp services_regexp
  end
end # class

if __FILE__ == $0
  start_services = StartServices.new
  start_services.execute
end
