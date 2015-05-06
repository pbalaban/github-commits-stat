require 'vcr'
require 'webmock'
require 'minitest/autorun'
require "minitest/reporters"

Minitest::Reporters.use!

VCR.configure do |config|
  config.cassette_library_dir = "specs/fixtures/vcr_cassettes"
  config.hook_into :webmock # or :fakeweb
end

class MiniTest::Spec
  before :each do
    VCR.turn_on!
    VCR.insert_cassette('synopsis', record: :new_episodes)
  end

  after :each do
    VCR.eject_cassette('synopsis')
    VCR.turn_off!
  end
end
