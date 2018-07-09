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
    module AttachmentPatch
      def self.included(base)

        base.class_eval do
          unloadable
          safe_attributes 'attachment_category_id'                    
          belongs_to      :attachment_category  
                    
          def css_class
            attachment_category.present? ? attachment_category.name.to_s.downcase.gsub(/[^\u0030-\u0039^\u0061-\u007A]/, "-") : ""
          end
                 
		  # Updates the filename and description of a set of attachments
		  # with the given hash of attributes. Returns true if all
		  # attachments were updated.
		  #
		  # Example:
		  #   Attachment.update_attachments(attachments, {
		  #     4 => {:filename => 'foo'},
		  #     7 => {:filename => 'bar', :description => 'file description'},
		  #     9 => {:filename => 'doe', :description => 'otther description', attachment_category => '1'}
		  #   })
		  #
		  def self.update_attachments(attachments, params)
			params = params.transform_keys {|key| key.to_i}

			saved = true
			transaction do
			  attachments.each do |attachment|
				if p = params[attachment.id]
				  attachment.filename = p[:filename] if p.key?(:filename)
				  attachment.description = p[:description] if p.key?(:description)
				  attachment.attachment_category_id = p[:attachment_category_id] if p.key?(:attachment_category_id)
				  saved &&= attachment.save
				end
			  end
			  unless saved
				raise ActiveRecord::Rollback
			  end
			end
			saved
		  end

        end
      end
      
    end
  end  
end

unless Attachment.included_modules.include?(RedmineAttachmentCategories::Patches::AttachmentPatch)
    Attachment.send(:include, RedmineAttachmentCategories::Patches::AttachmentPatch)
end
