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

function [x,y,typ]=etl_scicos_el4xxx(job,arg1,arg2)
x=[];y=[];typ=[];
use5 = %f;                      // In scicos version <5
try
  getversion('scilab');
  use5 = %t;                  // In scilab version >= 5
end
select job
case 'plot' then
  exprs=arg1.graphics.exprs;
  STYP=exprs(1)
  MID=evstr(exprs(2))
  DID=evstr(exprs(3))
  SLA=evstr(exprs(4))
  SLP=evstr(exprs(5))
  SLST=evstr(exprs(6))
  STYPID=evstr(exprs(7))
  standard_draw(arg1)
case 'getinputs' then
  [x,y,typ]=standard_inputs(arg1)
case 'getoutputs' then
  [x,y,typ]=standard_outputs(arg1)
case 'getorigin' then
  [x,y]=standard_origin(arg1)
case 'set' then
  x=arg1;
  graphics=arg1.graphics;exprs=graphics.exprs
  model=arg1.model;

  while %t do
    STYP=exprs(1)
    MID=evstr(exprs(2))
    DID=evstr(exprs(3))
    SLA=evstr(exprs(4))
    SLP=evstr(exprs(5))
    SLST=evstr(exprs(6))
    STYPID=evstr(exprs(7))
    [ln,fun]=where(); 
    if or(fun(3) == ["clikin", "xcosBlockInterface"]) then
       [loop,STYP,STYPID,MID,DID,SLA,SLP,SLST] = set_etl_slave_el4xxx(STYP,STYPID,MID,DID,SLA,SLP,SLST)
    else
       loop = %f;
    end
    //SDO Config
    //Datatype Index Subindex Value
    slave_sdoconfig = int32([]);
    valid_slave = %f; //Flag for Loop handling
    slave_desc = getslavexdesc('Beckhoff EL4xxx');
    //TypeCode 0=Analog 1=RawScale 2=Digital
    //Direction 1=Slave send to Master, eg EL3162,EL1004
    //Direction 2= Master send to Slave, eg EL4102,EL2032
    //Fullrange 2^n (Rawbitvalues)
    //Scale in UnitValue, ex. EL4102: 10 for 0-10V (Faktor from 0-1 to Range)
    //Offset in UnitValue, ex. EL4102: 0 for 0V
    //Calculation:
    //RawValue= (Input+Offset)/Scale *FullRange 

    data_stype   =   'EL'+ string([4001      4002      4004      4008      4102      4132      4012      4022      4032    ]);  // ['EL4001' 'EL4002' etc.
    data_slavrev = hex2dec(string([00100000  00100000  00100000  00100000  00000000  00000000  00100000  00100000  00100000])); // slave revision
    data_nchi    =                [1         2         4         8         2         2         2         2         2       ];   // number of channels on device
    data_index   = hex2dec(string([7000      7000      7000      7000      6411      6411      7000      7000      7000    ]));  // data index for first channel
    data_subindx = hex2dec(string([17        17        17        17        1         1         17        17        17      ]));  // subindex for first channel
    data_indxadd = hex2dec(string([10        10        10        10        0         0         10        10        10      ]));  // index adder for each next channel
    data_sbidxad = hex2dec(string([0         0         0         0         1         1         0         0         0       ]));  // subindex adder for each next channel
    data_scale   =                [10        10        10        10        10        10        20        16        10      ];   //? Correct?
    data_offset  =                [0         0         0         0         0         0         0         -4        0       ];   //? Correct?
    data_fulrang =                [12        12        12        12        15        15        12        12        12      ];   // full range at 2^n

