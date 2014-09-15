require 'spec_helper'
require File.join(File.dirname(__FILE__), '../lib/enable_pacemaker')

describe EnablePacemaker do

  it 'should enable pacemaker' do
    subject.dry_run = true
    subject.expects(:maintenance_mode).with false
    subject.execute
  end

end