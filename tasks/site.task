#-----------------------------------------------------------------------
# Website maintenance
#-----------------------------------------------------------------------
namespace :site do

    desc "Build the public website"
    task :build do
    end

    desc "Update the website on rubyforge"
    task :deploy => :build do
        sh "rsync -zav --delete #{Keybox::SPEC.local_site_dir} #{Keybox::SPEC.remote_site_location}"
    end

    #desc "View the website locally"
    task :view => :build do
        show_files Keybox::SPEC.local_site_dir
    end

end