module Package
  def get_rpm_packages
    `rpm -qa --queryformat '%{NAME}|%{VERSION}-%{RELEASE}\n'`
  end

  def get_deb_packages
    `dpkg-query --show -f='${Package}|${Version}|${Status}\n'`
  end

  def parse_rpm_packages
    packages = {}
    get_rpm_packages.split("\n").each do |package|
      fields = package.split('|')
      name = fields[0]
      version = fields[1]
      if name
        packages.store name, version
      end
    end
    packages
  end

  def parse_deb_packages
    packages = {}
    get_deb_packages.split("\n").each do |package|
      fields = package.split('|')
      name = fields[0]
      version = fields[1]
      if fields[2] == 'install ok installed'
        installed = true
      else
        installed = false
      end
      if installed and name
        packages.store name, version
      end
    end
    packages
  end

  def installed_packages_with_renew
    @installed_packages = nil
    installed_packages
  end

  def installed_packages
    return @installed_packages if @installed_packages
    if osfamily == 'RedHat'
      @installed_packages = parse_rpm_packages
    elsif osfamily == 'Debian'
      @installed_packages = parse_deb_packages
    else
      raise "Unknown osfamily: #{osfamily}"
    end
  end

  def is_installed?(package)
    installed_packages.key? package
  end

  def filter_installed(packages)
    packages.select { |p| is_installed? p }
  end

  def remove(packages)
    packages = Array packages
    if osfamily == 'RedHat'
      run "yum erase -y #{packages.join ' '}"
    elsif osfamily == 'Debian'
      run "apt-get purge -y #{packages.join ' '}"
    else
      raise "Unknown osfamily: #{osfamily}"
    end
  end

  def uninstall_packages(packages)
    remove filter_installed(packages)
  end

end