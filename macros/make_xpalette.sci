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
    // See the Scilab Help for create_palette.
    // This version uses the new xcos function calls to generate an individual palette
    // aPath    : base path to the module's macros path
    //            The directory 'images' must be its sibling.
    // library  : The name of the palette to create_palette
    // subDir   : A directory under the aPath directory where the palette's block interface functions are.
    //            If absent, it is assumed that all sci files in the macros directory are block interface functions.

    thisfunc = "make_xpalette";
    mprintf("Entering %s on path %s\n", thisfunc, aPath);
    
    if argn(2) < 2 or argn(2) > 3 then
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
    my_tbx_build_blocks(module, lisf, subDir);
    
    // Create a ready to load palette
    pal = xcosPal(library);
    for fil = lisf'
        h5File    = pathconvert(module + "images/h5/")  + fil + ".h5";
        imgFile   = pathconvert(module + "images/gif/") + fil + ".gif";
        svgFile   = pathconvert(module + "images/svg/") + fil + ".svg";
        styleFile = pathconvert(module + "images/svg/") + fil + ".style";
        if isfile(styleFile) then
            aStyle = make_x_getStyle(styleFile);
        else
            aStyle = svgFile;
        end
        pal = xcosPalAddBlock(pal, h5File, imgFile, aStyle);
    end
    palPath = pathconvert(module + "images/h5/") + library + ".h5";
    [status, msg] = xcosPalExport(pal, palPath);
    if ~status then
       mprintf(msg);
       aMsg = msprintf("%s: Cannot export palette to %s\nMessage: %s", "make_palette", palPath, msg)
       error(aMsg);
    end
    mprintf(_("Wrote %s\n"),palPath);
  endfunction

function my_tbx_build_blocks(module, names, subDir)
    // Build a default block instance
    // The original did not build gif or svg files if they already existed. This is a bug.
    // This version does a make-like operation to determine if building these files is needed.
    //
    // In addition:
    // - a subDir can be given if there are other macros in the macros directory then interface files.
    //   The interface files proper must then be collected in the subDir directory, and a 
    //   non-empty string entered for subDir.
    // - if a .style file is present in the images/svg directory, it is assumed that its 
    //   content is used for xcosPallAdd's style and the svg file is not built.
    //
    // Calling Sequence
    //   my_tbx_build_blocks(module, names, subDir)
    //
    // Parameters
    // module: Toolbox base directory
    //         The directories 'macros' and 'images' must be here.
    // names:  List of block names (sci file name without extension)
    // subDir: (optional) Subdirectory of module/macros where the block interface files sit.

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

    if argn(2) < 3 then subDir = "", end;
    // Checking subDir argument
    if type(subDir) <> 10 then
        error(msprintf(gettext("%s: Wrong type for input argument #%d: A string expected.\n"), thisfunc, 3));
    end
    if size(subDir,"*") <> 1 then
        error(msprintf(gettext("%s: Wrong size for input argument #%d: A string expected.\n"), thisfunc, 3));
    end

    iface_path = pathconvert(module + "macros" + filesep() + subDir, %t, %t);
    if ~isdir(iface_path) then
        error(msprintf(gettext("%s: The directory ''%s'' doesn''t exist or is not read accessible.\n"), thisfunc, iface_path));
    end


    mprintf(gettext("Building blocks...\n"));

    // load Xcos libraries when not already loaded.
    if ~exists("scicos_diagram") then loadXcosLibs(); end
    
    sciFiles   = pathconvert(iface_path) + names + ".sci";
    h5Files    = pathconvert(module + "images/h5/") + names + ".h5";
    gif_tlbx   = pathconvert(module + "images/gif");
    gifFiles   = pathconvert(module + "images/gif/") + names + ".gif";
    svg_tlbx   = pathconvert(module + "images/svg");
    svgFiles   = pathconvert(module + "images/svg/") + names + ".svg";
    styleFiles = pathconvert(module + "images/svg/") + names + ".style";
    // Get the right number of copies of the name of this sci file
    thisFile    = sciFiles;                         // just to get the size right.
    thisFile(:) = get_function_path("make_xpalette");

    h5Outdated    = makex_fileIsNewer(sciFiles, h5Files)    | makex_fileIsNewer(thisFile, h5Files);
    gifOutdated   = makex_fileIsNewer(sciFiles, gifFiles)   | makex_fileIsNewer(thisFile, gifFiles);
    svgOutdated   = makex_fileIsNewer(sciFiles, svgFiles)   | makex_fileIsNewer(thisFile, svgFiles);
    needwork      = h5Outdated | gifOutdated | (svgOutdated & ~isfile(styleFiles));
    //mprintf("h5Outdated   : %s\n", strcat(string(h5Outdated   ), " "));
    //mprintf("gifOutdated  : %s\n", strcat(string(gifOutdated  ), " "));
    //mprintf("svgOutdated  : %s\n", strcat(string(svgOutdated  ), " "));
    //mprintf("needwork     : %s\n", strcat(string(needwork     ), " "));

    if or(needwork) then
        handle = gcf();
        for i=1:size(sciFiles, "*")   //find(needwork)
            mprintf("  Working on %s:\n", names(i));
            // load the interface function
            exec(sciFiles(i), -1);
            // Obtain the block from the sci file
            execstr(msprintf("scs_m = %s (''define'');", names(i)));
            
            // export the instance if the h5 file is outdated.
            if h5Outdated then
                if ~export_to_hdf5(h5Files(i), "scs_m") then
                    error(msprintf(gettext("%s: Unable to export %s to %s.\n"),"tbx_build_blocks",names(i), h5Files(i)));
                end
            end

            block = scs_m;
            // export a gif file if the gif file is outdated.
            if gifOutdated(i) then
                if ~generateMyBlockImage(block, gif_tlbx, names(i), handle, "gif", %t) then
                    error(msprintf(gettext("%s: Unable to export %s to %s.\n"),"tbx_build_blocks",names(i), gifFiles(i)));
                end
            end

            // export an svg file if the svg file is outdated and a style file does not exist
            if svgOutdated(i) then 
                if ~isfile(styleFiles(i)) then
                    if ~generateMyBlockImage(block, svg_tlbx, names(i), handle, "svg", %f) then
                        error(msprintf(gettext("%s: Unable to export %s to %s.\n"),"tbx_build_blocks",names(i), svgFiles(i)));
                    end
                end
            end
        end
        delete(handle);
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
    ierr = ~(exist1|exist2);         // ierr is only true if both do not exist  
    status(~exist2) = %t;            // if file2 does not exist, then file1 is newer 
    info1 = fileinfo(file1);
    info2 = fileinfo(file2);
    for i = find(exist1 & exist2)                   // if both files exist
        status(i) = (info1(i,6) > info2(i,6));      // compare dates
    end
endfunction