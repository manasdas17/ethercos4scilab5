mode(-1);
// Copyright (C) 2008-2009  Andreas Stewering, IgH Essen
//
// This file is part of EtherCos.
//
// EtherCos is free software; you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// EtherCos is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with EtherCos; if not, write to the Free Software
// Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA


//=====================================================================
current_dir_ethercos = pwd();
toolbox_dir = get_absolute_file_path('builder.sce');

//=====================================================================
if(setenv('ETLPATH',toolbox_dir)==%f) then
  disp('Setting Enviroment Variable failed');
  return;
end

//=====================================================================
//Check for Host System
if (getos() == "Windows") then
    disp('Windows is not supported');
    return; 
end;

//=====================================================================
//Set Release dependent Header Files
try
  [version,modules]=getversion();
  mprintf("\n");
  [from, to] = regexp(version, '/^[Ss]cilab-/');
  if from then
      version = part(version, to+1:length(version));    // strip leading '[sS]ilab-'
  end;
  if find(version == ['4.3']) then
    includefn = "scicos_block4_3.h";
  elseif find(version == ['4.1.2', 'Gtk-2007-12-07']) then
    includefn = "scicos_block4_12.h";
  elseif find(version == ['5.3.3' '5.4.0']) then
    includefn = "scicos_block4_" + version + ".h";
  else
    disp("Scilab Version ''" + version + "'' not supported");
    return;	
  end;
  // Copy the rigth include file to a local place
  shellstr = 'cp -f ' + toolbox_dir + 'includes/' + includefn + ' ' + toolbox_dir + 'includes/scicos_block4.h';
  rcode = unix(shellstr);
  if rcode != 0 then
    disp('Header Initialisation not successfull!')
    return;
  end
catch 
  disp('Failure Handling')
end 

// ====================================================================
try
  getversion('scilab');   // Fails with version < 5
  if ~with_module('development_tools') then
    error(msprintf(gettext('%s module not installed."),'development_tools'));
  end
end
try
  chdir('macros');
  exec('buildmacros.sce');
  exec('loadmacros.sce');
  chdir(toolbox_dir);
catch
  error('macros dir not available!');
end
// ====================================================================
TOOLBOX_NAME = 'etherlab_toolbox';
TOOLBOX_TITLE = 'EtherCos Toolbox for scilab';
status = '';
// ====================================================================
  listSuccessful  = list(); // list of successful builds
  listFailed      = list(); // list of failed builds
  buildDetails  = '';     // details about every failed test
// ====================================================================
chdir(toolbox_dir);
 try
    tbx_builder_src(toolbox_dir);
    tbx_build_loader(TOOLBOX_NAME, toolbox_dir);
    listSuccessful($+1)='ethercos main';
    status=sprintf(' |   %s                         ',TOOLBOX_NAME);
 catch
    [str,n,line,func]=lasterror();
    status=sprintf(' !                         %s ',TOOLBOX_NAME);
    printf(' %s  could not be built!',TOOLBOX_NAME);
    mprintf("\nError message: %s\nOn line %d in function %s\n", str, n, func);
    listFailed($+1)=TOOLBOX_NAME;
 end
// ====================================================================
 buildDetails=[buildDetails;status'];

chdir(toolbox_dir);
if ( isdir('modules') ) then
  disp('Build modules');
  chdir('modules');
  module=dir();
  start=1;
  while(start<length(module.isdir)) do
 
  for i=start:length(module.isdir)
	  start=i+1;
    if (module.isdir(i)) then
      if (fileinfo(module.name(i)+'/builder.sce')~=[]) then
//	    try
          disp('Building module: '+module.name(i));
          exec(module.name(i)+'/builder.sce',-1);
          chdir(toolbox_dir+'modules');
//	    catch
//		    chdir(toolbox_dir+'modules');
//   			disp(module.name(start-1)+' could not build!');
//   			listFailed($+1)=module.name(start-1);
//	    end
      end
    end
  end   //for
end  //isdir
clear module dir i;
else
end

//-- Display overall report
nbPassed  = length(listSuccessful)
nbFailed  = length(listFailed)
nbTests   =nbPassed+nbFailed;
printf('\n')
printf('  ---------------------------------------------------------------------\n')
printf('   Summary\n\n')
printf('   builds                    %4d - 100.0 %% \n', nbPassed+nbFailed)
printf('   passed                    %4d - %5.1f %% \n', nbPassed,  nbPassed/nbTests*100)
printf('   failed                    %4d - %5.1f %% \n', nbFailed,  nbFailed/nbTests*100)
printf('  ---------------------------------------------------------------------\n')
printf('   Details\n\n')
printf('   succesfully built modules \t failed modules\n\n')
printf('%s\n', buildDetails)
printf('\n')
printf('  ----------------------------------------------------------------------\n')

chdir(current_dir_ethercos);

// ====================================================================
clear toolbox_dir i module dir;
clear status;
clear tbx_builder_macros tbx_builder_src tbx_builder_gateway tbx_builder_help tbx_build_loader;
clear toolbox_dir;
clear TOOLBOX_NAME TOOLBOX_TITLE;
clear current_dir_ethercos, listFailed, listSuccessful,nbPassed,nbFailed,nbTests,buildDetails;
// ====================================================================

//quit


