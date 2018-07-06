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
    module AutoCompletesControllerPatch
      def self.included(base)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable
          skip_before_filter :find_project, :only => [:attachment_descriptions]
        end
      end

      module InstanceMethods

        def attachment_descriptions
          @attachments= []
		  q = (params[:q] || params[:term]).to_s.strip
		  if q.present?
			if q.match(/.*/)
			  @descriptions = Attachment.
			                    distinct.
			                    where(:container_type => "Issue").
			                    where("description like ?", "%#{q}%").
			                    order(:created_on => :desc).
			                    limit(20).
			                    pluck(:description).
			                    to_a
			end
			@attachments.compact!
		  end
          render :layout => false 
        end #def
         
      end #module
    end #module
  end #module
end #module


unless AutoCompletesController.included_modules.include?(AttachmentCategories::Patches::AutoCompletesControllerPatch)
    AutoCompletesController.send(:include, AttachmentCategories::Patches::AutoCompletesControllerPatch)
end
