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
    stop_services_by_regexp services
    kill_pids_by_regexp services
    recreate_murano_database

  end

end

if __FILE__ == $0
  me = Update.new
  me.execute
end
