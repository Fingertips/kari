$:.unshift(File.expand_path('../lib', File.dirname(__FILE__)))

require 'test/unit'
require 'active_support'

require 'kari/ri'

require 'rubygems' rescue LoadError
require 'mocha'

require 'benchmark'

class SearchBench

  def new
    Kari::RI::Index.rebuild
    2.times { Kari::RI.search('benchmark') }
  end

  def bench_quick_search(n=1)
    puts
    puts "QUICK SEARCH #{runs(n)}"
    Benchmark.bm(30) do |x|
      x.report("Search for `li':") { n.times {
        Kari::RI.quick_search('li')
      } }
      x.report("Search for `string render':") { n.times {
        Kari::RI.quick_search('string render')
      } }
      x.report("Search for `bench':") { n.times {
        Kari::RI.quick_search('bench')
      } }
    end
  end

  def bench_search(n=1)
    puts
    puts "SEARCH #{runs(n)}"
    Benchmark.bm(30) do |x|
      x.report("Search for `li':") { n.times {
        Kari::RI.search('li')
      } }
      x.report("Search for `string render':") { n.times {
        Kari::RI.search('string render')
      } }
      x.report("Search for `bench':") { n.times {
        Kari::RI.search('bench')
      } }
    end
  end

  def run
    bench_quick_search(10)
    bench_search(10)
  end
  
  private
  
  def runs(n)
    "(#{n} #{n > 1 ? 'runs' : 'run'})"
  end
end

SearchBench.new.run