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

function [repeat_dialog,selslave,selectid,MID,DID,SLA,SLP,SLST] = set_etl_slave_el4xxx(selslave,selectid,MID,DID,SLA,SLP,SLST)
  check_values = 0;
  fd = mopen([getenv('ETLPATH')+'/modules/etherlab_base/src/tcl/'+'etl_scicos_el2xxx.tcl'],'r');
  txt = mgetl(fd,-1);
  mclose(fd);

  data_types = [4001 4002 4004 4008 4102 4132 4012 4022 4032];
  data_state = [   0    0    0    0    0    0    0    0    0];        // None carries a statusbyte

  str_indx  = string(0:(size(data_types,'c')-1));                    // ['0' '1' '2' etc.
  str_types = 'EL' + string(data_types);                             // ['EL4001' 'EL4002' etc.
  str_state = string(data_state);                                    // ['0' '0' '0' etc.

  str_slavestring = '';
  str_slavestate = '';
  for dv = [ str_indx; str_types; str_state ]
    str_slavestring = str_slavestring + ' ' + dv(1) + ' ' + dv(2);    // '0 EL4001 1 EL4002 ...' etc.
    str_slavestate  = str_slavestate  + ' ' + dv(1) + ' ' + dv(3);    // '0 0 1 0 2 0 ...' etc.
  end

  initvalues = [
    'array set slavestring { ' + str_slavestring + ' }'; 
    'array set slavestate { ' + str_slavestate + '}';
    'set slaveselected '+selslave;
    'set selectid '+string(selectid);
    'set masterid '+string(MID);
    'set domainid '+string(DID);
    'set slavealias '+string(SLA);
    'set slaveposition '+string(SLP);
    'set showstate '+string(SLST)
    ];

//   initvalues = ['array set slavestring { 0 EL4001 1 EL4002 2 EL4004 3 EL4008 4 EL4102 5 EL4132 6 EL4012 7 EL4022 8 EL4032 }' 
// 		'array set slavestate { 0 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0}';   // None carries a statusbyte
// 		'set slaveselected '+selslave;
// 		'set selectid '+string(selectid);
// 		'set masterid '+string(MID);
// 		'set domainid '+string(DID);
// 		'set slavealias '+string(SLA);
// 		'set slaveposition '+string(SLP);
// 		'set showstate '+string(SLST)
// 		];

  listentry = '.eltop.list insert end $slavestring(' + str_indx' + ')';       // Need str_indx' to get a single column
  listentry = [listentry;
               '.eltop.list see $selectid';
               '.eltop.list selection set $selectid';
              ];

// listentry = [
//     '.eltop.list insert end $slavestring(0)';
// 		'.eltop.list insert end $slavestring(1)';
// 		'.eltop.list insert end $slavestring(2)';
// 		'.eltop.list insert end $slavestring(3)';
// 		'.eltop.list insert end $slavestring(4)';
// 		'.eltop.list insert end $slavestring(5)';
//     '.eltop.list insert end $slavestring(6)';
//     '.eltop.list insert end $slavestring(7)';
//     '.eltop.list insert end $slavestring(8)';
//     '.eltop.list insert end $slavestring(9)';
// 		'.eltop.list see $selectid';
// 		'.eltop.list selection set $selectid';
// 	];
    
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
  
  repeat_dialog = %f;
  selslave = TCL_GetVar('slaveselected')
  selectid = evstr(TCL_GetVar('selectid'))

  MID = check_pos_integer('Master ID','masterid');
  if MID<0  then
    repeat_dialog = %t;
  end
  DID = check_pos_integer('Domain ID','domainid');
  if DID<0  then
    repeat_dialog = %t;
  end
  SLA = check_pos_integer('Slave Alias','slavealias');
  if SLA<0  then
    repeat_dialog = %t;
  end
  SLP = check_pos_integer('Slave Position','slaveposition');
  if SLP<0  then
    repeat_dialog = %t;
  end
  SLST = check_pos_integer('Slave Stateoutput','showstate');
  if SLST<0  then
    repeat_dialog = %t;
  end

  TCL_EvalStr('destroy $eltop')
 endfunction
