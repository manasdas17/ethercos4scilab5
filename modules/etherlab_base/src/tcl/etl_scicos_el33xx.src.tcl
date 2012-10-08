#/******************************************************************************
# *
# *  Copyright (C) 2008-2009  Andreas Stewering-Bone, Ingenieurgemeinschaft IgH
# *
# *  This file is part of the IgH EtherLAB Scicos Toolbox.
# *  
# *  The IgH EtherLAB Scicos Toolbox is free software; you can
# *  redistribute it and/or modify it under the terms of the GNU Lesser General
# *  Public License as published by the Free Software Foundation; version 2.1
# *  of the License.
# *
# *  The IgH EtherLAB Scicos Toolbox is distributed in the hope that
# *  it will be useful, but WITHOUT ANY WARRANTY; without even the implied
# *  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# *  GNU Lesser General Public License for more details.
# *
# *  You should have received a copy of the GNU Lesser General Public License
# *  along with the IgH EtherLAB Scicos Toolbox. If not, see
# *  <http://www.gnu.org/licenses/>.
# *  
# *  ---
# *  
# *  The license mentioned above concerns the source code only. Using the
# *  EtherCAT technology and brand is only permitted in compliance with the
# *  industrial property and similar rights of Beckhoff Automation GmbH.
# *
# *****************************************************************************/

# Tcl source dialog script for configuring a Beckhoff EL33xx module.
# This script is converted to a tcl script by convert_freeformat_tcl.pl
# See the comments in that script.
# Note: Any (compound) statement embedded in a compound statement MUST be ended with` a semicolon:
# This fails: foreach {} {stmnt foreach {}{    } stmtnt }
# This works: foreach {} {stmnt; foreach {}{    }; stmtnt; }
#
#--------------------------------------------------------------------------
# This commented out section is required if you need to test this script 
# directly from a tcl interpreter (e.g. 'tclsh') independently of a calling scicos script.
# This part replaces 'initvalues'
# There is another such part at the bottom of the script

# package require Tk
# array set slavestring {
#  0 EL3311
#  1 EL3312
#  2 EL3314
# }
# array set slavestate {
#  0 1
#  1 1
#  2 1 
# }
# set slaveselected $slavestring(0)
# set selectid 0
# set masterid 0
# set domainid 0
# set slavealias 0
# set slaveposition 0
# set showstate 0
# set enFilter 0
# 
# set tctype0 0 
# set tctype1 0
# set tctype3 0
# set tctype4 0
# set cjtype0 0 
# set cjtype1 0
# set cjtype3 0
# set cjtype4 0
#--------------------------------------------------------------------------

proc check_stateport {} {
  global slaveselected;
  global selectid; 
  global .eltop; 
  global slavestring; 
  global slavestate; 
  global showstate; 
  set slaveselected [.eltop.list get [.eltop.list curselection]]; 
  set selectid      [.eltop.list curselection]; 
  set selstate  $slavestate([.eltop.list curselection]); 
  if {$selstate == 1} then { 
	  .eltop.showstatus configure -state normal 
  } else {
	  .eltop.showstatus configure -state disable; 
	  set showstate 0;
  }; 
}

set okstate 0
set cancelstate 0
set eltop .eltop
toplevel .eltop
wm title .eltop "Configure Beckhoff EL33xx"
label .eltop.ellabel -text "Selected Slavetype:" -justify center
entry .eltop.showslave -textvariable slaveselected -justify center
scrollbar .eltop.h -orient horizontal -command ".eltop.list xview"
scrollbar .eltop.v -command ".eltop.list yview"
listbox .eltop.list -selectmode single -width 20 -height 10 -setgrid 1 -xscroll ".eltop.h set" -yscroll ".eltop.v set"
checkbutton .eltop.showstatus -text {Enable Statusport} -justify center -variable showstate 
checkbutton .eltop.enablefilter -text {Enable Filter} -justify center -variable enFilter 
label .eltop.masteridlabel -text "Master ID:" -justify right
entry .eltop.masteridentry -textvariable masterid -justify left
label .eltop.domainidlabel -text "Domain ID:" -justify right
entry .eltop.domainidentry -textvariable domainid -justify left
label .eltop.slavealiaslabel -text "Slave Alias:" -justify right
entry .eltop.slavealiasentry -textvariable slavealias -justify left
label .eltop.slavepositionlabel -text "Slave Position:" -justify right
entry .eltop.slavepositionentry -textvariable slaveposition -justify left
button .eltop.setok -text "Ok" -justify center -command {global okstate; set okstate 1}
button .eltop.setcancel -text "Cancel" -justify center -command {global okstate; global cancelstate; set okstate 0; set cancelstate 1}

label .eltop.labelch1 -text "Channel 1" -justify left
label .eltop.labelch2 -text "Channel 2" -justify left
label .eltop.labelch3 -text "Channel 3" -justify left
label .eltop.labelch4 -text "Channel 4" -justify left

