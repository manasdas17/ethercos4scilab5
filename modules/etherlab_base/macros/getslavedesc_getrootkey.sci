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

function rootkey = getslavedesc_getrootkey(dev_desc)
    // All items in column 1 of dev_desc start with 
    //     "Descriptions.Devices.Device." or 
    //     "Descriptions.Devices.Device(##)." where ## is a single number for all entries
    // and have a trailer after that
    aKey = dev_desc(1,1);
    pos1 = length("Descriptions.Devices.Device.");
    if part(aKey, pos1) == "." then
        rootkey = "Descriptions.Devices.Device.";
    else
        pos2 = strindex(aKey, ")");
        rootkey = strncpy(aKey, pos2(1) + 1);
    end
endfunction
