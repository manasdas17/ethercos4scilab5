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

//Check for existing Description
function device = getslavex_checkslave(slave_desc,slavetype,rev)
    //mprintf("getslavedesc_checkslave(%s, %#.8x) --> ", slavetype, rev);
    device = [];
    //mprintf("%s ", slave_desc.root.name);
    ltypes = xmlXPath(slave_desc.root, "Descriptions/Devices/Device/Type[contains(.,''" + slavetype + "'')]");
    //mprintf("num: %d -- ", ltypes.size);
    for i = 1:ltypes.size
        tp = ltypes(i);
        //mprintf("i: %d, ", i);
        if getnum(tp.attributes.RevisionNo) == rev then
            device = tp.parent;
            //mprintf("OK ");
            break;
        end
    end
    //if type(device) <> type([]) then
    //    mprintf("\n%s\n", strcat(xmlAsText(xmlXPath(device, "Name")), " -- "));
    //else
    //    mprintf("%s\n", "Empty");
    //end
endfunction
