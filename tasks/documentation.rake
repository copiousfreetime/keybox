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

    if HAVE_HEEL then
        desc "View the RDoc documentation locally"
        task :view => :rdoc do
            show_files Keybox::SPEC.local_rdoc_dir
        end
    end
end
