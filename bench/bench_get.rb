$:.unshift(File.expand_path('../lib', File.dirname(__FILE__)))

require 'test/unit'
require 'active_support'

require 'kari/ri'

require 'rubygems' rescue LoadError
require 'mocha'

require 'benchmark'

class GetBench

  def new
    Kari::RI::Index.rebuild
    2.times { Kari::RI.get('Object') }
  end

  def bench_get(n=1)
    puts
    puts "GET #{runs(n)}"
    Benchmark.bm(38) do |x|
      x.report("Get for `Object':") { n.times {
        Kari::RI.get('Object')
      } }
      x.report("Get for `String#to_blob':") { n.times {
        Kari::RI.get('String#to_blob')
      } }
      x.report("Get for `SOAP::WSDLDriver#httpproxy':") { n.times {
        Kari::RI.get('SOAP::WSDLDriver#httpproxy')
      } }
    end
  end

  def run
    bench_get(10000)
  end
  
  private
  
  def runs(n)
    "(#{n} #{n > 1 ? 'runs' : 'run'})"
  end
end

GetBench.new.run