#-----------------------------------------------------------------------
# Testing - this is either test or spec, include the appropriate one
#-----------------------------------------------------------------------
namespace :test do

    task :default => :spec

    require 'rspec/core/rake_task'
    RSpec::Core::RakeTask.new do |r|
        r.rspec_opts = %w(--format documentation --color)
    end

    if HAVE_HEEL then
        desc "View the code coverage report locally"
        task :view_coverage => [:spec] do
            sh "heel --root #{Keybox::SPEC.local_coverage_dir}"
        end 
    end
end