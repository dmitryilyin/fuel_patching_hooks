require 'spec_helper'
require File.join(File.dirname(__FILE__), '../lib/start_services')

describe StartServices do

  it 'should start services' do
    subject.dry_run = true
    subject.expects(:start_services_by_regexp)
    subject.execute
  end

end