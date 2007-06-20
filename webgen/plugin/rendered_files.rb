#
#--
# rendered_files.rb : 
#
#   webgen miscellaneous plugin to record the paths of all the files and
#   directories written during rendering.  
#
# Copyright (C) 2007 Jeremy Hinegardner
#
#++
#

load_plugin 'webgen/plugins/filehandlers/filehandler'

module MiscPlugins

    # This plugin registers as a listener for message :after_node_written 
    # with the 'Core/FileHandler' plugin.
    # 
    # When its callback is invoked, if the node in question is a file or
    # directory it records the nodes fully expanded path in @files
    #
    # The list of files currently rendered can then be retrieved by
    # getting a handle on this plugin and calling +files+.
    #
    #   Example:
    #
    #       @plugin_manager['Misc/RenderedFiles'].files
    #
    class RenderedFilesPlugin < Webgen::Plugin
        infos( :name => 'Misc/RenderedFiles',
               :author => 'Jeremy Hinegardner <jeremy@hinegardner.org>',
               :summary => 'Keeps track of all the files and directories written during rendering.')

        depends_on 'Core/FileHandler'

        attr_reader :files

        def initialize(plugin_manager)
            super
            @plugin_manager['Core/FileHandler'].add_msg_listener(:after_node_written, method(:record_file))
            @files = []
        end

        #######
        private
        #######

        # we use expand_path to remove possible environmental parameters
        # or ../'s in the path
        def record_file(node)
            if node.is_file? or node.is_directory? then
                @files << File.expand_path(node.full_path)
            end
        end
    end
end
