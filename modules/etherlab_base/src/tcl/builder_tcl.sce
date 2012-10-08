// Copyright (C) 2008  Andreas Stewering
// Copyright (C) 2008  Holger Nahrstaedt (HART-Project)
// Copyright (C) 2008  L.P. Remmerswaal (Revolution Controls)
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

srcpath = get_absolute_file_path('builder_tcl.sce');
theFiles = listfiles(srcpath+"*.src.tcl");
if ~isempty(theFiles) then
  mprintf("Converting src.tcl scripts...\n");
  perlscript = srcpath + "../perl/convert_freeformat_tcl.pl";
  for aFile = theFiles'
    mprintf("    %s.tcl\n",basename(aFile));
    cmnd = perlscript+" "+ aFile;
    try
      unix_w(cmnd);
    catch
      disp("Failed to execute "+cmnd);
    end
  end
end
// ====================================================================

clear scrpath;
clear perlscript;
clear theFiles;
clear aFile;
clear cmnd;

// ====================================================================
