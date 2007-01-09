#!/usr/bin/env ruby

# Define a task library for running webgen

require 'rake'
require 'rake/tasklib'
require 'webgen/website'

module Webgen
    module Rake

        # A Rake task that runs a webgen site
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

            # Name of the directory for webgen, defaults to :
            # File.join(Dir.pwd, "webgen")
            attr_accessor :directory

            # Create a webgen task
            def initialize(name = :webgen)
                @name = name
                @directory = File.join(Dir.pwd, "webgen")
                yield self if block_given?
                define
            end

            def define
                super
                task @name do 
                    website = Webgen::WebSite.new @directory
                    @out_dir = website.ws.param_for_plugin('Core/Configuration', 'outDir')
                    website.render
                end

                if @name then
                    desc "Remove webgen output"
                    clobber_task = paste("clobber_", @name)

                    task clobber_task do 
                        rm_r @out_dir rescue nil
                    end

                    task :clobber => [clobber_rask]
                    task @name => clobber_task
                end
                self
            end
        end
    end
end

