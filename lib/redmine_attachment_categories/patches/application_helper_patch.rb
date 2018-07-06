# encoding: utf-8
#
# Redmine plugin for quick attribute setting of redmine issues
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

module AttachmentCategories
  module Patches 
    module ApplicationHelperPatch
      def self.included(base)
#        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
        base.class_eval do

          unloadable 
          
          alias_method_chain :thumbnail_tag, :attachment_category
          alias_method_chain :link_to_attachment, :attachment_category
            
        end #base
      end #self

      module InstanceMethods    

          # ------------------------------------------------------------------------------#
          # Generates a link to an attachment.
          # Options:
          # * :text - Link text (default to attachment filename)
          # * :download - Force download (default: false)
          # ------------------------------------------------------------------------------#
          def link_to_attachment_with_attachment_category(attachment, options={})
            text = options.delete(:text) || attachment.filename
            route_method = options.delete(:download) ? :download_named_attachment_url : :named_attachment_url
            html_options = options.slice!(:only_path)
            options[:only_path] = true unless options.key?(:only_path)
            url = send(route_method, attachment, attachment.filename, options)
            link_to( text, url, html_options) + (route_method == :download_named_attachment_url ? "" : attachment_category_tag(attachment.attachment_category,:span))
          end

          # ------------------------------------------------------------------------------#
          # creates a thumbnail tag, which honors
          # the attachment_category
          # ------------------------------------------------------------------------------#
          def thumbnail_tag_with_attachment_category(attachment, options={})
            thumbnail_tag_without_attachment_category(attachment) + ( options.key?(:no_attribute_tag) ? "" : "<br />".html_safe + attachment_category_tag(attachment.attachment_category, :span) )
          end

          # ------------------------------------------------------------------------------#
          # creates an attachment_category_tag
          # 
          # ------------------------------------------------------------------------------#
          def attachment_category_tag(attachment_category, tag, html_options={})
            if attachment_category.present?
              _css_color = contrast_css_color( attachment_category.html_color )
              _tag = content_tag tag, 
                                 h(attachment_category.name),
                                 {:class => "attachment_category " + Setting['plugin_redmine_attachment_categories']['attachment_category_style'].presence || "attachment_category_default",
                                  :style => "background:#{attachment_category.html_color};color:#{_css_color};"
                                 }.merge(html_options)
            else
              _tag = content_tag tag, 
                                 "&nbsp;".html_safe,
                                 {:class => "attachment_category "
                                 }.merge(html_options)
            end 
            _tag.html_safe
          end #def

          def contrast_css_color( _html_color )
            begin
              _rgb = _html_color.downcase.scan(/[0-9a-f]{2}/).map(&:hex)
              (0.213 * _rgb[0] + 0.715 * _rgb[1] + 0.072 * _rgb[2])/255 > 0.5 ? "black" : "white"
            rescue
              "black"
            end
          end #def
          
          
      end #module
      
#       module ClassMethods
#       end #module
      
    end #module
  end #module
end #module

unless ApplicationHelper.included_modules.include?(AttachmentCategories::Patches::ApplicationHelperPatch)
    ApplicationHelper.send(:include, AttachmentCategories::Patches::ApplicationHelperPatch)
end


