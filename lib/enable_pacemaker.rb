require File.join(File.dirname(__FILE__), 'common/base')
require File.join(File.dirname(__FILE__), 'common/pacemaker')

class EnablePacemaker
  include Base
  include Pacemaker

  def initialize
    @dry_run = false
  end

  # entry point
  def execute
    unmanage_cluster
  end
end

if __FILE__ == $0
  stop_services = EnablePacemaker.new
  stop_services.execute
end
