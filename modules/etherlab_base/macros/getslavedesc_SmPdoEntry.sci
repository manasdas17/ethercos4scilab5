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

function [index,subindex,bitlen,datatype] = getslavedesc_SmPdoEntry(pdo_desc, pdo_key, entryindex)
    //mprintf("getslavedesc_SmPdoEntry");
    key = pdo_key + "Entry";
    if (entryindex ~= 1) | (isempty(find( pdo_desc == key + ".Index"))) then
        key = key + "(" + string(entryindex) + ")";
    end;
    //mprintf("<key = %s>", key);
    index        = getnum(pdo_desc(find(pdo_desc == key + ".Index"   ), 2));
    bitlen       = getnum(pdo_desc(find(pdo_desc == key + ".BitLen"  ), 2));
    if index == 0 then
        // GAP-Entry found
        subindex = 0;
        datatype = 0;
    else
        subindex = getnum(pdo_desc(find(pdo_desc == key + ".SubIndex"), 2));
        datatype =        pdo_desc(find(pdo_desc == key + ".DataType"), 2);
    end;
    //mprintf("(%s, %d) --> %#.4x, %#x, %d, %s\n", pdo_key, entryindex, index, subindex, bitlen, string(datatype));
endfunction
