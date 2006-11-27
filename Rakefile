# -*- ruby -*-

$: << "./lib"

require 'rubygems'
require 'spec/rake/spectask'
require 'hoe'
require 'keybox'

Hoe.new('keybox', Keybox::VERSION.join(".")) do |p|
  p.rubyforge_name = 'keybox'
  # p.summary = 'FIX'
  # p.description = p.paragraphs_of('README.txt', 2..5).join("\n\n")
  # p.url = p.paragraphs_of('README.txt', 0).first.split(/\n/)[1..-1]
  p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")
end

Spec::Rake::SpecTask.new do |t|
    t.warning   = true
    t.rcov      = true
    t.libs      << "./lib" 
end

