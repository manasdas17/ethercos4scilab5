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

function grepkey = getslavedesc_makegrepkey(aKey)
    // Make a straight key good for using with grep.
    // This means making a few characters quoted.
    // Do not include "/" at start and end: the result of this may need to be 
    //     expanded before handing to grep()
    aKey = strsubst(aKey, ".", "\.");
    aKey = strsubst(aKey, "(", "\(");
    aKey = strsubst(aKey, ")", "\)");
    grepkey = aKey;
endfunction
