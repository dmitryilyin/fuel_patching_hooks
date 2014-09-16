module Service

  #TODO start only services enabled on boot
  #TODO record which services were stopped

  # get service status from shell command
  # @return String
  def services
    `service --status-all 2>&1`
  end

  # same as services_list but resets mnemoization
  # @return [Hash<String => Symbol>]
  def services_list_with_renew
    @services_list = nil
    services_list
  end

  # parse services into servicer list
  # @return [Hash<String => Symbol>]
  def services_list
    return @services_list if @services_list
    @services_list = {}
    services.split("\n").each do |service|
      fields = service.chomp.split
      case
        when fields[4] == 'running...'
          name = fields[0]
          status = :running
        when fields[2] == 'stopped'
          name = fields[0]
          status = :stopped
        when fields[1] == '+'
          name = fields[3]
          status = :running
        when fields[1] == '-'
          name = fields[3]
          status = :stopped
        when fields[1] == '?'
          name = fields[3]
          status = :unknown
        else
          name = nil
          status = nil
      end

      if name
        # replace wrong service name
        name = 'httpd' if name == 'httpd.event' and osfamily == 'RedHat'
        name = 'openstack-keystone' if name == 'keystone' and osfamily == 'RedHat'
        @services_list.store name, status
      end
    end
    @services_list
  end

  # find services matching regular expression
  # @param regexp <Regexp>
  # @return [Hash<String => Symbol>]
  def services_by_regexp(regexp)
    matched = {}
    services_list.each do |name, status|
      matched.store name, status if name =~ regexp
    end
    matched
  end

  # stop services that match regex
  # @param regexp <Regexp>
  def stop_services_by_regexp(regexp)
    services_by_regexp(regexp).each do |name, status|
      next if status == :stopped
      log "Try to stop service: #{name}"
      run "service #{name} stop"
    end
  end

  # start services that match regex
  # @param regexp <Regexp>
  def start_services_by_regexp(regexp)
    services_by_regexp(regexp).each do |name, status|
      next if status == :running
      log "Try to start service: #{name}"
      run "service #{name} start"
    end
  end

end