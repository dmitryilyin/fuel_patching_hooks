require File.join(File.dirname(__FILE__), 'common/base')
require File.join(File.dirname(__FILE__), 'common/pacemaker')

class DisablResources
  include Base
  include Pacemaker

  def initialize
    @dry_run = false
  end

  # entry point
  def execute
    manage_cluster
  end
end

if __FILE__ == $0
  stop_services = DisablResources.new
  stop_services.execute
end
