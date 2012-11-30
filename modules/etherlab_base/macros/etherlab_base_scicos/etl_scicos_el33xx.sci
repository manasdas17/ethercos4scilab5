// Copyright (C) 2008  Andreas Stewering, Len Remmerswaal
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

function [x,y,typ]=etl_scicos_el33xx(job,arg1,arg2)
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
    ENFI=evstr(exprs(8))
    TCTYP1=evstr(exprs(9))
    TCTYP2=evstr(exprs(10))
    TCTYP3=evstr(exprs(11))
    TCTYP4=evstr(exprs(12))
    CJTYP1=evstr(exprs(13))
    CJTYP2=evstr(exprs(14))
    CJTYP3=evstr(exprs(15))
    CJTYP4=evstr(exprs(16))
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
      ENFI=evstr(exprs(8))
      TCTYP1=evstr(exprs(9))
      TCTYP2=evstr(exprs(10))
      TCTYP3=evstr(exprs(11))
      TCTYP4=evstr(exprs(12))
      CJTYP1=evstr(exprs(13))
      CJTYP2=evstr(exprs(14))
      CJTYP3=evstr(exprs(15))
      CJTYP4=evstr(exprs(16))

      [ln,fun]=where(); 
      if or(fun(3) == ["clikin", "xcosBlockInterface"]) then
         [loop,STYP,STYPID,MID,DID,SLA,SLP,SLST,ENFI,TCTYP1,TCTYP2,TCTYP3,TCTYP4,CJTYP1,CJTYP2,CJTYP3,CJTYP4] = set_etl_slave_el33xx(STYP,STYPID,MID,DID,SLA,SLP,SLST,ENFI,TCTYP1,TCTYP2,TCTYP3,TCTYP4,CJTYP1,CJTYP2,CJTYP3,CJTYP4);
      else
         loop = %f;
      end
      //SDO Config
      //Datatype Index Subindex Value
      slave_sdoconfig = int32([]);
      valid_slave = %f; //Flag for Loop handling
      slave_desc = getslavedesc('EtherCATInfo_el3xxx');

      //Clear Channel List
      clear channel
      clear sdo
      sdoinc = 1;

      select STYP
      case 'EL3311' then
        sdoloop = [8000; TCTYP1; CJTYP1];
      case 'EL3312' then
        sdoloop = [8000 8010; TCTYP1 TCTYP2; CJTYP1 CJTYP2];
      case 'EL3314' then
        sdoloop = [8000 8010 8020 8040; TCTYP1 TCTYP2 TCTYP3 TCTYP4; CJTYP1 CJTYP2 CJTYP3 CJTYP4 ];
      end

      //General SDO Configurations
      for loopcount = sdoloop
        sdocount = loopcount(1);
        tctype   = loopcount(2);
        cjtype   = loopcount(3);

        sdo(sdoinc).index = hex2dec(string(sdocount));
        sdo(sdoinc).subindex = hex2dec('1');
        sdo(sdoinc).datatype = 'si_uint8_T';
        sdo(sdoinc).value =  0; // Disable user scaling Channel 
        sdoinc = sdoinc +1; 

        sdo(sdoinc).index = hex2dec(string(sdocount));
        sdo(sdoinc).subindex = hex2dec('2');
        sdo(sdoinc).datatype = 'si_uint8_T';
        sdo(sdoinc).value =  0; // Value as signed int 16 Channel 
        sdoinc = sdoinc +1;

        sdo(sdoinc).index = hex2dec(string(sdocount));
        sdo(sdoinc).subindex = hex2dec('7');
        sdo(sdoinc).datatype = 'si_uint8_T';
        sdo(sdoinc).value =  0; // Disable Limit 1 Channel 
        sdoinc = sdoinc +1;

        sdo(sdoinc).index = hex2dec(string(sdocount));
        sdo(sdoinc).subindex = hex2dec('8');
        sdo(sdoinc).datatype = 'si_uint8_T';
        sdo(sdoinc).value =  0; // Disable Limit 2 Channel 
        sdoinc = sdoinc +1;

        sdo(sdoinc).index = hex2dec(string(sdocount));
        sdo(sdoinc).subindex = hex2dec('A');
        sdo(sdoinc).datatype = 'si_uint8_T';
        sdo(sdoinc).value =  0; // Disable user callibration Channel 
        sdoinc = sdoinc +1;

        sdo(sdoinc).index = hex2dec(string(sdocount));
        sdo(sdoinc).subindex = hex2dec('B');
        sdo(sdoinc).datatype = 'si_uint8_T';
        sdo(sdoinc).value =  1; // Enable vendor calibration Channel 
        sdoinc = sdoinc +1;

        sdo(sdoinc).index = hex2dec(string(sdocount));
        sdo(sdoinc).subindex = hex2dec('19');
        sdo(sdoinc).datatype = 'si_uint16_T';
        sdo(sdoinc).value = tctype; // Set the thermocouple type
        sdoinc = sdoinc +1

        sdo(sdoinc).index = hex2dec(string(sdocount));
        sdo(sdoinc).subindex = hex2dec('C');
        sdo(sdoinc).datatype = 'si_uint8_T';
        sdo(sdoinc).value = cjtype; // Set the cold junction type
        sdoinc = sdoinc +1
      end

      sdo(sdoinc).index = hex2dec('8000');
      sdo(sdoinc).subindex = hex2dec('6');
      sdo(sdoinc).datatype = 'si_uint8_T'; 
      sdo(sdoinc).value = ENFI; // Enable Filter for all Channels
      sdoinc = sdoinc +1;

      sdo(sdoinc).index = hex2dec('8000');
      sdo(sdoinc).subindex = hex2dec('16');
      sdo(sdoinc).datatype = 'si_uint16_T'; 
      sdo(sdoinc).value = 0; // Default Filter Freq=50Hz
      sdoinc = sdoinc +1;

      select STYP
      case 'EL3311' then
        vct_input   = hex2dec(['7000']); // index for input values (CJ values)
        vct_output  = hex2dec(['6000']); // index for output values (TC values, status byte)
        vct_cj      = [CJTYP1];          // CJ type (CJTYP==2 requires an input channel)
      case 'EL3312' then
        vct_input   = hex2dec(['7000' '7010']);
        vct_output  = hex2dec(['6000' '6010']);
        vct_cj      = [CJTYP1, CJTYP2];
      case 'EL3314' then
        vct_input   = hex2dec(['7000' '7010' '7020' '7030']);
        vct_output  = hex2dec(['6000' '6010' '6020' '6030']);
        vct_cj      = [CJTYP1, CJTYP2, CJTYP3, CJTYP4];
      end
      vct = [vct_input; vct_output; vct_cj];

      chn = 1;		// index to channel
      cho = 0;		// number of output channels (where the TC values go)
      chi = 0;		// number of input channels	(where the CJ values go)

      slave_revision = hex2dec('00100000');	
      slave_type = STYP;
      for v = vct		// input index, output index, cj_type
        cho = cho + 1;
        channel(chn).index = v(2);
        channel(chn).subindex = hex2dec('11');
        channel(chn).vectorlength = 1;
        channel(chn).valuetype = 'si_sint16_T';
        channel(chn).typecode = 'raw';
        channel(chn).direction = 'getvalues';
        channel(chn).channelno = chn;
        channel(chn).scale = 0.1;
        channel(chn).offset = 0.0;
        channel(chn).fullrange = 16;
        chn = chn + 1;
        if v(3) == 2 then				// Need a Cold Juntion channel
          chi = chi +  1;
          channel(chn).index = v(1);      // address for CJ value
          channel(chn).subindex = hex2dec('11');
          channel(chn).vectorlength = 1;
          channel(chn).valuetype = 'si_sint16_T';
          channel(chn).typecode = 'raw';
          channel(chn).direction = 'setvalues';
          channel(chn).channelno = chn;
          channel(chn).scale = 0.1;
          channel(chn).offset = 0.0;
          channel(chn).fullrange = 16;
          chn = chn + 1;
        end
      end // for v = vct
      // Declaring status channels at the end of the rest:
      // This ensures that the extra output channels occur at the end of the block, preventing 
      // a need to reconnect channels on enabling or disabling the status check.
      if SLST == 1 then       // Need a status channel
        for v = vct   // input index, output index, cj_type
          cho = cho + 1;
          channel(chn).index = v(2);
          channel(chn).subindex = hex2dec('7');
          channel(chn).vectorlength = 1;
          channel(chn).valuetype = 'si_uint8_T';
          channel(chn).typecode = 'digital';
          channel(chn).direction = 'getvalues';
          channel(chn).channelno = chn;
          channel(chn).scale = 0.0;
          channel(chn).offset = 0.0;
          channel(chn).fullrange = 0;
          chn = chn+1;
        end
      end

      slave_inputs       = ones(chi, 2);    // Creates chi columns of [1 1]
      slave_input_types  = ones(chi, 1);
      slave_outputs      = ones(cho, 2);		// Creates cho columns of [1 1]
      slave_output_types = ones(cho, 1);

      [slave_sdoconfig,valid_sdoconfig]=build_sdostruct(sdo)
      //disp(slave_sdoconfig)
      [slave_pdomapping,slave_pdomapping_scale,valid_mapping]=build_mapstruct(channel);

      if valid_sdoconfig < 0 then
        disp('No valid SDO Configuration');
      end;

      if valid_mapping < 0 then
        disp('No valid Mapping Configuration');
      end;

      //disp("sdo_config");disp(slave_sdoconfig);
      //disp("pdo_map");disp(slave_pdomapping);
      //disp("pdo_map_scale");disp(slave_pdomapping_scale);

      dev_desc = getslavedesc_checkslave(slave_desc,slave_type,slave_revision);
      if ~isempty(dev_desc) then
        slave_config= getslavedesc_getconfig(slave_desc, dev_desc);
        slave_vendor = slave_config.vendor;              //getslavedesc_vendor(slave_desc);
        slave_productcode = slave_config.productcode;    //getslavedesc_productcode(slave_desc,slave_typeid);
        slave_generic = int32([slave_vendor; slave_productcode]);
        [slave_smconfig,slave_pdoconfig,slave_pdoentry,valid_slave] = getslavedesc_buildopar(slave_config,0,0); //Default Configurartion
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
        exprs(8)=sci2exp(ENFI);
        exprs(9)=sci2exp(TCTYP1);
        exprs(10)=sci2exp(TCTYP2);
        exprs(11)=sci2exp(TCTYP3);
        exprs(12)=sci2exp(TCTYP4);
        exprs(13)=sci2exp(CJTYP1);
        exprs(14)=sci2exp(CJTYP2);
        exprs(15)=sci2exp(CJTYP3);
        exprs(16)=sci2exp(CJTYP4);
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
    end	 // while
  case 'define' then
    model=scicos_model()
    model.sim=list('etl_scicos',4) // name of the c-function
    DEBUG=0;//No Debuging
    MID=0;
    DID=0;
    SLA=0;
    SLP=0;
    SLST=0;
    STYP='EL3311';
    ENFI=0;
    STYPID=0;
    TCTYP1=0;
    TCTYP2=0;
    TCTYP3=0;
    TCTYP4=0;
    CJTYP1=0;
    CJTYP2=0;
    CJTYP3=0;
    CJTYP4=0;
    slave_type = 'EL3311';
    //SDO Config
    //Datatype Index Subindex Value	
    slave_sdoconfig = int32([]);
    rpar=[];
    ipar=[DEBUG;MID;DID;SLA;SLP];
    model.evtin=1;
    model.evtout=[];
    model.out=[1];
    model.out2=[1];
    model.outtyp=[1];
    model.in=[];
    model.rpar=rpar;
    model.ipar=ipar;
    model.dstate=[1];
    model.blocktype='d';
    model.dep_ut=[%t, %f];

    //SDO-Configuration
    sdoinc=1
    sdo(sdoinc).index = hex2dec('8000');
    sdo(sdoinc).subindex = hex2dec('1');
    sdo(sdoinc).datatype = 'si_uint8_T';
    sdo(sdoinc).value =  0; // Disable user scaling Channel 
    sdoinc = sdoinc +1;
    sdo(sdoinc).index = hex2dec('8000');
    sdo(sdoinc).subindex = hex2dec('2');
    sdo(sdoinc).datatype = 'si_uint8_T';
    sdo(sdoinc).value =  0; // Value as signed int 16 Channel 
    sdoinc = sdoinc +1;
    sdo(sdoinc).index = hex2dec('8000');
    sdo(sdoinc).subindex = hex2dec('7');
    sdo(sdoinc).datatype = 'si_uint8_T';
    sdo(sdoinc).value =  0; // Disable Limit 1 Channel 
    sdoinc = sdoinc +1;
    sdo(sdoinc).index = hex2dec('8000');
    sdo(sdoinc).subindex = hex2dec('8');
    sdo(sdoinc).datatype = 'si_uint8_T';
    sdo(sdoinc).value =  0; // Disable Limit 2 Channel 
    sdoinc = sdoinc +1;
    sdo(sdoinc).index = hex2dec('8000');
    sdo(sdoinc).subindex = hex2dec('A');
    sdo(sdoinc).datatype = 'si_uint8_T';
    sdo(sdoinc).value =  0; // Disable user callibration Channel 
    sdoinc = sdoinc +1;
    sdo(sdoinc).index = hex2dec('8000');
    sdo(sdoinc).subindex = hex2dec('B');
    sdo(sdoinc).datatype = 'si_uint8_T';
    sdo(sdoinc).value =  1; // Enable vendor callibration Channel 
    sdoinc = sdoinc +1;
    sdo(sdoinc).index = hex2dec('8000');
    sdo(sdoinc).subindex = hex2dec('19');
    sdo(sdoinc).datatype = 'si_uint16_T';
    sdo(sdoinc).value = TCTYP1; 
    sdoinc = sdoinc +1
    sdo(sdoinc).index = hex2dec('8000');
    sdo(sdoinc).subindex = hex2dec('6');
    sdo(sdoinc).datatype = 'si_uint8_T'; 
    sdo(sdoinc).value = ENFI; // Enable Filter for all Channels
    sdoinc = sdoinc +1;
    sdo(sdoinc).index = hex2dec('8000');
    sdo(sdoinc).subindex = hex2dec('16');
    sdo(sdoinc).datatype = 'si_uint16_T'; 
    sdo(sdoinc).value = 0; // Default Filter Freq=50Hz
    sdoinc = sdoinc +1;

    [slave_sdoconfig,valid_sdoconfig]=build_sdostruct(sdo)
	
    //Set Default Slave
    slave_desc = getslavedesc('EtherCATInfo_el3xxx');	
    slave_revision = hex2dec('00100000');
    dev_desc = getslavedesc_checkslave(slave_desc,slave_type,slave_revision);
    slave_config= getslavedesc_getconfig(slave_desc, dev_desc);   
    slave_vendor = slave_config.vendor;           //getslavedesc_vendor(slave_desc);
    slave_productcode = slave_config.productcode; //getslavedesc_productcode(slave_desc,slave_typeid);
    slave_generic = int32([slave_vendor; slave_productcode]);
    [slave_smconfig,slave_pdoconfig,slave_pdoentry,valid_slave] = getslavedesc_buildopar(slave_config,0,0); //Default Configurartion 

    //Index subindex vectorlength valuetype bitlength Channelno Direction TypeCode Fullrange Scale Offset
    clear channel;
    channel(1).index = hex2dec('6000');
    channel(1).subindex = hex2dec('11');
    channel(1).vectorlength = 1;
    channel(1).valuetype = 'si_sint16_T';
    channel(1).typecode = 'raw';
    channel(1).direction = 'getvalues';
    channel(1).channelno = 1;
    channel(1).scale = 0.1;
    channel(1).offset = 0.0;
    channel(1).fullrange = 16;
    [slave_pdomapping,slave_pdomapping_scale,valid_mapping]=build_mapstruct(channel);	

    if valid_mapping < 0 then
      disp('No valid Mapping Configuration');
    end;
    model.opar = list(slave_smconfig,slave_pdoconfig,slave_pdoentry,slave_sdoconfig,slave_pdomapping,slave_generic, slave_pdomapping_scale);

    exprs=[STYP,sci2exp(ipar(2)),sci2exp(ipar(3)),sci2exp(ipar(4)),sci2exp(ipar(5)),sci2exp(SLST),sci2exp(STYPID),sci2exp(ENFI),sci2exp(TCTYP1),sci2exp(TCTYP2),sci2exp(TCTYP3),sci2exp(TCTYP4),sci2exp(CJTYP1),sci2exp(CJTYP2),sci2exp(CJTYP3),sci2exp(CJTYP4)];
    if use5 then
        gr_i=['xstringb(orig(1),orig(2),[''Ethercat'';''EL331X''],sz(1),sz(2),''fill'');'];
    else
        gr_i=['xstringb(orig(1),orig(2),[''Ethercat ''+STYP;''Master ''+string(MID)+'' Pos ''+string(SLP);''Alias ''+string(SLA)],sz(1),sz(2),''fill'');'];
    end
    x=standard_define([4 2],model,exprs,gr_i)
    x.graphics.id=["EL331X"]
  end     	
endfunction
