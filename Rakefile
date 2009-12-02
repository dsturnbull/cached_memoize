require 'rubygems'
require 'spec/rake/spectask'

task :default => :spec

specs = ['spec/cached_memoize_spec.rb'] 

desc 'Run all specs'
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_opts  = ['--options', 'spec/spec.opts']
  t.spec_files = specs
end

desc 'Run all specs with rcov'
Spec::Rake::SpecTask.new('rcov') do |t|
  t.spec_files = specs
  t.rcov = true
end
