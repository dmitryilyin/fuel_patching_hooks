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
    return true unless packages.any?
    if osfamily == 'RedHat'
      stdout, return_code = run "yum erase -y #{packages.join ' '}"
      parse_rpm_remove stdout
    elsif osfamily == 'Debian'
      stdout, return_code = run "apt-get remove -y #{packages.join ' '}"
      parse_deb_remove stdout
    else
      raise "Unknown osfamily: #{osfamily}"
    end
  end

  def parse_deb_remove(stdout)
    if not stdout or stdout == ''
      @removed_packages = {}
      return @removed_packages
    end
    @removed_packages = {}
    stdout.split("\n").inject({}) do |removed, line|
      if line =~ /^Removing\s+(\S+)\s+\((\S+?)\)\s+\.\.\./
        @removed_packages.store $1, $2 if $1 and $2
      end
    end
    @removed_packages
  end

  def parse_rpm_remove(stdout)
    if not stdout or stdout == ''
      @removed_packages = {}
      return @removed_packages
    end
    @removed_packages = {}
    in_block = false
    stdout.split("\n").inject({}) do |removed, line|
      if line =~ /^Removing:/ and not in_block
        in_block = true
        next
      end

      if line =~/^Transaction Summary/ and in_block
        in_block = false
        next
      end

      if in_block
        if line =~ /^\s*(\S+)\s+\S+\s+(\S+)/
          @removed_packages.store $1, $2 if $1 and $2
        end
      end
    end
    @removed_packages
  end

  def removed_packages
    @removed_packages = {} unless @removed_packages
    @removed_packages
  end

  def install(packages)
    packages = Array packages
    return true unless packages.any?
    if osfamily == 'RedHat'
      run "yum install -y #{packages.join ' '}"
    elsif osfamily == 'Debian'
      run "aptitude install -y #{packages.join ' '}"
    else
      raise "Unknown osfamily: #{osfamily}"
    end
  end

  def install_removed_packages(key_packages = [])
    if removed_packages.keys.length == 0 and key_packages.length > 0
      install key_packages
    elsif key_packages.length == 0 and removed_packages.keys.length > 0
      install removed_packages.keys
    elsif key_packages.length > 0 and removed_packages.keys.length > 0
      to_install = key_packages.select do |kp|
        removed_packages.key? kp
      end
      install to_install
    end
  end

  def uninstall_packages(packages)
    remove filter_installed(packages)
  end

  def reset_repos
    if osfamily == 'RedHat'
      run 'yum clean all'
      run 'yum makecache'
    elsif osfamily == 'Debian'
      run 'apt-get clean'
      run 'apt-get update'
    else
      raise "Unknown osfamily: #{osfamily}"
    end
  end

  def update_removing_first(packages)
    uninstall_packages packages
    install_removed_packages packages
  end

end
