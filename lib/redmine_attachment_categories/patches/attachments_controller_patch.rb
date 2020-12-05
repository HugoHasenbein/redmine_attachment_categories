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

module RedmineAttachmentCategories
  module Patches
    module AttachmentsControllerPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        
        base.class_eval do
          unloadable
            
          alias_method   :update_all_params, :update_all_params_with_attachment_category_id
          
        end #base
        
      end #self
      
      module InstanceMethods
      
        # Returns attachments param for #update_all
        def update_all_params_with_attachment_category_id
          {:archive    => params.permit(:archive), 
          :attachments => params.permit(:attachments => [:filename, :description, :attachment_category_id]).require(:attachments)}
        end #def
        
      end #module      
    end #module
  end #module
end #module

unless AttachmentsController.included_modules.include?(RedmineAttachmentCategories::Patches::AttachmentsControllerPatch)
    AttachmentsController.send(:include, RedmineAttachmentCategories::Patches::AttachmentsControllerPatch)
end



