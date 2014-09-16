require 'rubygems'
require 'facter'
require 'time'
require 'yaml'

module Base
  @osfamily = nil
  @dry_run = false

  attr_accessor :dry_run

  # same as fuel_settings but resets mnemoization
  # @return [Hash]
  def fuel_settings_with_renew
    @fuel_settings = nil
    fuel_settings
  end

  def read_astute_yaml
    settings_file = '/etc/astute.yaml'
    begin
      File.read settings_file
    rescue
      nil
    end
  end

  # get astute.yaml settings
  # @return [Hash]
  def fuel_settings
    return @fuel_settings if @fuel_settings
    begin
      @fuel_settings = YAML.load read_astute_yaml
    rescue
      @fuel_settings = nil
    end
    @fuel_settings
  end

  def cluster_nodes_count
    return nil unless fuel_settings.is_a? Hash and fuel_settings.key? 'nodes'
    nodes = fuel_settings['nodes']
    return nil unless nodes.is_a? Array
    nodes.inject(0) do |controllers, node|
      if node['role'] =~ /controller/
        controllers + 1
      else
       controllers
      end
    end
  end

  # get osfamily from facter
  # @return [String]
  def osfamily
    return @osfamily if @osfamily
    @osfamily = Facter.value 'osfamily'
  end

  # run the shell command with dry_run support
  # @param cmd [String] Command to run
  def run(cmd)
    ENV['LANG'] = 'C'
    log "Run: #{cmd}"
    if dry_run
      return ['', 0]
    end
    stdout = `#{cmd} 2>&1`
    return_code = $?.exitstatus
    puts stdout
    puts "Return: #{return_code}"
    [stdout, return_code]
  end

  # output a string
  # @param msg [String]
  def log(msg)
     begin
       log_file = '/tmp/update.log'
       open(log_file, 'a') do |file|
         file.puts Time.now.to_s + ': ' + msg
       end
     end
    puts msg
  end
end