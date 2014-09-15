require 'rubygems'
require 'facter'
require 'time'

module Base
  @osfamily = nil
  @dry_run = false

  attr_accessor :dry_run

  # get osfamily from facter
  # @return [String]
  def osfamily
    return @osfamily if @osfamily
    @osfamily = Facter.value 'osfamily'
  end

  # run the shell command with dry_run support
  # @param cmd [String] Command to run
  def run(cmd)
    command = "#{dry_run ? 'echo' : ''} #{cmd} 2>&1"
    system command
  end

  # output a string
  # @param msg [String]
  def log(msg)
     begin
       log_file = __FILE__ + '.log'
       open(log_file, 'a') do |file|
         file.puts Time.now.to_s + ': ' + msg
       end
     end
    puts msg
  end
end