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

function [x,y,typ]=etl_scicos_el5001(job,arg1,arg2)
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
  FRAMEERROR=evstr(exprs(8))
  INHIBIT=evstr(exprs(9))
  SSICODE=evstr(exprs(10))
  BAUD=evstr(exprs(11))
  FRAME=evstr(exprs(12))
  FRAMESIZE=evstr(exprs(13))
  LENGTH=evstr(exprs(14))
  INHIBITTIME=evstr(exprs(15))
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
   FRAMEERROR=evstr(exprs(8))
   INHIBIT=evstr(exprs(9))
   SSICODE=evstr(exprs(10))
   BAUD=evstr(exprs(11))
   FRAME=evstr(exprs(12))
   FRAMESIZE=evstr(exprs(13))
   LENGTH=evstr(exprs(14))
   INHIBITTIME=evstr(exprs(15))
   [ln,fun]=where(); 
   if or(fun(3) == ["clikin", "xcosBlockInterface"]) then
	BAUD = BAUD -1; //Dekrement TCL index
       [loop,STYP,STYPID,MID,DID,SLA,SLP,SLST,FRAMEERROR,INHIBIT,SSICODE,BAUD,FRAME,FRAMESIZE,LENGTH,INHIBITTIME] = set_etl_slave_el5001(STYP,STYPID,MID,DID,SLA,SLP,SLST,FRAMEERROR,INHIBIT,SSICODE,BAUD,FRAME,FRAMESIZE,LENGTH,INHIBITTIME)
	BAUD = BAUD +1; //Inkrement TCL index
    else
       loop = %f;
   end
   //SDO Config
   //Datatype Index Subindex Value
   slave_sdoconfig = int32([]);
   valid_slave = %f; //Flag for Loop handling
   slave_desc = getslavexdesc('Beckhoff EL5xxx');

   //Clear Channel List
   clear channel
   clear sdo
   sdoinc = 1;
   


   //Generell SDO Configurations

   sdo(sdoinc).index = hex2dec('4061');
   sdo(sdoinc).subindex = 1;  
   sdo(sdoinc).datatype = 'si_uint8_T';
   sdo(sdoinc).value = FRAMEERROR; // FrameError
   sdoinc = sdoinc +1;
   sdo(sdoinc).index = hex2dec('4061');
   sdo(sdoinc).subindex = 2;  
   sdo(sdoinc).datatype = 'si_uint8_T';
   sdo(sdoinc).value = 1; // Powerfail
   sdoinc = sdoinc +1;
   sdo(sdoinc).index = hex2dec('4061');
   sdo(sdoinc).subindex = 3;  
   sdo(sdoinc).datatype = 'si_uint8_T';
   sdo(sdoinc).value = INHIBIT; // Enable Inhibit
   sdoinc = sdoinc +1;
   sdo(sdoinc).index = hex2dec('4066');
   sdo(sdoinc).subindex = 0;  
   sdo(sdoinc).datatype = 'si_uint16_T';
   sdo(sdoinc).value = SSICODE; // SSI Code TYpe
   sdoinc = sdoinc +1;
   sdo(sdoinc).index = hex2dec('4067');
   sdo(sdoinc).subindex = 0;  
   sdo(sdoinc).datatype = 'si_uint16_T';
   sdo(sdoinc).value = BAUD; // BAUD Rate
   sdoinc = sdoinc +1;
   sdo(sdoinc).index = hex2dec('4068');
   sdo(sdoinc).subindex = 0;  
   sdo(sdoinc).datatype = 'si_uint16_T';
   sdo(sdoinc).value = FRAME; // Frame Type
   sdoinc = sdoinc +1;
   sdo(sdoinc).index = hex2dec('4069');
   sdo(sdoinc).subindex = 0;  
   sdo(sdoinc).datatype = 'si_uint16_T';
   sdo(sdoinc).value = FRAMESIZE; // Frame Size
   sdoinc = sdoinc +1;
   sdo(sdoinc).index = hex2dec('406A');
   sdo(sdoinc).subindex = 0;  
   sdo(sdoinc).datatype = 'si_uint16_T';
   sdo(sdoinc).value = LENGTH; // Data Length
   sdoinc = sdoinc +1;
   sdo(sdoinc).index = hex2dec('406B');
   sdo(sdoinc).subindex = 0;  
   sdo(sdoinc).datatype = 'si_uint16_T';
   sdo(sdoinc).value = INHIBITTIME; // Inhibit Time
   sdoinc = sdoinc +1;




   if STYP == 'EL5001V1' then
	slave_revision = hex2dec('00000000');	
       	slave_type = 'EL5001';
	
   	//Block Configuration
   	slave_outputs = [1 1]; //[rows input 1 colums input 1;...];
   	slave_output_types = [1] //all real [Type Input 1; Type Input 2]
   	slave_inputs = [];
  	slave_input_types = [];

	channel(1).index = hex2dec('3101');
  	channel(1).subindex = hex2dec('2');
  	channel(1).vectorlength = 1;
  	channel(1).valuetype = 'si_uint32_T';
  	channel(1).typecode = 'raw';
  	channel(1).direction = 'getvalues';
  	channel(1).channelno = 1;
  	channel(1).scale = 1.0;
  	channel(1).offset = 0.0;
  	channel(1).fullrange = 32;

	if SLST == 1 then
	   	//Block Configuration
   		slave_outputs = [1 1; 1 1]; //[rows input 1 colums input 1;...];
   		slave_output_types = [1;1] //all real [Type Input 1; Type Input 2]
		channel(2).index = hex2dec('3101');
  		channel(2).subindex = hex2dec('1');
  		channel(2).vectorlength = 1;
  		channel(2).valuetype = 'si_uint8_T';
  		channel(2).typecode = 'raw';
  		channel(2).direction = 'getvalues';
  		channel(2).channelno = 2;
  		channel(2).scale = 1.0;
  		channel(2).offset = 0.0;
  		channel(2).fullrange = 0;
	end	

	[slave_sdoconfig,valid_sdoconfig]=build_sdostruct(sdo)
  	[slave_pdomapping,slave_pdomapping_scale,valid_mapping]=build_mapstruct(channel);

  end



   if STYP == 'EL5001V2' then
	slave_revision = hex2dec('00010000');	
       	slave_type = 'EL5001';
	
   	//Block Configuration
   	slave_outputs = [1 1]; //[rows input 1 colums input 1;...];
   	slave_output_types = [1] //all real [Type Input 1; Type Input 2]
   	slave_inputs = [];
  	slave_input_types = [];

	channel(1).index = hex2dec('6000');
  	channel(1).subindex = hex2dec('2');
  	channel(1).vectorlength = 1;
  	channel(1).valuetype = 'si_uint32_T';
  	channel(1).typecode = 'raw';
  	channel(1).direction = 'getvalues';
  	channel(1).channelno = 1;
  	channel(1).scale = 1.0;
  	channel(1).offset = 0.0;
  	channel(1).fullrange = 32;

	if SLST == 1 then
	   	//Block Configuration
   		slave_outputs = [1 1; 1 1]; //[rows input 1 colums input 1;...];
   		slave_output_types = [1;1] //all real [Type Input 1; Type Input 2]
		channel(2).index = hex2dec('6000');
  		channel(2).subindex = hex2dec('1');
  		channel(2).vectorlength = 1;
  		channel(2).valuetype = 'si_uint8_T';
  		channel(2).typecode = 'raw';
  		channel(2).direction = 'getvalues';
  		channel(2).channelno = 2;
  		channel(2).scale = 1.0;
  		channel(2).offset = 0.0;
  		channel(2).fullrange = 0;
	end	

	[slave_sdoconfig,valid_sdoconfig]=build_sdostruct(sdo)
  	[slave_pdomapping,slave_pdomapping_scale,valid_mapping]=build_mapstruct(channel);

  end


   if valid_sdoconfig < 0 then
	disp('No valid SDO Configuration');
   end;

   if valid_mapping < 0 then
	disp('No valid Mapping Configuration');
   end;


   dev_desc = getslavex_checkslave(slave_desc,slave_type,slave_revision);
   if ~isempty(dev_desc) then
    slave_config= getslavex_getconfig(slave_desc, dev_desc);
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
     exprs(8)=sci2exp(FRAMEERROR)
     exprs(9)=sci2exp(INHIBIT)
     exprs(10)=sci2exp(SSICODE)
     exprs(11)=sci2exp(BAUD)
     exprs(12)=sci2exp(FRAME)
     exprs(13)=sci2exp(FRAMESIZE)
     exprs(14)=sci2exp(LENGTH)
     exprs(15)=sci2exp(INHIBITTIME)
     graphics.exprs=exprs;
     DEBUG=1; //DEBUG =1 => Debug the calculation function 
     model.ipar=[DEBUG;MID;DID;SLA;SLP];  //transmit integer variables to the c block 
     model.rpar=[];       		 //transmit double variables to the c block
     model.opar = list(slave_smconfig,slave_pdoconfig,slave_pdoentry,slave_sdoconfig,slave_pdomapping,slave_generic, slave_pdomapping_scale);
     model.dstate=[1];
     model.dep_ut=[%t, %f]
     x.graphics=graphics;x.model=model
     break
    end
  end	
