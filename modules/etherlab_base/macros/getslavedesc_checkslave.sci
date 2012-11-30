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

//Check for existing Description
function device = getslavedesc_checkslave(slave_desc,slavetype,rev)
  device = [];
  aKey = "";
  indType = grep(slave_desc(:,1)',"/Descriptions.Devices.Device(\(\d+\))?.Type/", "r");
  types = slave_desc(indType,:);             // This is the subset of slave_desc with type descriptions
  aType = find(types(:,2)' == slavetype);    // Indices within types with the right slavetype
  revkeys = types(aType,1) + ".RevisionNo";  // Construct keys for revision numbers
  for aRevkey = revkeys'
    aRev = find(types(:,1)' == aRevkey);     // Fetch the index of the record with the currently considered revision key
    if ~isempty(aRev) then
        if getnum(types(aRev, 2)) == rev then                 // The key exists.See if the value is correct.
            aKey    = strncpy(aRevkey, length(aRevkey) - length(".Type.RevisionNo")); // The root key for the device
            tempkey = getslavedesc_makegrepkey(aKey);         // Make the key OK for use with grep.
            indDevice = grep(slave_desc(:,1)', "/" + tempkey + "/", "r");  
            device    = slave_desc(indDevice,:);		      // All records for the wanted device
            break;                                            // Found the device, so done.
        end
    end
  end
  //mprintf("getslavedesc_checkslave(%s, %#.8x) --> %s\n", slavetype, rev, aKey);
endfunction
