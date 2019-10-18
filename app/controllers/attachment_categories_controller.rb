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

class AttachmentCategoriesController < ApplicationController

  layout 'admin'
  self.main_menu = false

  before_action :require_admin, except: :index
  before_action :require_admin_or_api_request, only: :index
  accept_api_auth :index

  def index
    @attachment_categories = AttachmentCategory.sorted.to_a
    respond_to do |format|
      format.html { render layout: false if request.xhr? }
      format.api
    end
  end

  def new
    @attachment_category = AttachmentCategory.new
  end

  def create
    @attachment_category = AttachmentCategory.new(permitted_attributes)
    if @attachment_category.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to attachment_categories_path
    else
      render action: 'new'
    end
  end

  def edit
    @attachment_category = AttachmentCategory.find(params[:id])
  end

  def update
    @attachment_category = AttachmentCategory.find(params[:id])
    if @attachment_category.update_attributes(permitted_attributes)
      respond_to do |format|
        format.html {
          flash[:notice] = l(:notice_successful_update)
          redirect_to attachment_categories_path(page: params[:page])
        }
        format.js { render nothing: true }
      end
    else
      respond_to do |format|
        format.html { render action: 'edit' }
        format.js { render nothing: true, status: 422 }
      end
    end
  end

  def destroy
    AttachmentCategory.find(params[:id]).destroy
    redirect_to attachment_categories_path
  rescue
    flash[:error] = l(:error_unable_delete_attachment_category)
    redirect_to attachment_categories_path
  end

  def update_attachment_color
    if request.post? && AttachmentCategory.update_attachment_colors
      flash[:notice] = l(:notice_attachment_colors_updated)
    else
      flash[:error] =  l(:error_attachment_colors_not_updated)
    end
    redirect_to attachment_categories_path
  end

  private

  def permitted_attributes
    params.require(:attachment_category).permit(:name, :html_color)
  end
end
