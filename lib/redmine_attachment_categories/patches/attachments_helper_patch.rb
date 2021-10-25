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
    module AttachmentsHelperPatch
    
      def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
        base.class_eval do
        
          unloadable
          
          if Rails::VERSION::MAJOR >= 5
          
            alias_method :render_api_attachment_attributes_without_attachment_category, :render_api_attachment_attributes
            alias_method :render_api_attachment_attributes, :render_api_attachment_attributes_with_attachment_category
          else
            alias_method_chain :render_api_attachment_attributes, :attachment_category
          end
          
        end #base
        
      end #self
      
      module InstanceMethods
      
        # ------------------------------------------------------------------------------#
        # render attachment, which honors
        # the attachment_category
        # ------------------------------------------------------------------------------#
        def render_api_attachment_attributes_with_attachment_category(attachment, api)
          render_api_attachment_attributes_without_attachment_category(attachment, api)
          if attachment.attachment_category
            api.attachment_category(
                :id => attachment.attachment_category.id,
                :name => attachment.attachment_category.name
            )
          end
        end
        
      end #module
      
      module ClassMethods
      
      end #module
      
    end #module
  end #module
end #module

unless AttachmentsHelper.included_modules.include?(RedmineAttachmentCategories::Patches::AttachmentsHelperPatch)
  AttachmentsHelper.send(:include, RedmineAttachmentCategories::Patches::AttachmentsHelperPatch)
end
