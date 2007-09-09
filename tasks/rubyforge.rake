require 'rubyforge'

#-----------------------------------------------------------------------
# Packaging and Distribution - push to rubyforge
#-----------------------------------------------------------------------
namespace :dist do
    
    desc "Release files to rubyforge"
    task :release => [:clean, :package] do
        
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

#-----------------------------------------------------------------------
# Announcements - Create an email text file, and post news to rubyforge
#-----------------------------------------------------------------------
def changes
    change_file = File.expand_path(File.join(File.basename(__FILE__),"..","CHANGES"))
    sections    = File.read(change_file).split(/^(?===)/)
end
def last_changeset
    changes[1]
end

def announcement
    urls    = "  #{Keybox::SPEC.homepage}"
    subject = "#{Keybox::SPEC.name} #{Keybox::VERSION} Released"
    title   = "#{Keybox::SPEC.name} version #{Keybox::VERSION} has been released."
    body    = <<BODY
#{Keybox::SPEC.description.rstrip}

{{ Changelog for Version #{Keybox::VERSION} }}

#{last_changeset.rstrip}

BODY

    return subject, title, body, urls
end

namespace :announce do
    desc "create email for ruby-talk"
    task :email do
        subject, title, body, urls = announcement

        File.open("email.txt", "w") do |mail|
            mail.puts "From: #{Keybox::SPEC.author} <#{Keybox::SPEC.email}>"
            mail.puts "To: ruby-talk@ruby-lang.org"
            mail.puts "Date: #{Time.now.rfc2822}"
            mail.puts "Subject: [ANN] #{subject}"
            mail.puts
            mail.puts title
            mail.puts
            mail.puts urls
            mail.puts 
            mail.puts body
            mail.puts 
            mail.puts urls
        end
        puts "Created the following as email.txt:"
        puts "-" * 72
        puts File.read("email.txt")
        puts "-" * 72
    end
    
    CLOBBER << "email.txt"

    desc "Post news of #{Keybox::SPEC.name} to #{Keybox::SPEC.rubyforge_project} on rubyforge"
    task :post_news do
        subject, title, body, urls = announcement
        rubyforge = RubyForge.new
        rubyforge.login
        rubyforge.post_news(Keybox::SPEC.rubyforge_project, subject, "#{title}\n\n#{urls}\n\n#{body}")
        puts "Posted to rubyforge"
    end

end
