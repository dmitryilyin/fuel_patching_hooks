require 'spec_helper'
require File.join(File.dirname(__FILE__), '../lib/common/base')
require File.join(File.dirname(__FILE__), '../lib/common/package')

class PackageTest
  include Base
  include Package
end

describe PackageTest do

  let(:deb_packages) do
<<-eos
mc|3:4.8.11-1|deinstall ok config-files
ipcalc|0.41-4|install ok installed
iproute|3.12.0-2|install ok installed
iptables|1.4.21-1ubuntu1|install ok installed
ntpdate|4.2.6.p5+dfsg-3ubuntu2|install ok installed
eos
  end

  let(:deb_packages_list) do
    {
        "iptables"=>"1.4.21-1ubuntu1",
        "iproute"=>"3.12.0-2",
        "ipcalc"=>"0.41-4",
        "ntpdate" =>"4.2.6.p5+dfsg-3ubuntu2",
    }
  end

  let(:rpm_packages) do
<<-eos
iproute|2.6.32-130.el6.netns.2.mira1
util-linux-ng|2.17.2-12.14.el6_5
udev|147-2.51.el6
device-mapper|1.02.79-8.el6
openssh|5.3p1-94.el6
ntpdate|4.2.6p5-1.el6
eos
  end

  let(:rpm_packages_list) do
    {
        "util-linux-ng"=>"2.17.2-12.14.el6_5",
        "iproute"=>"2.6.32-130.el6.netns.2.mira1",
        "openssh"=>"5.3p1-94.el6",
        "udev"=>"147-2.51.el6",
        "device-mapper"=>"1.02.79-8.el6",
        "ntpdate"=>"4.2.6p5-1.el6",
    }
  end

  let(:packages_to_remove) do
    %w(iproute mc firefox ntpdate)
  end

  ###########################

  before(:each) do
    @class = subject
    @class.dry_run = true
    #@class.stubs(:log).returns true
  end

  context 'on Debian system' do
    before(:each) do
      @class.stubs(:get_rpm_packages).returns rpm_packages
      @class.stubs(:get_deb_packages).returns deb_packages
      @class.stubs(:osfamily).returns 'Debian'
    end

    it 'parses package list' do
      expect(@class.parse_deb_packages).to eq deb_packages_list
    end

    it 'determines if a package is installed' do
      @class.installed_packages_with_renew
      expect(@class.is_installed? 'iproute').to be_truthy
    end

    it 'determines if a package is not installed' do
      @class.installed_packages_with_renew
      expect(@class.is_installed? 'mc').to be_falsey
    end

    it 'filters out not installed packages' do
      @class.installed_packages_with_renew
      expect(@class.filter_installed packages_to_remove).to eq %w(iproute ntpdate)
    end

    it 'uninstalls packages from the list' do
      @class.installed_packages_with_renew
      @class.expects(:remove).with(%w(iproute ntpdate))
      @class.uninstall_packages packages_to_remove
    end

    it 'uses apt-get purge -y to remove packages' do
      @class.installed_packages_with_renew
      @class.expects(:run).with 'apt-get purge -y iproute ntpdate'
      @class.remove %w(iproute ntpdate)
    end

  end

  context 'on RedHat system' do
    before(:each) do
      @class.stubs(:get_rpm_packages).returns rpm_packages
      @class.stubs(:get_deb_packages).returns deb_packages
      @class.stubs(:osfamily).returns 'RedHat'
    end

    it 'parses package list' do
      expect(@class.parse_rpm_packages).to eq rpm_packages_list
    end

    it 'determines if a package is installed' do
      @class.installed_packages_with_renew
      expect(@class.is_installed? 'iproute').to be_truthy
    end

    it 'determines if a package is not installed' do
      @class.installed_packages_with_renew
      expect(@class.is_installed? 'mc').to be_falsey
    end

    it 'filters out not installed packages' do
      @class.installed_packages_with_renew
      expect(@class.filter_installed packages_to_remove).to eq %w(iproute ntpdate)
    end

    it 'uninstalls packages from the list' do
      @class.installed_packages_with_renew
      @class.expects(:remove).with(%w(iproute ntpdate))
      @class.uninstall_packages packages_to_remove
    end

    it 'uses yum -y erase to remove packages' do
      @class.installed_packages_with_renew
      @class.expects(:run).with 'yum erase -y iproute ntpdate'
      @class.remove %w(iproute ntpdate)
    end
  end

end