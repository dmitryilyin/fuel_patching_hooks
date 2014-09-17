require 'rubygems'
require 'facter'
require 'time'
require 'yaml'

module Base
  LOG_FILE = '/var/log/patching.log'

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

  def is_ha?
    return nil unless fuel_settings.is_a? Hash and fuel_settings.key? 'deployment_mode'
    if %w(singlenode multinode).include? fuel_settings['deployment_mode']
      false
    elsif %w(ha ha_compact ha_full).include? fuel_settings['deployment_mode']
      true
    else
      nil
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
       log_file = LOG_FILE
       open(log_file, 'a') do |file|
         file.puts Time.now.to_s + ': ' + msg
       end
     end
    puts msg
  end

  def remove_log
    begin
      File.delete LOG_FILE if File.exists? LOG_FILE
    rescue
      false
    end
  end

  def mysqldump(database, file)
    database.gsub! %q('), %q(\')
    file.gsub! %q('), %q(\')
    command = %Q(mysqldump --default-character-set=utf8 --single-transaction '#{database}' | gzip > '#{file}')
    out,code = run command
    code == 0
  end

  def timestamp
    Time.now.to_i.to_s
  end

  def drop_mysql_database(database)
    database.gsub! %q('), %q(\')
    command = %Q(drop database `#{database}`)
    command = %Q(mysql -Be '#{command}')
    out,code = run command
    code == 0
  end

  def create_mysql_database(database)
    database.gsub! %q('), %q(\')
    command = %Q(create database `#{database}` default character set utf8)
    command = %Q(mysql -Be '#{command}')
    out,code = run command
    code == 0
  end

  def mysql_query(query)
    query.gsub! %q('), %q(\')
    command = %Q(mysql -Be '#{query}')
    run command
  end

  def mysql_database_exists?(database)
    database.gsub! %q('), %q(\')
    command = %Q(show create database `#{database}`)
    command = %Q(mysql -Be '#{command}')
    out,code = run command
    code == 0
  end

end
