require 'rubygems'
require 'pry'

require File.join(File.dirname(__FILE__), 'common/base')
require File.join(File.dirname(__FILE__), 'common/service')
require File.join(File.dirname(__FILE__), 'common/process')
require File.join(File.dirname(__FILE__), 'common/pacemaker')
require File.join(File.dirname(__FILE__), 'common/package')
require File.join(File.dirname(__FILE__), 'common/migration')

class Hooks
  include Base
  include Service
  include Process
  include Pacemaker
  include Package
  include Migration
end

hooks = Hooks.new
binding.pry