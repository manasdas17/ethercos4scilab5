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

function pdoList = getslavex_pdoList(dev_desc, direction)
  if direction == 1 then //TxPdo, Input
    aPdo = 'TxPdo';
  elseif direction == 2 then //RxPdo, Output
    aPdo = 'RxPdo';
  else
    numpdo = -1; // Unexpected input
    //mprintf("getslavedesc_numPdo(%s, %d) --> error: direction not 1 or 2.\n", rootkey, direction);
    return;
  end;
  pdoList = xmlXPath(dev_desc, aPdo);
  //tmpnumpdo = size(slave_desc.Descriptions.Devices.Device(index).TxPdo);
  //tmpnumpdo = size(slave_desc.Descriptions.Devices.Device(index).RxPdo);
  //mprintf("getslavedesc_numPdo(%s, %d) --> ", rootkey, direction);
  //key = getslavedesc_makegrepkey(rootkey) + aPdo + "(\(\d+\))?\.Index";
  //tmpnumpdo = size(grep(dev_desc(:,1)', "/" + key + "/", "r"));
  //if and(tmpnumpdo) then
  //  numpdo = max(tmpnumpdo);
  //else
  //  numpdo = -1; 
  //end
  //mprintf("%d\n", numpdo);
endfunction
