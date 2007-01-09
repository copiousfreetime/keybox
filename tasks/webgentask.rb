# -*- ruby -*-

#
#--
# webgentask.rb:
#
#   Define a task library for running webgen
#
# Copyright (C) 2007 Jeremy Hinegardner
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or (at
# your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
# USA
#
#++
#

require 'rake'
require 'rake/tasklib'
require 'webgen/website'

module Webgen

    module Rake

        ##
        # A Rake task that generates a webgen website.
        #
        # It is assumed that you have already used the 'webgen' command
        # to create the base directory for the site.  This task is here
        # to make it easier to integrate the generation of the website
        # within the broader scope of another project.
        #
        # === Basics
        #
        #   require 'webgen/rake/webgentask'
        #
        #   Webgen::Rake::WebgenTask.new do |t|
        #       t.directory = File.join(Dir.pwd, "webgen")
        #   end
        #
        # === Attributes
        #
        # The attributes available to the task in the new block are:A
        #
        # * name              - the name of the task.  This can also be set as
        #                       a parameter to new (default :webgen)
        # * directory         - the root directory of the webgen site
        #                       (default File.join(Dir.pwd, "webgen")
        # * clobber_directory - remove +directory+ during clobber
        #                       (default false)
        # 
        # === Tasks Provided
        # 
        # The tasks provided are :
        #
        # * webgen         - create the website
        # * clobber_webgen - remove all the files created during creation
        #
        # If the +name+ attribute is changed then the Tasks are changed
        # to relect that.  For Example:
        #
        #   Webgen::Rake::WebgenTask.new(:my_webgen) do |t|
        #       t.clobber_directory = true
        #   end
        #
        # This will create tasks:
        #
        # * my_webgen
        # * clobber_my_webgen
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

            # During the clobber, should +directory+ be removed
            # default is false
            attr_accessor :clobber_directory

            # Create a webgen task
            def initialize(name = :webgen)
                @name               = name
                @directory          = File.join(Dir.pwd, "webgen")
                @clobber_directory  = false

                yield self if block_given?

                @website        = Webgen::WebSite.new @directory
                @out_dir        = File.expand_path(@website.param_for_plugin('Core/Configuration', 'outDir'))

                define
            end

            def define
                desc "Run webgen"
                task @name do |t|
                    Dir.chdir(@directory) do 
                        begin
                            # some items from webgen may be sensitive to the
                            # current directory when it runs
                            @website.render
                            puts "Webgen rendered to : #{@out_dir}"
                            @rendered_files << @website.manager['Misc/RenderedFiles'].files
                        rescue => e
                            puts "Webgen task failed: #{e}"
                            raise e
                        end
                    end
                end

                clobber_task = paste("clobber_",@name)

                desc "Remove webgen products"
                task clobber_task do 
                    puts @rendered_files
                    #rm_r @rendered_files rescue nil
                end
                
                task :clobber => [clobber_task]
                task @name => clobber_task
                self
            end

            # callback method for add_msg_listener
            def call(node)
                puts node.path
                @rendered_files << node.path
            end
        end
    end
end

