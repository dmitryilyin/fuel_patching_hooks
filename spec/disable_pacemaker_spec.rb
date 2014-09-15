require 'spec_helper'
require File.join(File.dirname(__FILE__), '../lib/disable_pacemaker')

describe DisablePacemaker do

  it 'should disable pacemaker' do
    subject.dry_run = true
    subject.expects(:maintenance_mode).with true
    subject.execute
  end

end