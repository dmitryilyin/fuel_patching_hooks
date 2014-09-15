module Service
  attr_accessor :stop_services_regexp

  # get service status from shell command
  # @return String
  def services
    `service --status-all 2>&1`
  end

  # same as services_to_stop but reset mnemoization
  # @return Array[String]
  def services_to_stop_with_renew
    @services_to_stop = nil
    services_to_stop
  end

  # find running services that should be stopped
  # uses service status and regex to filter
  # @return [Array<String>]
  def services_to_stop
    return @services_to_stop if @services_to_stop
    @services_to_stop = services.split("\n").inject([]) do |services_to_stop, service|
      fields = service.chomp.split
      running = if fields[4] == 'running...'
                  fields[0]
                elsif fields[1] == '+'
                  fields[3]
                else
                  nil
                end

      if running =~ stop_services_regexp
        # replace wrong service name
        running = 'httpd' if running == 'httpd.event' and osfamily == 'RedHat'
        running = 'openstack-keystone' if running == 'keystone' and osfamily == 'RedHat'
        services_to_stop << running
      else
        services_to_stop
      end
    end
  end

  # stop services that match stop_services_regex
  def stop_services
    services_to_stop.each do |service|
      log "Try to stop service: #{service}"
      run "service #{service} stop"
    end
  end

end