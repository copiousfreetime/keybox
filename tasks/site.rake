#-----------------------------------------------------------------------
# Website maintenance
#-----------------------------------------------------------------------
namespace :site do
    
    desc "Remove all the files from the local deployment of the site"
    task :clobber do
        rm_rf Keybox::SPEC.local_site_dir
    end

    desc "Update the website on #{Keybox::SPEC.remote_site_location}"
    task :deploy => :build do
        sh "rsync -zav --delete #{Keybox::SPEC.local_site_dir}/ #{Keybox::SPEC.remote_site_location}"
    end

    if HAVE_WEBBY then
        desc "Build the public website"
        task :build do
            sh "pushd website && rake"
        end
    end

    if HAVE_HEEL then
        desc "View the website locally"
        task :view => :build do
            sh "heel --root #{Keybox::SPEC.local_site_dir}"
        end
    end

end