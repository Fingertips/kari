require 'rdoc/ri/ri_driver'
require 'stringio'

module Kari
  module Search
    class Index
      def initialize
        ENV['RI'] ||= '-f html -T'
        @driver = RiDriver.new
      end

      def search(term)
        old_stdout = $stdout
        $stdout = StringIO.new
        @driver.get_info_for(term)
        $stdout.flush
        $stdout.rewind
        output = $stdout.read
        $stdout = old_stdout
        output
      end

      def self.search(term)
        sr = self.new
        sr.search term
      end
    end
  end
end