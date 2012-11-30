// Copyright (C) 2008  Andreas Stewering
// Copyright (C) 2008  Holger Nahrstaedt (HART-Project)
//
// This file is part of Etherlab.
//
// Etherlab is free software; you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// Etherlab is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with Etherlab; if not, write to the Free Software
// Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA//
// ====================================================================
macros_dir_etherlab_tlbx = get_absolute_file_path('buildmacros.sce');
names5 = ["make_xpalette.sci" "generateMyBlockImage.sci"];

use5 = %F;
try
    getversion('scilab');
    use5 = %T;
end
if use5 then
    genlib('etherlab_lib',macros_dir_etherlab_tlbx,%f,%t, names5); // Just need a few
else
    names4 = get_sci4_names(macros_dir_etherlab_tlbx, names5);
    genlib('etherlab_lib',macros_dir_etherlab_tlbx,%f,%t, names4);
    clear names4
end

function [nameslist] = get_sci4_names(aPath, skiplist)
    files = listfiles(macros_dir_etherlab_tlbx+"*.sci",%f);         // Find all *.sci names and then some (listfiles bug)
    files = files(grep(files, "/\.sci$/", "r"));                    // Only the *.sci names
    files = basename(files,%f);                                     // Without the sci
    skiplist = basename(skiplist);
    nameslist = setdiff(files, skiplist);                           // Remove the entries in the skiplist
endfunction

// ====================================================================
// clear variables on stack
clear getsave;
clear genlib;
clear macros_dir_tlbx_sklt
clear use5 names5 get_sci4_names
// ====================================================================
