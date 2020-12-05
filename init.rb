# encoding: utf-8
#
# Redmine plugin for having a category tag on attachments
#
# Copyright © 2018 Stephan Wenzel <stephan.wenzel@drwpatent.de>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
#
# 1.0.3
#        runing on redmine 3.4.x
#
# 2.0.0 
#        runing on redmine 4.x

require 'redmine'

Redmine::Plugin.register :redmine_attachment_categories do
  name 'Attachment Categories'
  author 'Stephan Wenzel'
  description 'This is a plugin for Redmine for having a category tag on attachments'
  version '2.0.0'
  url 'https://github.com/HugoHasenbein/redmine_attachment_categories'
  author_url 'https://github.com/HugoHasenbein/redmine_attachment_categories'
  
#-----------------------------------------------------------------------------------------
# Plugin setting
#-----------------------------------------------------------------------------------------
  settings :default => {'attachment_category_style'     => 'attachment_category_default'
                        },
           :partial => 'settings/redmine_attachment_categories/plugin_settings'
           
#-----------------------------------------------------------------------------------------
# Menus
#-----------------------------------------------------------------------------------------
  menu :admin_menu, 
       :attachment_categories, # name and id
       { controller: 'attachment_categories', action: 'index' },
       after:   :enumerations, 
       html:    { class: 'icon icon-attachment' },
       caption: :label_attachment_category_plural
       
end

#---------------------------------------------------------------------------------------
# Plugin Library
#---------------------------------------------------------------------------------------
require 'redmine_attachment_categories'



