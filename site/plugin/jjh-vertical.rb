#
#--
#
# $Id: vertical.rb 555 2006-12-27 15:40:14Z thomas $
#
# webgen: template based static website generator
# Copyright (C) 2004 Thomas Leitner
#
# This program is free software; you can redistribute it and/or modify it under the terms of the GNU
# General Public License as published by the Free Software Foundation; either version 2 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
# even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with this program; if not,
# write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#
#++
#

load_plugin 'webgen/plugins/menustyles/default'


  class JJHVerticalMenuStyle < MenuStyles::DefaultMenuStyle

    infos( :name => 'MenuStyle/JJHVertical',
           :author => "Jeremy Hinegardner",
           :summary => "Builds a vertical menu"
           )

    register_handler 'jjh-vertical'

    param 'startLevel', 1, 'The level at which the menu starts. For example, if set to 2 the top most ' +
      'menu items are not shown.'
    param 'minLevels', 1, 'Specifies how many levels should be always be shown, ie. how deep the menu is. ' +
      'For example, if minLevels = 3, then three levels are always shown at least.'
    param 'maxLevels', 3,  'Specifies the maximum number of levels that should be shown. ' +
      'For example, if maxLevels = 1, then only one level is shown.'
    param 'showCurrentSubtreeOnly', true, 'True if only the current subtree should be shown in the menu. ' +
      'If set to false, each subtree will be shown.'

    def internal_build_menu( src_node, menu_tree )
        <<-MENU
        <ul class=\"#{param('divClass')}\">
          #{submenu( src_node, menu_tree, 1) }
        </ul>
        MENU
    end

    #######
    private
    #######

    def submenu( src_node, menu_node, level )
      if menu_node.nil? \
        || level > param( 'maxLevels' ) + param( 'startLevel' ) - 1 \
        || ( ( level > param( 'minLevels' ) + param( 'startLevel' ) - 1 ) \
             && ( menu_node.level >= src_node.level \
                  || ( param( 'showCurrentSubtreeOnly' ) && !src_node.in_subtree_of?( menu_node.node_info[:node] ) )
                  )
             ) \
        || src_node.level < param( 'startLevel' ) \
        || (level == param('startLevel') && !src_node.in_subtree_of?( menu_node.node_info[:node] ))
        return ''
      end

      out = ""
      submenus = ''
      menu_node.each do |child|
        menu = child.has_children? ? submenu( src_node, child, level + 1 ) : ''
        style, link = menu_item_details( src_node, child.node_info[:node] )
        submenus << menu

        out << "<li #{style}>#{link}"
        out << menu
        out << "</li>\n"
      end

      if level < param( 'startLevel' )
        '' + submenus
      else
        out
      end
    end

  end

