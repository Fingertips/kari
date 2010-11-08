require File.expand_path('../../spec_helper', __FILE__)

describe "FilteringArrayController" do
  extend Controllers
  
  before do
    @controller = FilteringArrayController.alloc.init
    
    @objects = []
    @objects << ScoredRubyName.alloc.initWithName('Benchmark', karidocFilename:'/path/to/benchmark.karidoc', query:'bench')
    @objects << ScoredRubyName.alloc.initWithName('Benchmark::Base', karidocFilename:'/path/to/benchmark/base.karidoc', query:'bench')
    @objects << ScoredRubyName.alloc.initWithName('Debugger', karidocFilename:'/path/to/benchmark/debugger.karidoc', query:'bench')
    @objects << ScoredRubyName.alloc.initWithName('Bejeweled', karidocFilename:'/path/to/benchmark/bejeweled.karidoc', query:'bench')
  end
  
  it "orders the objects" do
    @controller.addObjects(@objects)
    @controller.arrangeObjects(@objects).should == @controller.arrangedObjects
  end
end