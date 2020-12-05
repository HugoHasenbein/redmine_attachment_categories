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
  module Lib
    module RacFile
      class << self
      
        # ------------------------------------------------------------------------------ #
        #
        # current_filename( prefix(string), filename(string) )
        # returns filename with timestamp as name
        #
        def current_filename( prefix, filename )
           ext = File.extname( filename )
           bas = File.basename( filename, ext )
          "#{prefix}-#{bas}-#{Time.now.strftime("%Y-%m-%d_%H-%M-%S_%6N")}#{ext}"
        end #def
        
        # ------------------------------------------------------------------------------ #
        #
        def create_filename( filename, mime_type )
          extension = File.extname(filename.to_s)
          basename  = File.basename(filename.to_s, extension)
          extension = Rack::Mime::MIME_TYPES.invert[mime_type.to_s].presence.to_s if extension.blank?
          basename  = mime_type.to_s =~ /image/ ? "image" : "file" if basename.blank?
          "#{basename}#{extension}"
        end #def
        
        # ------------------------------------------------------------------------------ #
        # unique_filename( filenames(array), filename(string) )
        # returns filename, which is unique to filenames-array,
        # whereby extensions are kept
        #
        def unique_filename( filenames, filename, index=2 )
        
          if filenames.any? {|f| f == filename }
          
            #######################################################################
            #  get extension, i.e. '.txt'                                         #
            #######################################################################
            extname = File.extname(filename) 
            
            #######################################################################
            #  is extension an index?, i.e. '.2'                                  #
            #######################################################################
            if !!(extname =~ /\A\.\d+\z/) # is extension already a number?
              basname = File.basename(filename, extname) # get the basename 
              extname = "" # new index will replace index extension
              
            elsif extname.blank?
            #######################################################################
            #  no extension                                                       #
            #######################################################################
              basname = filename
              extname = "" #extname is already blank
            else
            #######################################################################
            #  extension exists and is NOT an index, i.e. '.2'                    #
            #######################################################################
              tmpname = File.basename(filename, extname) # leave a basename with a possible index counter, i.e. 'text.0'
              indname = File.extname(tmpname) # get secondary extension filename, i.e. '.0' from text.0.txt (if at all)
              if !!(indname =~ /\A\.\d+\z/) # is secondary extension  a number?
                basname = File.basename(tmpname, indname) # get the eventual basename, i.e 'text'
              else
                basname = tmpname
              end
            end #def
            
            newname = unique_filename( filenames, "#{basname}.#{index}#{extname}", index + 1 )
          else
            return filename
          end #if 
        end #def
        
        # ------------------------------------------------------------------------------ #
        # make_filenames_unique( filenames(array), filename(string) )
        # returns array of filenames, with each name unique
        # whereby extensions are kept
        #
        def make_filenames_unique( filenames )
           new_filenames = []
           # all but the first name must be unique_filename
           filenames.each do |filename|
             new_filenames << unique_filename( new_filenames, filename )
           end #each
           new_filenames
        end#def
                
        # ------------------------------------------------------------------------------ #
        # sanitize(filename)
        # returns sanitized filename(string)
        #        
        def sanitize( filename )
          _filename  = RpeText.to_utf8(filename.to_s.dup) # in case filename is nil
          _filename  = File.basename( _filename )
          _extension = File.extname(  _filename)
          _filestem  = File.basename( _filename, _extension)
          # limit maximum length of filename to 260 characters
          _extension = _extension[0..255]      # limit extension length
          _fslength  = 260 - _extension.length # limit basename accordingly
          _filename  = "#{_filestem[0.._fslength]}#{_extension}"
          # Bad as defined by wikipedia: https://en.wikipedia.org/wiki/Filename#Reserved_characters_and_words
          # Also have to escape the backslash, ampersand, ", ', and ;
          _bad_chars = /\/|\\|\?|%|\*|:|\|\"|\'|\<|\>| |;|&/
          _filename.gsub(_bad_chars, '_')
        end #def
        
      end #class
    end #module
  end #module
end #module
