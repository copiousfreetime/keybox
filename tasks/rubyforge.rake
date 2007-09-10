if HAVE_RUBYFORGE then 
    #-----------------------------------------------------------------------
    # Rubyforge additions to the task library.
    #-----------------------------------------------------------------------
    namespace :dist do
    
        desc "Release files to rubyforge"
        task :rubyforge => [:clean, :package] do
    
            rubyforge = RubyForge.new
    
            # make sure this release doesn't already exist
            releases = rubyforge.autoconfig['release_ids']
            if releases.has_key?(Keybox::SPEC.name) and releases[Keybox::SPEC.name][Keybox::VERSION] then
                abort("ERROR: Release #{Keybox::VERSION} already exists!  Unable to release.")
            end
    
            config = rubyforge.userconfig
            config["release_notes"]     = Keybox::SPEC.description
            config["release_changes"]   = last_changeset
            config["Prefomatted"]       = true


            puts "Uploading to rubyforge..."
            files = FileList[File.join("pkg","#{Keybox::SPEC.name}-#{Keybox::VERSION}.*")].to_a
            rubyforge.login
            rubyforge.add_release(Keybox::SPEC.rubyforge_project, Keybox::SPEC.name, Keybox::VERSION, *files)
            puts "done."
        end
    end

    namespace :announce do
        desc "Post news of #{Keybox::SPEC.name} to #{Keybox::SPEC.rubyforge_project} on rubyforge"
        task :rubyforge do
            subject, title, body, urls = announcement
            rubyforge = RubyForge.new
            rubyforge.login
            rubyforge.post_news(Keybox::SPEC.rubyforge_project, subject, "#{title}\n\n#{urls}\n\n#{body}")
            puts "Posted to rubyforge"
        end
    end
end