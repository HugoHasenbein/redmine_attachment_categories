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
    module ActsAsAttachablePatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        
        base.class_eval do
          unloadable
          
        def save_attachments(attachments, author=User.current)
          if attachments.respond_to?(:to_unsafe_hash)
            attachments = attachments.to_unsafe_hash
          end
          
          if attachments.is_a?(Hash)
            attachments = attachments.stringify_keys
            attachments = attachments.to_a.sort {|a, b|
              if a.first.to_i > 0 && b.first.to_i > 0
                a.first.to_i <=> b.first.to_i
              elsif a.first.to_i > 0
                1
              elsif b.first.to_i > 0
                -1
              else
                a.first <=> b.first
              end
            }
            attachments = attachments.map(&:last)
          end
          if attachments.is_a?(Array)
            @failed_attachment_count = 0
            attachments.each do |attachment|
              next unless attachment.present?
              a = nil
              if file = attachment['file']
                a = Attachment.create(:file => file, :author => author)
              elsif token = attachment['token'].presence
                a = Attachment.find_by_token(token)
                unless a
                  @failed_attachment_count += 1
                  next
                end
                a.filename = attachment['filename'] unless attachment['filename'].blank?
                a.content_type = attachment['content_type'] unless attachment['content_type'].blank?
              end
              next unless a
              a.description = attachment['description'].to_s.strip
              a.attachment_category_id = attachment['attachment_category_id'].to_s.strip
              if a.new_record?
                unsaved_attachments << a
              else
                saved_attachments << a
              end
            end
          end
          {:files => saved_attachments, :unsaved => unsaved_attachments}
        end #def
        
        end #base
      end #self
      
      module InstanceMethods
                   
      end #module
    end #module
  end #module
end #module

unless Redmine::Acts::Attachable::InstanceMethods.included_modules.include?(RedmineAttachmentCategories::Patches::ActsAsAttachablePatch)
  Redmine::Acts::Attachable::InstanceMethods.send(:include, RedmineAttachmentCategories::Patches::ActsAsAttachablePatch)
end
