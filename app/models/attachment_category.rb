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

class AttachmentCategory < ActiveRecord::Base
  
  ########################################################################################
  #
  # includes
  #
  ########################################################################################
  include Redmine::SafeAttributes
  
  ########################################################################################
  #
  # relations
  #
  ########################################################################################
  has_many :attachments
  
  ########################################################################################
  #
  # scopes
  #
  ########################################################################################
  scope :sorted, lambda { order(:position) }
  scope :categorized, lambda {|arg| where("LOWER(#{table_name}.name) = LOWER(?)", arg.to_s.strip)}
  
  ########################################################################################
  #
  # callbacks
  #
  ########################################################################################
  before_destroy :check_integrity
  
  ########################################################################################
  #
  # validators
  #
  ########################################################################################
  validates_presence_of   :name
  validates_uniqueness_of :name
  validates_length_of     :name, :maximum => 60
  
  ########################################################################################
  #
  # safe attributes
  #
  ########################################################################################
  safe_attributes  "name",
                   "html_color",
                   "position"
  
  ########################################################################################
  #
  # redmine libraries, plugins
  #
  ########################################################################################
  acts_as_positioned
  
  ########################################################################################
  #
  # class functions
  #
  ########################################################################################
  # none
  
  ########################################################################################
  #
  # field functions
  #
  ########################################################################################
  # none
  
  ########################################################################################
  #
  # specific functions
  #
  ########################################################################################
  def <=>(category)
    position <=> category.position
  end
  
  def to_s; name end
  
  ########################################################################################
  #
  # private
  #
  ########################################################################################
  private
  
  def check_integrity
    if Attachment.where(:attachment_category_id => id).any?
      raise "This status is used by some issues"
    end
  end
  
end