case 'define' then
  model=scicos_model()
  model.sim=list('etl_scicos',4) // name of the c-function
  DEBUG=0;//No Debuging
  MID=0;
  DID=0;
  SLA=0;
  SLP=0;
  SLST=0;
  STYP='EL5001V1';
  STYPID=0;
  //Default Configuration
  FRAMEERROR=1; //Disable Frame Error
  INHIBIT=0; //Inhibit Time is disabled
  SSICODE=1; //Greycode
  BAUD=3; // 500kBaud
  FRAME=0; //Multiturn(25-Bit)
  FRAMESIZE=25; //Framesize for Typ  Frame == 3
  LENGTH=24; //Datalength, default
  INHIBITTIME=0; //Inhibittime in nues, default

  slave_type = 'EL5001';
  //SDO Config
  //Datatype Index Subindex Value	
  slave_sdoconfig = int32([]);
  rpar=[];
  ipar=[DEBUG;MID;DID;SLA;SLP];
  model.evtin=1
  model.evtout=[]
  model.out=[1]
  model.out2=[1]
  model.outtyp=[1]
  model.in=[]
  model.rpar=rpar;
  model.ipar=ipar;
  model.dstate=[1];
  model.blocktype='d'
  model.dep_ut=[%t, %f]

  //SDO-Configuration
  sdoinc=1
   //Generell SDO Configurations

   sdo(sdoinc).index = hex2dec('4061');
   sdo(sdoinc).subindex = 1;  
   sdo(sdoinc).datatype = 'si_uint8_T';
   sdo(sdoinc).value = FRAMEERROR; // FrameError
   sdoinc = sdoinc +1;
   sdo(sdoinc).index = hex2dec('4061');
   sdo(sdoinc).subindex = 2;  
   sdo(sdoinc).datatype = 'si_uint8_T';
   sdo(sdoinc).value = 1; // Powerfail
   sdoinc = sdoinc +1;
   sdo(sdoinc).index = hex2dec('4061');
   sdo(sdoinc).subindex = 3;  
   sdo(sdoinc).datatype = 'si_uint8_T';
   sdo(sdoinc).value = INHIBIT; // Enable Inhibit
   sdoinc = sdoinc +1;
   sdo(sdoinc).index = hex2dec('4066');
   sdo(sdoinc).subindex = 0;  
   sdo(sdoinc).datatype = 'si_uint16_T';
   sdo(sdoinc).value = SSICODE; // SSI Code TYpe
   sdoinc = sdoinc +1;
   sdo(sdoinc).index = hex2dec('4067');
   sdo(sdoinc).subindex = 0;  
   sdo(sdoinc).datatype = 'si_uint16_T';
   sdo(sdoinc).value = BAUD; // BAUD Rate
   sdoinc = sdoinc +1;
   sdo(sdoinc).index = hex2dec('4068');
   sdo(sdoinc).subindex = 0;  
   sdo(sdoinc).datatype = 'si_uint16_T';
   sdo(sdoinc).value = FRAME; // Frame Type
   sdoinc = sdoinc +1;
   sdo(sdoinc).index = hex2dec('4069');
   sdo(sdoinc).subindex = 0;  
   sdo(sdoinc).datatype = 'si_uint16_T';
   sdo(sdoinc).value = FRAMESIZE; // Frame Size
   sdoinc = sdoinc +1;
   sdo(sdoinc).index = hex2dec('406A');
   sdo(sdoinc).subindex = 0;  
   sdo(sdoinc).datatype = 'si_uint16_T';
   sdo(sdoinc).value = LENGTH; // Data Length
   sdoinc = sdoinc +1;
   sdo(sdoinc).index = hex2dec('406B');
   sdo(sdoinc).subindex = 0;  
   sdo(sdoinc).datatype = 'si_uint16_T';
   sdo(sdoinc).value = INHIBITTIME; // Inhibit Time
   sdoinc = sdoinc +1;

  [slave_sdoconfig,valid_sdoconfig]=build_sdostruct(sdo)

   if valid_sdoconfig < 0 then
	disp('No valid SDO Configuration');
   end;

	
  //Set Default Slave
  slave_desc = getslavexdesc('Beckhoff EL5xxx');	
  slave_revision = hex2dec('00000000');
  dev_desc = getslavex_checkslave(slave_desc,slave_type,slave_revision);
  slave_config= getslavex_getconfig(slave_desc, dev_desc);   
  slave_vendor = slave_config.vendor;           //getslavedesc_vendor(slave_desc);
  slave_productcode = slave_config.productcode; //getslavedesc_productcode(slave_desc,slave_typeid);
  slave_generic = int32([slave_vendor; slave_productcode]);
  [slave_smconfig,slave_pdoconfig,slave_pdoentry,valid_slave] = getslavedesc_buildopar(slave_config,0,0); //Default Configurartion 
  getslavexdiscard(slave_desc);
  //Index subindex vectorlength valuetype bitlength Channelno Direction TypeCode Fullrange Scale Offset
  clear channel;
  channel(1).index = hex2dec('3101');
  channel(1).subindex = hex2dec('2');
  channel(1).vectorlength = 1;
  channel(1).valuetype = 'si_uint32_T';
  channel(1).typecode = 'raw';
  channel(1).direction = 'getvalues';
  channel(1).channelno = 1;
  channel(1).scale = 1.0;
  channel(1).offset = 0.0;
  channel(1).fullrange = 32;

  [slave_pdomapping,slave_pdomapping_scale,valid_mapping]=build_mapstruct(channel);	

  if valid_mapping < 0 then
	disp('No valid Mapping Configuration');
  end;
  model.opar = list(slave_smconfig,slave_pdoconfig,slave_pdoentry,slave_sdoconfig,slave_pdomapping,slave_generic, slave_pdomapping_scale);

  exprs=[STYP,sci2exp(ipar(2)),sci2exp(ipar(3)),sci2exp(ipar(4)),sci2exp(ipar(5)),sci2exp(SLST),sci2exp(STYPID), sci2exp(FRAMEERROR), sci2exp(INHIBIT), sci2exp(SSICODE), sci2exp(BAUD), sci2exp(FRAME), sci2exp(FRAMESIZE), sci2exp(LENGTH), sci2exp(INHIBITTIME)]
  if use5 then
    gr_i=['xstringb(orig(1),orig(2),[''Ethercat'';''EL5001''],sz(1),sz(2),''fill'');'];
  else
    gr_i=['xstringb(orig(1),orig(2),[''Ethercat ''+STYP;''Master ''+string(MID)+'' Pos ''+string(SLP);''Alias ''+string(SLA)],sz(1),sz(2),''fill'');'];
  end
  x=standard_define([4 2],model,exprs,gr_i)
  x.graphics.id=["EL5001"]
end     	
endfunction
