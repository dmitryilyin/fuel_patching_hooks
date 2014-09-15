require 'spec_helper'
require File.join(File.dirname(__FILE__), '../lib/disable_resources')

describe DisableResources do

  it 'should disable resources' do
    subject.dry_run = true
    subject.expects(:stop_or_ban_by_regexp)
    subject.execute
  end

end