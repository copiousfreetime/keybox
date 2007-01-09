#!/usr/bin/env ruby

# Define a task library for running webgen

require 'rake'
require 'rake/tasklib'
require 'webgen/website'

module Webgen
    module Rake

        # A Rake task that runs a webgen site.
        #
        # It is assumed that you have already used the 'webgen' command
        # to create the base directory for the site.  This task is here
        # to make it easier to integrate the generation of the website
        # within the broader scope of another project.
        #
        # Example:
        #
        #   Rake::WebgenTask.new do |web_task|
        #       t.directory = File.join(Dir.pwd, "webgen")
        #   end
        #
        # This will create a task that can be run with:
        #
        #   rake webgen
        #
        class WebgenTask < ::Rake::TaskLib
            
            # Name of webgen task. (default is :webgen)
            attr_accessor :name

            # The directory of the webgen site.  This would be the
            # directory of your config.yaml file.  Or the parent
            # directory of the src/ directory for webgen
            #
            # The default for this is assumed to be 
            #   File.join(Dir.pwd,"webgen")
            attr_accessor :directory

            # Create a webgen task
            def initialize(name = :webgen)
                @name = name
                @directory = File.join(Dir.pwd, "webgen")
                yield self if block_given?
                define
            end

            def define
                desc "Run webgen"
                task @name do |t|
                    website = Webgen::WebSite.new @directory
                    @out_dir = website.ws.param_for_plugin('Core/Configuration', 'outDir')
                    website.render
                end

                if @name then
                    clobber_task = paste("clobber_", @name)

                    desc "Remove webgen output"
                    task clobber_task do 
                        rm_r @out_dir rescue nil
                    end

                    task :clobber => [clobber_task]
                    task @name => clobber_task
                end
                self
            end
        end
    end
end

