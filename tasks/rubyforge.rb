# create the website for use on rubyforge
require 'webgen/rake/webgentask'
Webgen::Rake::WebgenTask.new

# generate the content for the website
task :publish_docs => [:webgen, :rdoc, :spec]

# push the website and all documentation to rubyforge
require 'rubyforge'
require 'yaml'
desc "Sync #{PKG_INFO.publish_dir} with rubyforge site"
task :sync_rubyforge do |rf|
    rf_config = YAML::load(File.read(File.join(ENV["HOME"],".rubyforge","user-config.yml")))
    dest_host = "#{rf_config['username']}@rubyforge.org"
    dest_dir  = "/var/www/gforge-projects/#{PKG_INFO.rubyforge_name}"

    # trailing slash on source, none on destination
    sh "rsync -zav --delete #{PKG_INFO.publish_dir}/ #{dest_host}:#{dest_dir}"
end

desc "Remove all content from the rubyforge site"
task :clean_rubyforge => [:clobber, :sync_rubyforge] 

desc "Push the published docs to rubyforge"
task :publish_rubyforge => [:publish_docs, :sync_rubyforge] 

