#-----------------------------------------------------------------------
# Distribution
#-----------------------------------------------------------------------
namespace :dist do

    GEM_SPEC = eval(Keybox::SPEC.to_ruby)

    Gem::PackageTask.new(GEM_SPEC) do |pkg|
        pkg.need_tar = Keybox::SPEC.need_tar
        pkg.need_zip = Keybox::SPEC.need_zip
    end
    
    desc "Install as a gem"
    task :install => [:clobber_package, :package] do
        sh "sudo gem install pkg/#{Keybox::SPEC.full_name}.gem"
    end

    # uninstall the gem and all executables
    desc "Uninstall gem"
    task :uninstall do 
        sh "sudo gem uninstall #{Keybox::SPEC.name} -x"
    end

    desc "dump gemspec"
    task :gemspec do
        puts Keybox::SPEC.to_ruby
    end

    desc "reinstall gem"
    task :reinstall => [:install, :uninstall]

    desc "distribute copiously"
    task :copious => [:package] do
        Rake::SshFilePublisher.new('jeremy@copiousfreetime.org',
                               '/var/www/vhosts/www.copiousfreetime.org/htdocs/gems/gems',
                               'pkg',"#{Keybox::SPEC.full_name}.gem").upload
        sh "ssh jeremy@copiousfreetime.org rake -f /var/www/vhosts/www.copiousfreetime.org/htdocs/gems/Rakefile"
    end
end