foreach i {0 1 3 4} {
  frame .eltop.frametc$i -width 0.5i -height 0.5i -relief ridge -bd 2; 
  label .eltop.frametc$i.label -text "TC-Typ:" -justify left; 
  radiobutton .eltop.frametc$i.tc1 -text "K -200-1370°C" -variable tctype$i -value 0 -justify left; 
  radiobutton .eltop.frametc$i.tc2 -text "J -100-1200°C" -variable tctype$i -value 1 -justify left; 
  radiobutton .eltop.frametc$i.tc3 -text "L    0- 900°C" -variable tctype$i -value 2 -justify left; 
  radiobutton .eltop.frametc$i.tc4 -text "E -100-1000°C" -variable tctype$i -value 3 -justify left; 
  radiobutton .eltop.frametc$i.tc5 -text "T -200- 400°C" -variable tctype$i -value 4 -justify left; 
  radiobutton .eltop.frametc$i.tc6 -text "N -100-1300°C" -variable tctype$i -value 5 -justify left; 
  radiobutton .eltop.frametc$i.tc7 -text "U    0- 600°C" -variable tctype$i -value 6 -justify left; 
  radiobutton .eltop.frametc$i.tc8 -text "B  600-1800°C" -variable tctype$i -value 7 -justify left; 
  radiobutton .eltop.frametc$i.tc9 -text "R    0-1767°C" -variable tctype$i -value 8 -justify left; 
  radiobutton .eltop.frametc$i.tc10 -text "S    0-1760°C" -variable tctype$i -value 9 -justify left; 
  radiobutton .eltop.frametc$i.tc11 -text "C    0-2320°C" -variable tctype$i -value 10 -justify left; 
  radiobutton .eltop.frametc$i.tc12 -text "±30mV resol. 1µV" -variable tctype$i -value 100 -justify left; 
  radiobutton .eltop.frametc$i.tc13 -text "±60mV resol. 2µV" -variable tctype$i -value 101 -justify left; 
  radiobutton .eltop.frametc$i.tc14 -text "±75mV resol. 4µV" -variable tctype$i -value 102 -justify left; 

  frame .eltop.framecj$i -width 0.5i -height 0.5i -relief ridge -bd 2;
  label .eltop.framecj$i.label -text "Cold Junction:" -justify left;
  radiobutton .eltop.framecj$i.cj1 -text "Internal" -variable cjtype$i -value 0 -justify left;
  radiobutton .eltop.framecj$i.cj2 -text "None" -variable cjtype$i -value 1 -justify left;
  radiobutton .eltop.framecj$i.cj3 -text "External data" -variable cjtype$i -value 2 -justify left;
}

grid .eltop.ellabel -row 0 -column 0 -sticky "ew"
grid .eltop.showslave -row 0 -column 1 -sticky "ew"
grid .eltop.list -row 1 -column 0 -rowspan 8 -columnspan 2 -sticky "nsew"
grid .eltop.v -row 1 -column 2 -rowspan 8 -sticky "ns"
grid .eltop.h -row 9 -column 0 -columnspan 2 -sticky "ew"
grid .eltop.masteridlabel -row 1 -column 3 
grid .eltop.masteridentry -row 1 -column 4 -sticky "ew" 
grid .eltop.domainidlabel -row 2 -column 3 
grid .eltop.domainidentry -row 2 -column 4 -sticky "ew" 
grid .eltop.slavealiaslabel -row 3 -column 3 
grid .eltop.slavealiasentry -row 3 -column 4 -sticky "ew" 
grid .eltop.slavepositionlabel -row 4 -column 3 
grid .eltop.slavepositionentry -row 4 -column 4 -sticky "ew" 
grid .eltop.showstatus -row 5 -column 4 -columnspan 2 -sticky "w"
grid .eltop.enablefilter -row 6 -column 4 -columnspan 2 -sticky "w"
grid .eltop.setok -row 7 -column 3 
grid .eltop.setcancel -row 7 -column 4
grid columnconfigure .eltop 0 -weight 1
grid rowconfigure .eltop 0 -weight 1
grid .eltop.labelch1 -row 10 -column 0 -sticky "ew"
grid .eltop.labelch2 -row 10 -column 1 -sticky "ew"
grid .eltop.labelch3 -row 10 -column 3 -sticky "ew"
grid .eltop.labelch4 -row 10 -column 4 -sticky "ew"

foreach i {0 1 3 4} { 
  grid .eltop.frametc$i -row 11 -column $i -sticky "ew"; 
  grid .eltop.frametc$i.label -row 0 -column 0 -sticky "ew"; 
  foreach j {1 2 3 4 5 6 7 8 9 10 11 12 13 14} { 
    grid .eltop.frametc$i.tc$j -row $j -column 0 -sticky "w"; 
  };
  grid .eltop.framecj$i -row 12 -column $i -sticky "ew";
  grid .eltop.framecj$i.label -row 0 -column 0 -sticky "ew";
  foreach j {1 2 3} {
    grid .eltop.framecj$i.cj$j -row $j -column 0 -sticky "w";
  };
}

bind .eltop.list <ButtonRelease-1> "check_stateport "
raise .eltop

#--------------------------------------------------------------------------
# This commented out section is required if you need to test this script 
# directly from a tcl interpreter (e.g. 'tclsh') independently of a calling scicos script.
# This part replaces 'listentry'
# There is another such part at the top of the script
# 
# .eltop.list insert end $slavestring(0)
# .eltop.list insert end $slavestring(1)
# .eltop.list insert end $slavestring(2)
# .eltop.list see $selectid
# .eltop.list selection set $selectid
#--------------------------------------------------------------------------
