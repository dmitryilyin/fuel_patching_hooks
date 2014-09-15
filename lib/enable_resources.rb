require File.join(File.dirname(__FILE__), 'common/base')
require File.join(File.dirname(__FILE__), 'common/pacemaker')

class EnableResources
  include Base
  include Pacemaker

  def initialize
    @dry_run = false
  end

  # entry point
  def execute
    resources_regexp = %r{nova|cinder|glance|keystone|neutron|sahara|murano|ceilometer|heat|swift}
    start_or_unban_by_regexp resources_regexp
  end
end

if __FILE__ == $0
  stop_services = EnableResources.new
  stop_services.execute
end
