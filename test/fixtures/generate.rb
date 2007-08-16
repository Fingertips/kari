#!/usr/bin/env ruby

ROOT = File.expand_path(File.dirname(__FILE__))
$:.unshift(ROOT)

require 'rdoc/rdoc'

rdoc = RDoc::RDoc.new
options = []
options << '--all'
options << '--charset' << 'utf-8'
options << '--ri'
options << '--merge'
options << '--op' << File.join(ROOT, 'ri')
options << File.join(ROOT, 'geometry.rb')
rdoc.document(options)
