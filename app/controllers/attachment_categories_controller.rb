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

  ########################################################################################
  #
  # constants
  #
  ########################################################################################
  layout 'admin'
  self.main_menu = false
  
  ########################################################################################
  #
  # callbacks
  #
  ########################################################################################
  before_action   :require_admin,                :except => [:index]
  before_action   :require_admin_or_api_request, :only   => [:index]
  before_action   :find_attachment_category,     :only   => [:edit, :update, :destroy]
  accept_api_auth :index
  
  ########################################################################################
  #
  # standard controller functions
  #
  ########################################################################################
  def index
    @attachment_categories = AttachmentCategory.sorted.to_a
    respond_to do |format|
      format.html { render :layout => false if request.xhr? }
      format.api
    end
  end #def

  def new
    @attachment_category = AttachmentCategory.new
  end #def

  def create
    @attachment_category = AttachmentCategory.new
    @attachment_category.safe_attributes= params[:attachment_category]
    if @attachment_category.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to attachment_categories_path
    else
      render :action => 'new'
    end
  end #def
  
  def edit
  end #def
  
  def update
    @attachment_category.safe_attributes= params[:attachment_category]
    if @attachment_category.save
      respond_to do |format|
        format.html {
          flash[:notice] = l(:notice_successful_update)
          redirect_to attachment_categories_path(:page => params[:page])
        }
        format.js { head 200 }
      end
    else
      respond_to do |format|
        format.html { render :action => 'edit' }
        format.js   { head 422 }
      end
    end
  end #def
  
  def destroy
    begin
      @attachment_category.destroy
    rescue Exception => e
      flash[:error] = e.message
    end
  rescue
    redirect_to attachment_categories_path
  end #def
  
  ########################################################################################
  #
  # attachment category specific functions
  #
  ########################################################################################
  def update_attachment_color
    if request.post? && AttachmentCategory.update_attachment_colors
      flash[:notice] = l(:notice_attachment_colors_updated)
    else
      flash[:error] =  l(:error_attachment_colors_not_updated)
    end
    redirect_to attachment_categories_path
  end #def
  
  ########################################################################################
  #
  # private
  #
  ########################################################################################
  private
  
  def find_attachment_category
    @attachment_category  = AttachmentCategory.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end #def
  
end
