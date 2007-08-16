#!/usr/bin/env ruby

ROOT = File.expand_path(File.dirname(__FILE__))
$:.unshift(File.expand_path('../../lib', File.dirname(__FILE__)))

require 'rdoc/rdoc'
require 'kari/ri/index'

module Kari
  module RI
    class Generator
      class << self
        def generate_ri_fixtures
          rdoc = RDoc::RDoc.new
          options = []
          options << '--all'
          options << '--charset' << 'utf-8'
          options << '--ri'
          options << '--op' << File.join(ROOT, 'ri')
          options << File.join(ROOT, 'geometry.rb')
          rdoc.document(options)
        end

        def generate_search_index
          Index.build(
            :paths => [File.join(ROOT, 'ri')],
            :output_file => File.join(ROOT, 'index.marshal')
          )
        end
      end
    end
  end
end

if __FILE__ == $0
  puts "Generating RI fixtures"
  Kari::RI::Generator.generate_ri_fixtures
  puts "Generating search index for the RI fixtures"
  Kari::RI::Generator.generate_search_index
end