// TODO: The data above is extractable from the xml files and probably out of date. 
// There should be a way to import a new set of xml files and configure accordingly without recoding tables like these. Right?

    dvnum = find(data_stype == STYP);           // returns index of requested STYPE in data_stype
    if isempty(dvnum) then                      // Should never happen.
        disp('No valid device type selected');
        break;
    end;
    slave_revision = data_slavrev(dvnum);   
    slave_type = data_stype(dvnum);
    
    clear channel;
    for chi = 1:(data_nchi(dvnum))
      channel(chi).index        = data_index(dvnum)   + (chi-1)*data_indxadd(dvnum);
      channel(chi).subindex     = data_subindx(dvnum) + (chi-1)*data_sbidxad(dvnum);
      channel(chi).vectorlength = 1;
      channel(chi).valuetype    = 'si_uint16_T';
      channel(chi).typecode     = 'analog';
      channel(chi).direction    = 'setvalues';
      channel(chi).channelno    = chi;
      channel(chi).scale        = data_scale(dvnum);
      channel(chi).offset       = data_offset(dvnum);
      channel(chi).fullrange    = data_fulrang(dvnum);
    end
    [slave_pdomapping,slave_pdomapping_scale,valid_mapping]=build_mapstruct(channel);
    
    slave_inputs       = ones(data_nchi(dvnum), 2);      // Creates chi columns of a single slave_inputs row
    slave_input_types  = ones(data_nchi(dvnum), 1);
    slave_outputs = [];
    slave_output_types = [];

    if valid_mapping < 0 then
      disp('No valid Mapping Configuration');
    end;

    dev_desc = getslavex_checkslave(slave_desc,slave_type,slave_revision);
    if ~isempty(dev_desc) then
      slave_config = getslavex_getconfig(slave_desc, dev_desc);
      slave_vendor = slave_config.vendor;              //getslavedesc_vendor(slave_desc);
      slave_productcode = slave_config.productcode;    //getslavedesc_productcode(slave_desc,slave_typeid);
      slave_generic = int32([slave_vendor; slave_productcode]);
      [slave_smconfig,slave_pdoconfig,slave_pdoentry,valid_slave] = getslavedesc_buildopar(slave_config,0,0); //Default Configurartion
      getslavexdiscard(slave_desc);
    else
      disp('Can not find valid Configuration.');
    end
	
    if isempty(slave_inputs) then
      slave_input_list = list();
    else
      slave_input_list = list(slave_inputs,slave_input_types);
    end   
    if isempty(slave_outputs) then
      slave_output_list = list();
    else
      slave_output_list = list(slave_outputs,slave_output_types);
    end   

    [model,graphics,ok]=set_io(model,graphics,slave_input_list,slave_output_list,[1],[])
    if and([~loop ok valid_slave]) then
      exprs(1)=STYP;
      exprs(2)=sci2exp(MID);
      exprs(3)=sci2exp(DID);
      exprs(4)=sci2exp(SLA);
      exprs(5)=sci2exp(SLP);
      exprs(6)=sci2exp(SLST);
      exprs(7)=sci2exp(STYPID);
      graphics.exprs=exprs;
      DEBUG=1; //DEBUG =1 => Debug the calculation function 
      model.ipar=[DEBUG;MID;DID;SLA;SLP];  //transmit integer variables to the c block 
      model.rpar=[];       		 //transmit double variables to the c block
      model.opar = list(slave_smconfig,slave_pdoconfig,slave_pdoentry,slave_sdoconfig,slave_pdomapping,slave_generic,slave_pdomapping_scale);
      model.dstate=[1];
      model.dep_ut=[%t, %f]
      x.graphics=graphics;x.model=model
      break
    end
  end	
case 'define' then
  model=scicos_model()
  model.sim=list('etl_scicos',4) // name of the c-function
  DEBUG=1;//No Debuging
  MID=0;
  DID=0;
  SLA=0;
  SLP=0;
  SLST=0;
  STYP='EL4102';
  STYPID=4;
  slave_type = 'EL4102';
  //SDO Config
  //Datatype Index Subindex Value	
  slave_sdoconfig = int32([]);
  rpar=[];
  ipar=[DEBUG;MID;DID;SLA;SLP];
  model.evtin=1
  model.evtout=[]
  model.in=[1;1]
  model.in2=[1;1]
  model.intyp=[1;1]
  model.out=[]
  model.rpar=rpar;
  model.ipar=ipar;
  model.dstate=[1];
  model.blocktype='d'
  model.dep_ut=[%t, %f]
  //Set Default Slave
  slave_desc = getslavexdesc('Beckhoff EL4xxx');	
  slave_revision = 0;
  dev_desc = getslavex_checkslave(slave_desc,slave_type,slave_revision);
  slave_config= getslavex_getconfig(slave_desc, dev_desc);   
  slave_vendor = slave_config.vendor;           //getslavedesc_vendor(slave_desc);
  slave_productcode = slave_config.productcode; //getslavedesc_productcode(slave_desc,slave_typeid);
  slave_generic = int32([slave_vendor; slave_productcode]);
  [slave_smconfig,slave_pdoconfig,slave_pdoentry,valid_slave] = getslavedesc_buildopar(slave_config,0,0); //Default Configurartion
  getslavexdiscard(slave_desc);
  //Clear Channel List
  clear channel
  channel(1).index = hex2dec('6411');
  channel(1).subindex = hex2dec('1');
  channel(1).vectorlength = 1;
  channel(1).valuetype = 'si_uint16_T';
  channel(1).typecode = 'analog';
  channel(1).direction = 'setvalues';
  channel(1).channelno = 1;
  channel(1).scale = 10.0;
  channel(1).offset = 0.0;
  channel(1).fullrange = 15;
  channel(2) = channel(1);
  channel(2).subindex = hex2dec('2');
  channel(2).channelno = 2;
  [slave_pdomapping,slave_pdomapping_scale,valid_mapping]=build_mapstruct(channel);

  if valid_mapping < 0 then
    disp('No valid Mapping Configuration');
  end;
  model.opar = list(slave_smconfig,slave_pdoconfig,slave_pdoentry,slave_sdoconfig,slave_pdomapping,slave_generic,slave_pdomapping_scale);

  exprs=[STYP,sci2exp(ipar(2)),sci2exp(ipar(3)),sci2exp(ipar(4)),sci2exp(ipar(5)),sci2exp(SLST),sci2exp(STYPID)]
  if use5 then
    gr_i=['xstringb(orig(1),orig(2),[''Ethercat'';''EL4XXX''],sz(1),sz(2),''fill'');']
  else
    gr_i=['xstringb(orig(1),orig(2),[''Ethercat ''+STYP;''Master ''+string(MID)+'' Pos ''+string(SLP);''Alias ''+string(SLA)],sz(1),sz(2),''fill'');']
  end
  x=standard_define([4 2],model,exprs,gr_i)
  x.graphics.id=["EL4XXX"]
end     	
endfunction
