require 'rubygems'
require 'lib/cached_memoize'
require 'active_support'

module Rails
end

class Person
  extend ActiveSupport::Memoizable
  extend ActiveSupport::CachedMemoize

  attr_reader :num_calls, :num_calls_again

  def initialize
    @num_calls = 0
    @num_calls_again = 0
  end

  def say_what
    @num_calls += 1
    'what'
  end
  cached_memoize :say_what, :expires_in => 1.minute

  def say_what_again(num)
    @num_calls_again += 1
    num.times.map do
      'what'
    end
  end
  cached_memoize :say_what_again
end

describe ActiveSupport::CachedMemoize do
  before do
    #cache = ActiveSupport::Cache.lookup_store(:memory_store)
    cache = ActiveSupport::Cache.lookup_store(:mem_cache_store)
    Rails.stub!(:cache).and_return(cache)

    @person = Person.new
  end

  it 'should cache memoized methods' do
    2.times { @person.say_what.should == 'what' }
    @person.num_calls.should == 1
  end

  it 'should cache memoized methods with multiple args' do
    @person.say_what_again(2).should == ['what', 'what']
    @person.num_calls_again.should == 1
  end
end
