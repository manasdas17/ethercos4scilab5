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

// Converts strings to numbers
// Strings are expected to have either hexadecimal or pure decimal content.
//
// numstr   : String matrix of either hexadecimal or pure decimal strings
//            Hexadecimal content is expected to be from Beckhoff xml files, being preceded by "#x"
//            Trailing and leading spaces are allowed.
// varvalue : matrix of resulting numbers
//
// Rationale:
// - Beckhoff's xml files are not always consistent in what type of numbers are used where
//   (e.g. Sm Controlbyte: dec in el5xxx, hex in el3xxx)
//   Therefore the xml reader must preserve the xml hex prefix (#x) and scilab must decode the value
// - To keep things scilabesque, getnum accepts m x n string matrices
// - Any non-string matrix is passed straigth on. This prevents constructs like:
//    "if ~empty(str) then val = getnum(str)"

function varvalue = getnum(numstr)
    if type(numstr) ~= 10 then
        varvalue = numstr;        // Pass any non-string input (e.g. an empty input) straight on.
        return;
    end
    hi = find(part(numstr, (1:2)) == "#x");
    di = find(part(numstr, (1:2)) ~= "#x");
    hv = [];
    dv = [];
    if hi then      // hex2dec chokes on an empty input
        try
            hv = hex2dec(stripblanks((part(numstr(hi), (3: 30)))));
        catch
            error("Function getnum received invalid hex number");
        end
    end
    try
        dv = evstr(  stripblanks(      numstr(di)           ));
    catch
        error("Function getnum received invalid decimal number");
    end
    varvalue(hi) = hv;
    varvalue(di) = dv;
    varvalue = matrix(varvalue, size(numstr));
endfunction
