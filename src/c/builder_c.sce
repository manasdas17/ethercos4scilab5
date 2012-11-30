// Copyright (C) 2008-2009  Andreas Stewering, IgH Essen
//
// This file is part of EtherCOS.
//
// EtherCOS is free software; you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// EtherCOS is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with EtherCOS; if not, write to the Free Software
// Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA// 
// ====================================================================
names =''; //defined in loader.sce

files     = ["getstr.o","ecrt_scicos_support.o","ecrt_support_simply.o","list.o"];
libs      = [];
flag      = "c";
loadername= "loader.sce";
libname   = "etherlab";
cflags    = " -O2 -g -fpic -fno-stack-protector  -I/opt/etherlab/include   -I"+get_absolute_file_path('builder_c.sce')+"../../includes ";
ldflags   = " -Wl,--rpath -Wl,/opt/etherlab/lib -L/opt/etherlab/lib -lpthread -lstdc++ -lm -lethercat";
fflags    = [];
cc        = "gcc";
makename  = "Makefile";

try
   getversion('scilab');
   // makename should be set to the default since Scilab 5.0. Docs are inconsistent in what the default is: [] or "".
   makename = "";
   // From 5.3.x onward, the files should not mention .o or .obj files, but source file names.
   // This is deduced from:
   //  1. The warning from ilib_for_link: "Please use A managed file extension for input argument #2 instead."
   //  2. The example from SCI/contrib/xcos_toolbox_skeleton/src/c/builder_c.sce: 
   //           tbx_build_src(["block_sum", "business_sum"],["block_sum.c", "business_sum.c"], 
   files = strsubst(files, ".o", ".c");
   // For consistency. In some modules compilation fails in Scilab 5.
   // This define makes it possible to ammend broken files.
   cflags = cflags + "-Dversion5";
end

//vlvl = ilib_verbose();
//ncl = lines();
//lines(0);
//ilib_verbose(2);
//mprintf("Building sources for library %s\n", libname);
tbx_build_src(names, files, flag, get_absolute_file_path("builder_c.sce"),libs,ldflags,cflags,fflags,cc,libname,loadername,makename);
//ilib_verbose(vlvl);
//lines(ncl(2), ncl(1));
// ====================================================================
clear tbx_build_src;

clear names;
clear files;
clear libs;
// ====================================================================
