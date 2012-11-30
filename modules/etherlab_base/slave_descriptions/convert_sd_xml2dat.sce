// Copyright (C) 2012  Len Remmerswaal
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

// This converts the Beckhoff xml files into Scilab Binary files.
// At any time you can drop in a modern file or set of files, and remake the entire etherCOS.
// Only files named 'Beckhoff E[LK]*.xml' are considered (case insensitive). 
// The other 'Beckhoff *' files are not interesting for EtherCOS.
//
// You need perl library XML::LibXML for this to work.
// On Debian: sudo apt-get install libxml-libxml-perl

//mode(-1)
//Convert Beckhoff XML files into Scilab Binary Format
mprintf(gettext("Convert Beckhoff xml slave descriptions...\n"));
slavedesc_path = get_absolute_file_path('convert_sd_xml2dat.sce');
//slavedesc_path = [scilab_basename+'/contrib/etherlab/modules/etherlab_base/slave_descriptions/'];

// record the data of the perl script.
perlfile = dir("../src/perl/convert_slavedesc.pl");
perldate = perlfile.date;

filestoconvert = dir( slavedesc_path+"/*.xml");                       // The paths of the files to convert: a broad selection
filenames = convstr(basename(filestoconvert.name), "l");              // filenames in lowercase
filenames = strsubst(filenames, "beckhoff e", "EtherCATInfo_e");      // Only 'Beckhoff E' files
filenames = strsubst(filenames, "temposonics_mtsr", "EtherCATInfo_mtsr"); // and the temposonic mtsr file
filenames = strsubst(filenames, ' ', '');                             // Remove the spaces...
filenames = filenames + ".sce";                                       // This comes out of the perl xml converter
filesconverted = strsubst(filenames, ".sce", ".dat");                 // target file name
filesconverted = slavedesc_path + filesep() + filesconverted;         // target file paths
isconverted = isfile(filesconverted);                                 // result exists

ind = grep(filenames, "/EtherCATInfo_(e[kl]|mtsr)/", 'r');            // Only consider EL, EK and mtsr files
strcat(filenames(ind), "", "c")
count = max(size(ind));
for i = ind
  filename = basename(filestoconvert.name(i));
  count = count -1;
  mprintf('Converting %s (%d to go) ...', filename, count);
  if isconverted(i) then
    //check if the result is newer then the xml
    target = dir(filesconverted(i));
    if (target.date > filestoconvert.date(i)) & (target.date > perldate) then
      // target is newer than both the source file and the conversion utility.
      mprintf(gettext('skipped.\n'));
      continue;  
    end
  end
  mprintf('\n');
  tmppath = strsubst(filestoconvert.name(i), ' ', '\ ');
  [resp, rcode] = unix_g('../src/perl/convert_slavedesc.pl -f ' + tmppath);
  if rcode ~= 0 then
    mprintf(gettext('\nConversion failed.\n'));
    return 2;
  end
  exec(filenames(i));                                               // The resulting .sce file contains all to create a .dat file
end;
mprintf(gettext('All xml slave descriptions converted.\n'));

clear slavedesc_path;
clear filestoconvert;
clear filenames;
clear filesconverted;
clear isconverted;
clear ind;
clear i;
clear filename;
clear target;
clear rcode;
clear tmppath;
