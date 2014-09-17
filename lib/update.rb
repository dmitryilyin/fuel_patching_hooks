require File.join(File.dirname(__FILE__), 'common/base')
require File.join(File.dirname(__FILE__), 'common/service')
require File.join(File.dirname(__FILE__), 'common/process')
require File.join(File.dirname(__FILE__), 'common/pacemaker')
require File.join(File.dirname(__FILE__), 'common/package')
require File.join(File.dirname(__FILE__), 'common/migration')

class Update
  include Base
  include Service
  include Process
  include Pacemaker
  include Package
  include Migration

  def execute
    services = %r{nova|cinder|glance|keystone|neutron|sahara|murano|ceilometer|heat|swift|apache2|httpd}

    deb_packages = %w(
        python-oslo.messaging python-oslo.config python-heat python-nova
        python-routes python-routes1.13 python-neutron python-django-horizon
        murano-common murano-api sahara sahara-dashboard python-ceilometer
        python-swift python-cinder python-keystoneclient python-neutronclient
        python-novaclient python-swiftclient python-troveclient
        python-sqlalchemy python-testtools
    )

    rpm_packages = %w(
        python-oslo-messaging python-oslo-config openstack-heat-common
        python-nova python-routes python-routes1.12 python-neutron
        python-django-horizon murano-api sahara sahara-dashboard
        python-ceilometer openstack-swift openstack-utils
        python-glance python-glanceclient python-cinder
        python-sqlalchemy python-testtools
    )

    if osfamily == 'RedHat'
      packages = rpm_packages
    elsif osfamily == 'Debian'
      packages = deb_packages
    else
      raise "Unknown osfamily: #{osfamily}"
    end

    @dry_run = false

    ######

    remove_log

    if has_pacemaker?
      pcmk_status
      stop_or_ban_by_regexp services
      manage_cluster
      pcmk_status
    end

    stop_services_by_regexp services
    kill_pids_by_regexp services
    reinstall_with_remove packages
    recreate_murano_database

    if has_pacemaker?
      pcmk_status
      start_or_unban_by_regexp services
      unmanage_cluster
      cleanup_resources_by_regexp services
      pcmk_status
    end

    start_services_by_regexp services
  end

end

if __FILE__ == $0
  me = Update.new
  me.execute
end
