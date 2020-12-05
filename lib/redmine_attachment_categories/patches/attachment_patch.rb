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
          #     9 => {:filename => 'doe', :description => 'other description', attachment_category => '1'}
          #   })
          #
          def self.update_attachments(attachments, params)
            archive = params[:archive]
            params  = params[:attachments].transform_keys {|key| key.to_i}
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
            self.checkin_attachments(attachments) if archive.present?
            saved
          end
          
          #
          #
          #
          def self.checkin_attachments(attachments)
          
            custom_field_name = Setting['plugin_redmine_attachment_categories']['custom_field_name']
            
            attachments.each do |attachment|
              repos = attachment.project && attachment.project.repositories
              if repos.present?
                repos.each do |repo|
                  if repo.is_default? && repo.scm_name == "Filesystem"
                    if attachment.container.respond_to?(:visible_custom_field_values)
                      subdir = attachment.container.visible_custom_field_values.select {|v| v.custom_field.name == custom_field_name}.first if custom_field_name.present?
                      subdir ||= ""
                    else
                      subdir=""
                    end
                    dir = File.join( 
                      repo.url, 
                      subdir.to_s, 
                      (attachment.attachment_category && attachment.attachment_category.name.parameterize).to_s
                    )
                    FileUtils.mkdir_p(dir) unless File.exist?(dir)
                    existing_files = Dir.glob(File.join(dir, "*")).map {|file| File.basename(file)}
                    unique_filename = RedmineAttachmentCategories::Lib::RacFile.unique_filename(existing_files, attachment.filename)
                    # attachment#filename is already sanitized by attachment
                    file = File.join(dir, unique_filename)
                    FileUtils.cp(attachment.diskfile, file)
                    FileUtils.touch(file, :mtime => attachment.created_on.to_datetime.to_time)
                  end #if
                end #each
              end #if
            end #each
          end #def
          
          
        end
      end
      
    end
  end  
end

unless Attachment.included_modules.include?(RedmineAttachmentCategories::Patches::AttachmentPatch)
    Attachment.send(:include, RedmineAttachmentCategories::Patches::AttachmentPatch)
end
