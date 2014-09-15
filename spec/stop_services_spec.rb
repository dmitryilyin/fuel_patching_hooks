require 'spec_helper'
require File.join(File.dirname(__FILE__), '../lib/stop_services')

describe StopServices do
  it 'should stop services' do
    subject.dry_run = true
    subject.expects(:stop_services_by_regexp)
    subject.stubs(:kill_pids_by_regexp).returns true
    subject.execute
  end

  it 'should kill processes' do
    subject.dry_run = true
    subject.stubs(:stop_services_by_regexp).returns true
    subject.expects(:kill_pids_by_regexp)
    subject.execute
  end

end