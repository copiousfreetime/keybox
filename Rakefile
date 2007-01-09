
$: << "./lib"

require 'rubygems'
require 'spec/rake/spectask'
require 'hoe'
require 'keybox'

# get the webgen task
$: << "./tasks"
require 'webgentask'

hoe = Hoe.new('keybox', Keybox::VERSION.join(".")) do |p|
  p.rubyforge_name  = 'keybox'
  p.summary         = p.paragraphs_of('README.txt', 2).join("\n")
  p.description     = p.paragraphs_of('README.txt', 2).join("\n\n")
  p.url             = Keybox::HOMEPAGE
  p.changes         = p.paragraphs_of('History.txt', 0..1).join("\n\n")
  p.clean_globs <<  "doc/*"
  p.email           = Keybox::AUTHOR_EMAIL
  p.version         = Keybox::VERSION.join(".")
  p.author          = Keybox::AUTHOR
  p.rdoc_dir        = "doc/rdoc"
  p.publish_dir     = "doc/"

  # hoe is not necessary to run the application, just to build and test
  # it.
  p.extra_deps      = [] 
end

desc "Create the Manifest.txt file"
task :create_manifest => :clean do
    file_list = FileList['*.txt',
                         '*.textile',
                         'bin/**', 
                         'lib/**/*.rb', 
                         'resource/**',
                         'spec/**/*.rb' ]
    File.open("Manifest.txt", "w") do |manifest|
        file_list.each do |fname|
            manifest.puts fname
        end
    end
end

# defaults are good here
Webgen::Rake::WebgenTask.new(:blarggh)

Spec::Rake::SpecTask.new do |t|
    t.warning   = true
    t.rcov      = true
    t.rcov_dir  = "doc/coverage"
    t.libs      << "./lib" 
end

# add :webgen and :spec as prerequisites for :docs
desc "Generate all docs"
task :docs => [:webgen,:spec]  do |t|
    t.prerequisites.each { |p| puts "    #{p}" }
end

