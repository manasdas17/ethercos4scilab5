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

//mprintf("Entering etherlab_base builder_c.sce\n");

names =   [ 'etl_scicos']; // ; Seperator defined in loader.sce
files     = ["etl_scicos.c"]; // ; Seperator

libs      = [];
flag      = "c";
makename  = "Makefile";
loadername= "loader.sce";
libname   = "etherlab_basis";
cflags    = " -O2 -g -fpic -fno-stack-protector  -I/opt/etherlab/include  -I"+get_absolute_file_path('builder_c.sce')+"../../../../includes ";
ldflags   = " -Wl,--rpath -Wl,"+get_absolute_file_path('builder_c.sce')+"../../../../src/c -L"+get_absolute_file_path('builder_c.sce')+"../../../../src/c -lpthread -lstdc++ -lrt -lm -letherlab";
fflags    = [];
cc        = "gcc";

function [libs] = findlibs(namelist)
    // for all library basenames, try to locate it and return the absolute path
    // names is a row vector of libraries that should be linked before loading the target library for this builder.
    // These are the places to look for libraries. 
    places = ["/usr/lib/scilab/";
               SCI + "../../lib/scilab/";
               //If you find another location, please add here, with a semicolon!
             ];
             
    libs = [];
    for name = namelist
        for place = places'
            afile = place + "lib" + name + getdynlibext();
            if isfile(afile) then
                afile = place + "lib" + name;
                libs = [libs, afile];
                break;  // next name
            end;
        end;
    end;
endfunction

use5 = %F;
try
   getversion('scilab');
   use5 = %T;
end
if use5 then
   // makename should be set to the default since Scilab 5.0. Docs are inconsistent in what the default is: [] or "".
   makename = "";
   // As Scilab 5 does lazy include on the xcos libraries, it is likely that certain libraries are not loaded yet as the
   // loading of etherlab takes place. This preloads some libraries
   libs    = findlibs(["sciscicos"]);
   // From 5.3.x onward, the files should not mention .o or .obj files, but source file names.
   // This is deduced from:
   //  1. The warning from ilib_for_link: "Please use A managed file extension for input argument #2 instead."
   //  2. The example from SCI/contrib/xcos_toolbox_skeleton/src/c/builder_c.sce: 
   //           tbx_build_src(["block_sum", "business_sum"],["block_sum.c", "business_sum.c"], 
   files = strsubst(files, ".o", ".c");
   // For consistency. In some modules compilation fails in Scilab 5.
   // This define makes it possible to ammend broken files.
   cflags = cflags + "-Dversion5";
end;   // try
clear use5;

//ilib_verbose(2);
if ilib_verbose() == 2 then
   mprintf("Running tbx_build_src from : %s\n", TMPDIR);
end;
tbx_build_src(names, files, flag, get_absolute_file_path('builder_c.sce'),libs,ldflags,cflags,fflags,cc,libname,loadername,makename);
mprintf("Exit tbx_build_src\n");
// ====================================================================
clear tbx_build_src;

clear names findlibs;
clear files;
clear libs;
// ====================================================================
