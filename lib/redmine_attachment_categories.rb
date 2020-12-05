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

Rails.configuration.to_prepare do
  
  #------------------------------------------------------------------------------------- #
  # patch redmine core plugin
  #------------------------------------------------------------------------------------- #
  require 'redmine_attachment_categories/patches/acts_as_attachable_patch'
  
  #------------------------------------------------------------------------------------- #
  # patch helpers and controllers 
  #------------------------------------------------------------------------------------- #
  require 'redmine_attachment_categories/patches/application_helper_patch'  
  require 'redmine_attachment_categories/patches/attachment_patch'
  require 'redmine_attachment_categories/patches/attachments_controller_patch'
  require 'redmine_attachment_categories/patches/auto_completes_controller_patch'
   
  #------------------------------------------------------------------------------------- #
  # hooks 
  #------------------------------------------------------------------------------------- #
  require 'redmine_attachment_categories/hooks/layout_base_hook'

  #------------------------------------------------------------------------------------- #
  # utilities 
  #------------------------------------------------------------------------------------- #
  require 'redmine_attachment_categories/lib/rac_file'
end

