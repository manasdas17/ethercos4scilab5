//
//  Copyright (C) 2012 Len Remmerswaal
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
//
// See the file ./license.txt
//

function make_xpalette(aPath, library, subDir)
    // This function replaces the use of create_palette in Scilab version >= 5.3
    // create_palette was in the 'scicos/scicos_utils' library
    // If the svg directory contains a style file, the style file is used instead of the svg file to create the palette
    // To stop generateBlockImage from creating an unneeded svg file, a dummy svg file is put in place next to the style file
    // See the Scilab Help for create_palette.
    // This version uses the new xcos function calls to generate an individual palette
    // aPath    : base path to the module's macros path
    //            The directory 'images' must be its sibling.
    // library  : The name of the palette to create_palette
    // subDir   : A directory under the aPath directory where the palette's block interface functions are.
    //            If absent, it is assumed that all sci files in the macros directory are block interface functions.

    thisfunc = "make_xpalette";
    mprintf("Entering %s on path %s\n", thisfunc, aPath);
    
    if argn(2) < 2 | argn(2) > 3 then
        error(msprintf(gettext("%s: Wrong number of input arguments: %d to %d expected.\n"), thisfunc, 2, 3));
    end
    if argn(2) == 2 then subDir = "", end;

    if type(aPath) <> 10 then
        error(msprintf(gettext("%s: Wrong type for input argument #%d: A string expected.\n"), thisfunc, 1));
    end
    if type(library) <> 10 then
        error(msprintf(gettext("%s: Wrong type for input argument #%d: A string expected.\n"), thisfunc, 2));
    end
    if type(subDir) <> 10 then
        error(msprintf(gettext("%s: Wrong type for input argument #%d: A string expected.\n"), thisfunc, 3));
    end
    if size(aPath,"*") <> 1 then
        error(msprintf(gettext("%s: Wrong size for input argument #%d: A string expected.\n"), thisfunc, 1));
    end
    if size(library,"*") <> 1 then
        error(msprintf(gettext("%s: Wrong size for input argument #%d: A string expected.\n"), thisfunc, 2));
    end
    if size(subDir,"*") <> 1 then
        error(msprintf(gettext("%s: Wrong size for input argument #%d: A string expected.\n"), thisfunc, 3));
    end

    module = pathconvert(aPath + "../",%t,%t);
    iface_path = pathconvert(aPath + subDir, %t, %t);
    if ~isdir(iface_path) then
        error(msprintf(gettext("%s: The directory ''%s'' doesn''t exist or is not read accessible.\n"), thisfunc, iface_path));
    end

    // Create a list of all block interface files in this module
    to_del = [];
    lisf = gsort(listfiles(iface_path + "/*.sci"), 'g', 'i');
    for i=1:size(lisf,'*')
      fil=lisf(i);
      ierror=execstr("exec(fil);",'errcatch');
      if ierror <>0 then
        to_del=[to_del i];
        mprintf("Will not be adding %s\n", fil);
      end
    end
    lisf(to_del)=[];
    if isempty(lisf) then
        msg = msprintf("No valid blocks for palette %s in directory %s\n", library, iface_path);
        error(msg);
    end

    //Create the xcos blocks
    lisf = basename(lisf);

    // Collect the interesting file names
    sciFiles   = pathconvert(iface_path) + lisf + ".sci";
    h5Files    = pathconvert(module + "images/h5/")  + lisf + ".sod";
    imgFiles   = pathconvert(module + "images/gif/") + lisf + ".gif";
    svgFiles   = pathconvert(module + "images/svg/") + lisf + ".svg";
    styleFiles = pathconvert(module + "images/svg/") + lisf + ".style";

    // Get the right number of copies of the name of this sci file
    thisFile    = lisf;                   // just to get the size right.
    thisFile(:) = get_function_path("make_xpalette");

    // See which files need remaking and which might just stay.
    h5Outdated    =  makex_fileIsNewer(sciFiles, h5Files)  | makex_fileIsNewer(thisFile, h5Files );
    gifOutdated   =  makex_fileIsNewer(sciFiles, imgFiles) | makex_fileIsNewer(thisFile, imgFiles);
    // svg cannot be outdated if a style file is present
    svgOutdated   = (makex_fileIsNewer(sciFiles, svgFiles) | makex_fileIsNewer(thisFile, svgFiles)) & ~isfile(styleFiles);
    needwork      = h5Outdated | gifOutdated | svgOutdated;
    //mprintf("h5Outdated   : %s\n", strcat(string(h5Outdated   ), " "));
    //mprintf("gifOutdated  : %s\n", strcat(string(gifOutdated  ), " "));
    //mprintf("svgOutdated  : %s\n", strcat(string(svgOutdated  ), " "));
    //mprintf("needwork     : %s\n", strcat(string(needwork     ), " "));

    // To make tbx_build_blocks regenerate outdated stuff, delete it.
    deleteables = [h5Files(h5Outdated);imgFiles(gifOutdated)];
    if deleteables <> [] then
        deleteables = deleteables(isfile(deleteables));
        //mprintf("Deleteables: %s\n", strcat(string(deleteables), " "));
        for f = deleteables'
            mdelete(f);
        end
    end
    clear deleteables;

    //Create a dummy svg file if a style file is present
    dummysvg = svgFiles(isfile(styleFiles) & ~isfile(svgFiles))
    for f = dummysvg'
        fd = mopen(f, "w");
        mclose(fd);
    end

    // If an item does not need work, then don't present it to tbx_build_blocks
    buildlist = lisf(needwork);
    //mprintf("Build list: %s\n", strcat(string(buildlist), " "));
    // ***** Build the blocks *****
    if ~isempty(buildlist) then
        %zoom = 1;                      // Or generateBlockImage may crash
        my_tbx_build_blocks(module, buildlist, iface_path);
    end
    clear buildlist;
    
    // Create a ready to load palette
    pal = xcosPal(library);
    for i = 1:size(lisf,'*')
        if isfile(styleFiles(i)) then
            aStyle = make_x_getStyle(styleFiles(i));
        else
            aStyle = svgFile(i);
        end
        pal = xcosPalAddBlock(pal, h5Files(i), imgFiles(i), aStyle);
    end
    palPath = pathconvert(module + "images/h5/") + library + ".sod";
    [status, msg] = xcosPalExport(pal, palPath);
    if ~status then
       mprintf(msg);
       aMsg = msprintf("%s: Cannot export palette to %s\nMessage: %s", "make_palette", palPath, msg)
       error(aMsg);
    end
    mprintf(_("Wrote %s\n"),palPath);
