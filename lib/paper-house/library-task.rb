#
# Copyright (C) 2013 NEC Corporation
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License, version 3, as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#


require "paper-house/build-task"


module PaperHouse
  #
  # Common base class for static, shared, and ruby library tasks.
  #
  class LibraryTask < BuildTask
    def initialize name, &block
      @library_dependencies = []
      super name, &block
    end


    #
    # Name of library.
    #
    def library_name
      @library_name ||= @name
    end


    #
    # Name of library.
    #
    def library_name= new_name
       @library_name = /\Alib/=~ new_name ? new_name : "lib" + new_name
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
