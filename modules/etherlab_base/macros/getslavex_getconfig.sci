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

function slave_config = getslavex_getconfig(slave_desc, dev_desc)
  //mprintf("getslavedesc_getconfig on rootkey %s\n", rootkey);
  slave_config = [];
  slave_config.vendor      = getslavex_vendor(slave_desc);
  slave_config.productcode = getslavex_productcode(dev_desc);
  slave_smList             = getslavex_smList(dev_desc);
  index_sm = 1;
  for i=1:slave_smList.size
    //disp(['Syncmgr: '+string(i)])
    anSm = slave_smList(i);
    CBytetype =getslavex_getsmtype(anSm);
    //disp(['Controltype: '+string(CBytetype)])
    if CBytetype >= 0 then 
      slave_pdoList = getslavex_pdoList(dev_desc, CBytetype);
      //disp(['Pdo Count: '+string(slave_numPdo)])
      index_default = 1;
      index_alternative = 1;
      Sm=[];
      Sm.index = i;
      Sm.direction = CBytetype; //1= TxPdo Slave send to Master, 2=RxPdo Master send to Slave
      for j=1:slave_pdoList.size
        //disp(['Pdo: '+string(j)])
        Pdo=[];
        aPdo = slave_pdoList(j);
        [smno, pdoindex, smexclude, smmandatory] = getslavex_SmPdoInfo(aPdo);
        Pdo.index = pdoindex;
        slave_entryList = getslavex_SmPdoEntries(aPdo); 
        //disp(['Entrys :'+string(slave_numentrys)]);
        Pdo.Entrys = cell2mat(cell(slave_entryList.size,4));
        for k=1:slave_entryList.size
          anEntry = slave_entryList(k);
          [eindex,esubindex,ebitlen,etype] = getslavex_SmPdoEntry(anEntry);
          if eindex == 0 then
            //disp('GAP-Entry found')
            esubindex = 0;
            etype = 0;
          end
          // etype comes out of the xml as a number of possible strings (e.g. BOOL, SINT, UDINT, DWORD, BIT2)
          // The result seems not to be actually used anywhere.
          // If it is ever used, it will have to be translated to an enumeration integer, because subsequent 
          //     processing is all integer based.
          // For now, we just set the type to 0.
          // Another note: a number of Pdo Entries define a DataType.DScale attribute (e.g 0.1degrC)
          // Currently, there is no application for this in EtherCOS anywhere.
          etype = 0;
          //disp(['Pdo Entry: '+string(eindex)+' '+string(esubindex)+' '+string(ebitlen)+' '+string(etype)])
          Pdo.Entrys(k,:)=[eindex esubindex ebitlen etype];      // etype as a string would have made this line fail.
        end
        //mprintf("Sync Index "+string(smno)+" available "+string(~isempty(smno)) + "\n");
        if and([~isempty(smno) isequal(smno,i-1)]) then //Fitting entry for SyncManager
          Sm.default.Pdo(index_default) = Pdo;
          //mprintf("Added Default Sync Manager Configuration\n");
          index_default = index_default+1;
        else
          Sm.alternativ.Pdo(index_alternative) = Pdo; 
          //mprintf("Added Alternativ Sync Manager Configuration\n");
          index_alternative = index_alternative +1;
        end
      end 
      slave_config.Sm(index_sm)=Sm;
      //disp(Sm)
      index_sm = index_sm +1;
    end // if CByteType > 0
  end  // for slave_smList
  //mprintf("getslavedesc_getconfig done.\n");
endfunction