endfunction

function my_tbx_build_blocks(module, names, ifacePath)
    // Build a default block instance
    //
    // This version corrects a bug, and is OK for 533 and 540
    // Define useSod with any value to cause 540 behaviour
    //
    // Calling Sequence
    //   my_tbx_build_blocks(module, names, subDir)
    //
    // Parameters
    // module   : Toolbox base directory
    //            The directories 'macros' and 'images' must be here.
    // names    : List of block names (sci file name without extension)
    // ifacePath: (optional) Directory where the block interface files sit.

    thisfunc = "my_tbx_build_blocks";
    
    if (argn(2) > 3) | (argn(2) < 2) then
        error(msprintf(gettext("%s: Wrong number of input arguments: %d to %d expected.\n"), thisfunc, 2, 3));
    end

    // checking module argument
    if type(module) <> 10 then
        error(msprintf(gettext("%s: Wrong type for input argument #%d: A string expected.\n"), thisfunc, 1));
    end
    if size(module,"*") <> 1 then
        error(msprintf(gettext("%s: Wrong size for input argument #%d: A string expected.\n"), thisfunc, 1));
    end
    if ~isdir(module) then
        error(msprintf(gettext("%s: The directory ''%s'' doesn''t exist or is not read accessible.\n"), thisfunc, module));
    end

    // checking names argument
    if type(names) <> 10 then
        error(msprintf(gettext("%s: Wrong type for input argument #%d: A string expected.\n"), thisfunc,2));
    end

    // checking optional IfacePath argument
    if argn(2) < 3 then 
        ifacePath = pathconvert(module + "macros/", %t, %t);
    end;
    if type(ifacePath) <> 10 then
        error(msprintf(gettext("%s: Wrong type for input argument #%d: A string expected.\n"), thisfunc, 3));
    end
    if size(ifacePath,"*") <> 1 then
        error(msprintf(gettext("%s: Wrong size for input argument #%d: A string expected.\n"), thisfunc, 3));
    end
    if ~isdir(ifacePath) then
        error(msprintf(gettext("%s: The directory ''%s'' doesn''t exist or is not read accessible.\n"), thisfunc, iface_path));
    end


    mprintf(gettext("Building blocks...\n"));

    // load Xcos libraries when not already loaded.
    if ~exists("scicos_diagram") then loadXcosLibs(); end
    
    names = names(:);
    h5_tlbx    = pathconvert(module + "/images/h5");
    gif_tlbx   = pathconvert(module + "/images/gif");
    svg_tlbx   = pathconvert(module + "/images/svg");
    images     = pathconvert(module + "images");
    // Create the needed directories if not there yet.
    tlbxs      = [images h5_tlbx gif_tlbx svg_tlbx];
    for d = tlbxs(~isdir(tlbxs))
        mkdir(d);
    end
    clear tlbxs images;

    sciFiles   = pathconvert(ifacePath) + names + ".sci";
    h5Files    = h5_tlbx  + names + ".sod";
    gifFiles   = svg_tlbx + names + ".gif";
    svgFiles   = svg_tlbx + names + ".svg";

    for i=1:size(sciFiles, "*")
        mprintf("  Working on %s:\n", names(i));
        // load the interface function
        exec(sciFiles(i), -1);

        // export the instance if the h5 file is outdated.
        execstr(msprintf("scs_m = %s (''define'');", names(i)));
        if ~export_to_hdf5(h5Files(i), "scs_m") then
           error(msprintf(gettext("%s: Unable to export %s to %s.\n"),"tbx_build_blocks",names(i), h5Files(i)));
        end
        block = scs_m;

        // export an image file if it doesn't exist
        files = gif_tlbx + "/" + names(i) + [".png" ".jpg" ".gif"];
        if ~or(isfile(files)) then
            //mprintf("%s: Calling %s\n", thisfunc, "generateBlockImage(gif)");
            if ~generateBlockImage(block, gif_tlbx, names(i), "gif", %t) then
                [str,n,line,func]=lasterror();
                mprintf("%s: Error %d: %s\n   on line %d of function %s\n",..
                        thisfunc, n, str, line, func);
                error(msprintf(gettext("%s: Unable to export %s to %s.\n"),"tbx_build_blocks", names(i), files(3)));
            end
            //mprintf("%s: Past calling %s\n", thisfunc, "generateBlockImage(gif)()");
        end

        // export a schema file if it does not exist
        files = svg_tlbx + "/" + names(i) + [".svg" ".png" ".jpg" ".gif"];
        if ~or(isfile(files)) then
            //mprintf("%s: Calling %s\n", thisfunc, "generateBlockImage(svg)");
            if ~generateBlockImage(block, svg_tlbx, names(i), handle, "svg", %f) then
                mprintf("%s: Error %d: %s\n   on line %d of function %s\n",..
                        thisfunc, n, str, line, func);
                error(msprintf(gettext("%s: Unable to export %s to %s.\n"),"tbx_build_blocks", names(i), files(1)));
            end
            //mprintf("%s: Past calling %s\n", thisfunc, "generateBlockImage(svg)()");
        end
    end
