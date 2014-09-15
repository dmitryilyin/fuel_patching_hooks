require 'spec_helper'
require File.join(File.dirname(__FILE__), '../lib/enable_resources')

describe EnableResources do

  it 'should enable resources' do
    subject.dry_run = true
    subject.expects(:start_or_unban_by_regexp)
    subject.execute
  end

end