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

class CreateAttachmentCategories < ActiveRecord::Migration[4.2]
  def self.up
    create_table :attachment_categories do |t|
      t.column :name,       :string,  limit: 60, default: '',        null: false
      t.column :html_color, :string,  limit: 7,  default: '#FFFFFF', null: false
      t.column :position,   :integer, default: nil
    end
    attachment_categories = [
      ['Category A', '#FFCCCC'],
      ['Category B', '#CCFFCC'],
      ['Category C', '#CCCCFF'],
      ['Category D', '#FFCCFF']
    ]
    attachment_categories.each do |name, html_color|
      AttachmentCategory.create(name: name, html_color: html_color)
    end
  end

  def self.down
    drop_table :attachment_categories
  end
end
