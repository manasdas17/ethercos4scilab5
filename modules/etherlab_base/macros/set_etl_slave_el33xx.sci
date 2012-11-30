// Copyright (C) 2008  Andreas Stewering
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

function [repeat_dialog,selslave,selectid,MID,DID,SLA,SLP,SLST,ENFILT,TC1,TC2,TC3,TC4,CJ1,CJ2,CJ3,CJ4] = set_etl_slave_el33xx(selslave,selectid,MID,DID,SLA,SLP,SLST,ENFILT,TC1,TC2,TC3,TC4,CJ1,CJ2,CJ3,CJ4)
  check_values = 0;
  fd = mopen([getenv('ETLPATH')+'/modules/etherlab_base/src/tcl/'+'etl_scicos_el33xx.tcl'],'r');
  txt = mgetl(fd,-1);
  mclose(fd);

  initvalues = ['array set slavestring { 0 EL3311 1 EL3312 2 EL3314}'; 
		'array set slavestate { 0 1 1 1 2 1}'; 
		'set slaveselected '+selslave;
		'set selectid '+string(selectid);
		'set masterid '+string(MID);
		'set domainid '+string(DID);
		'set slavealias '+string(SLA);
		'set slaveposition '+string(SLP);
		'set showstate '+string(SLST);
		'set enFilter '+string(ENFILT);
		'set tctype0 '+string(TC1);
		'set tctype1 '+string(TC2);
		'set tctype3 '+string(TC3);
		'set tctype4 '+string(TC4);
		'set cjtype0 '+string(CJ1);
		'set cjtype1 '+string(CJ2);
		'set cjtype3 '+string(CJ3);
		'set cjtype4 '+string(CJ4);
		];
  listentry = ['.eltop.list insert end $slavestring(0)';
		'.eltop.list insert end $slavestring(1)';
		'.eltop.list insert end $slavestring(2)';
		'.eltop.list see $selectid';
		'.eltop.list selection set $selectid';
	];
  tclscript = [txt;
		initvalues;
		listentry
	];
  TCL_EvalStr(tclscript); //  call TCL interpretor to create widget	
  while %t do
    ok = TCL_GetVar('okstate');
    cancel = TCL_GetVar('cancelstate');
    if evstr(ok) == 1 then 
      break
    end
    if evstr(cancel) == 1 then
      break
    end
   sleep(100);
  end
  //mprintf("Dismissing dialog el33xx\n");
  repeat_dialog = %f;
  selslave = TCL_GetVar('slaveselected')
  selectid = evstr(TCL_GetVar('selectid'))
  MID = check_pos_integer('Master ID','masterid');
  if MID<0  then
    repeat_dialog = %t;
  end
  //disp(MID);
  DID = check_pos_integer('Domain ID','domainid');
  if DID<0  then
    repeat_dialog = %t;
  end
  SLA = check_pos_integer('Slave Alias','slavealias');
  if SLA<0  then
    repeat_dialog = %t;
  end
  SLP = check_pos_integer('Slave Position','slaveposition');
  if SLA<0  then
    repeat_dialog = %t;
  end
  SLST = check_pos_integer('Slave Stateoutput','showstate');
  if SLST<0  then
    repeat_dialog = %t;
  end
  ENFILT = check_pos_integer('Enable Filter','enFilter');
  if ENFILT<0  then
    repeat_dialog = %t;
  end
  TC1 = check_pos_integer('TC Typ 1','tctype0');
  if TC1<0  then
    repeat_dialog = %t;
  end
  TC2 = check_pos_integer('TC Typ 2','tctype1');
  if TC2<0  then
    repeat_dialog = %t;
  end
  TC3 = check_pos_integer('TC Typ 3','tctype3');
  if TC3<0  then
    repeat_dialog = %t;
  end
  TC4 = check_pos_integer('TC Typ 4','tctype4');
  if TC4<0  then
    repeat_dialog = %t;
  end
  CJ1 = check_pos_integer('CJ Typ 1','cjtype0');
  if CJ1<0  then
    repeat_dialog = %t;
  end
  CJ2 = check_pos_integer('CJ Typ 2','cjtype1');
  if CJ2<0  then
    repeat_dialog = %t;
  end
  CJ3 = check_pos_integer('CJ Typ 3','cjtype3');
  if CJ3<0  then
    repeat_dialog = %t;
  end
  CJ4 = check_pos_integer('CJ Typ 4','cjtype4');
  if CJ4<0  then
    repeat_dialog = %t;
  end
  TCL_EvalStr('destroy $eltop');
 endfunction