endfunction

function aStyle = make_x_getStyle(fn)
    // Convert text file fn (filename) into a style defining string
    // each line of fn is as follows:
    //  - leading or trailing whitespace is ignored
    //  - if it starts with // the entire line is ignored
    //  - comments after other content on a line is not allowed
    //  - all other lines are like fieldname=value;
    //  - mind the closing semicolon!
    //  - each fieldname must occur once
    //  - Spaces around the = are important
    // All fieldname lines are concatenated to form a style for xcosPalAddBlock

    aStyle = "";
    if ~isfile(fn) then
        error(msprintf(gettext("%s: Unable to find file %s\n"), "make_x_getStyle", fn));
    end
    lins = stripblanks(mgetl(fn));
    for l = lins'
        if (length(l) > 0) & (strncpy(l, 2) <> "//") then   
            aStyle = aStyle + l;
        end
    end
    //mprintf("Style: %s\n", aStyle);
endfunction

function [status, ierr] = makex_fileIsNewer(file1, file2)
    // Return a boolean matrix with status(i)=%t where file1(i) is newer than file2(i)
    // file1 and file2 are string column matrices of the same size (may be size 1)
    // A non-existent file is considered the oldest.
    // If both files do not exist, the status is %f and ierr is %t, otherwise ierr is %f.
    thisfunc = "makex_fileIsNewer";
    if type(file1) <> 10 then
        error(msprintf("%s: Parameter %d must be a string matrix\n", thisfunc, 1));
    end
    if type(file2) <> 10 then
        error(msprintf("%s: Parameter %d must be a string matrix\n", thisfunc, 2));
    end
    if size(file1) <> size(file2) then
        error(msprintf("%s: parameters are not of the same size.\n", thisfunc));
    end
    if size(file1, "c") > 1 then
        error(msprintf("%s: file lists must be column vectors.\n", thisfunc));
    end
    exist1 = isfile(file1);     
    exist2 = isfile(file2);
    status(exist1|~exist1) = %f;     // status has size of exist1 (same as file1) and is all False
    for i = 1:size(status,"*")
        status(i) = (newest(file2(i), file1(i)) == 2);    // if both do not exist, status will be %f
    end
    ierr = ~(exist1|exist2);         // ierr is only true if both do not exist  
endfunction