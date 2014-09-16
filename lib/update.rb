require File.join(File.dirname(__FILE__), 'common/base')
require File.join(File.dirname(__FILE__), 'common/service')
require File.join(File.dirname(__FILE__), 'common/process')
require File.join(File.dirname(__FILE__), 'common/pacemaker')
require File.join(File.dirname(__FILE__), 'common/package')

class Update
  include Base
  include Service
  include Process
  include Pacemaker
  include Package

  def execute
    services = %r{nova|cinder|glance|keystone|neutron|sahara|murano|ceilometer|heat|swift|apache2|httpd}
    #TODO make package lists for ubuntu and centos
    packages = %w(
heat-api
heat-api-cfn
heat-api-cloudwatch
heat-common
heat-engine
python-heat
python-heatclient
    )

    @dry_run = false
    if is_ha?
      pcmk_status
      stop_or_ban_by_regexp services
      # manage_cluster
      pcmk_status
    end
    stop_services_by_regexp services
    kill_pids_by_regexp services
    uninstall_packages packages
    reset_repos
    install_removed_packages packages
    if is_ha?
      pcmk_status
      start_or_unban_by_regexp services
      # unmanage_cluster
      cleanup_resources_by_regexp services
      pcmk_status
    end
    # cannot do this because it will start disabled services too
    # start_services_by_regexp services

    # TODO start non-ha services that are autostart? or run puppet? or start services that were stopped previously?
    # finding a way to start services without Puppet will allow to patch with this script only
  end

end

if __FILE__ == $0
  me = Update.new
  me.execute
end
