#-----------------------------------------------------------------------
# Documentation
#-----------------------------------------------------------------------
namespace :doc do |ns|

    # generating documentation locally
    Rake::RDocTask.new do |rdoc|
        rdoc.rdoc_dir   = Keybox::SPEC.local_rdoc_dir
        rdoc.options    = Keybox::SPEC.rdoc_options 
        rdoc.rdoc_files = Keybox::SPEC.rdoc_files
    end

    desc "Deploy the RDoc documentation to #{Keybox::SPEC.remote_rdoc_location}"
    task :deploy => :rerdoc do
        sh "rsync -zav --delete #{Keybox::SPEC.local_rdoc_dir}/ #{Keybox::SPEC.remote_rdoc_location}"
    end
    
    if HAVE_HEEL then
        desc "View the RDoc documentation locally"
        task :view => :rdoc do
            sh "heel --root #{Keybox::SPEC.local_rdoc_dir}"
        end
    end
end
