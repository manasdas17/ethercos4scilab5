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

function [pdo_desc, pdo_key, smno,smindex,smexclude,smmandatory] = getslavedesc_SmPdoInfo(dev_desc, rootkey, direction, pdoindex)
    //mprintf("getslavedesc_SmPdoInfo(%s, %d, %d) --> ", rootkey, direction, pdoindex);
    if direction == 1 //TxPdo, Slave send to Master
      //disp('Get TxPdo Info')
      aPdo = "TxPdo";
    elseif direction == 2 //RxPdo Master send zo Slave
      //disp('Get RxPdo Info')
      aPdo = "RxPdo";
    else
      aPdo = "NotaPdo";
    end;
    key = rootkey + aPdo;
    if (pdoindex ~= 1) | (isempty(find(dev_desc == key + ".Index"))) then
        key = key + "(" + string(pdoindex) + ")";
    end;
    //mprintf("getslavedesc_SmPdoInfo: key: %s\n", key); 
    smno        = getnum(dev_desc(find(dev_desc == key + ".Sm"), 2));        //pdo.Sm; : May be empty
    smindex     = getnum(dev_desc(find(dev_desc == key + ".Index"), 2));     // pdo.Index;
    smexclude   = getnum(dev_desc(find(dev_desc == key + ".Exclude"), 2)) ;  // pdo.Exclude;
    smmandatory = getnum(dev_desc(find(dev_desc == key + ".Mandatory"), 2)); // pdo.Mandatory;
    // This trailer is only for errorfree printing of the debug lines
    //if isempty(smno)        then pno = -1; else pno = smno;        end;
    //if isempty(smindex)     then pi  = 0;  else pi  = smindex;     end;
    //if isempty(smexclude)   then ec  = 0;  else ec  = smexclude;   end; 
    //if isempty(smmandatory) then md  = -1; else md  = smmandatory; end;
    //mprintf("%d, %#.4x, %#.4x, %d\n", pno, pi, ec, md);
    key = key + ".";
//    grpkey = getslavedesc_makegrepkey(key);
//    mprintf("%s\n", grpkey);
//    grpi = grep(dev_desc(:,1)', "/" + grpkey + "/", "r");
//    mprintf("%d\n", size(grpi, "*"));
//    descr = dev_desc(grpi,:);
    pdo_key = key;
//    pdo_desc = descr;
    pdo_desc = dev_desc(grep(dev_desc(:,1)', "/" + getslavedesc_makegrepkey(key) + "/", "r"),:);
endfunction
