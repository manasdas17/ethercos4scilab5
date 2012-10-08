#!/usr/bin/perl -w
#/******************************************************************************
# *
# *  Copyright (C) 2012  Len Remmerswaal, Revolution Controls B.V.
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

# Converts a free-formatted tcl file that can be interpreted by tclsh
# into a tcl file that will pass throught the Scicos TCL_EvalStr function.
# This Scicos function fails on any tcl source where a braced group is spread over multiple lines.
# Thus each 'proc' command and each 'foreach' compund statement must be on a single line.
# As this is no good for any decent source creation, this little tool is created.

use IO::File;
use strict;
use Getopt::Std;

my $infilenm;
my $infileh;
my $outfilenm;
my $outfileh;


sub print_debug
{
    my($leveltype,$output)=@_;
    
    warn "\n$leveltype : $output\n";
    exit 0;
}


sub dohelp {
    print <<ALabel;
TCL freeformat to scicos format converter

usage: $0 -h
       $0 <Inputfile>.src.tcl

-h: prints this help

The inputfile file is copied to an output file, with a little difference.

The inputfile should contain a tcl script that is successfully parsed by tclsh.
All compound blocks ('{' at the end of the line, matching '}' somewhere later) 
are placed on a single (long!) line.
This is necessary for the Scicos function TCL_EvalStr to successfully
evaluate the tcl script.

The input file must have an extension .src.tcl 
The output file has the same name and the extension .tcl, without the .src part.
Existing target tcl files are silently overwritten.

ALabel
    exit 0;
}

# Returns the balance of opening and closing braces of the input line.
sub unbalancedbraces
{
  my ($line) = @_;
  return 0 if $line !~ /[{}]/; 			# lines without any braces are not of interest.
  #print "-------------\nInput    : $line";
  $line =~ s/\".*?\"//;					# take out any quoted stuff
  #print "No quote : $line";
  $line =~ s/#.*$//;					# take out any commented stuff
  $line =~ s/[^{}]//g;					# take out any non-brace
  #print "Braces   : $line\n";
  while ($line =~ s/{}//) {};			# take out matching pairs
  #print "-->      : $line : ";
  my $countopen =  ($line =~ tr/{/{/);	# count opening braces
  my $countclose = ($line =~ tr/}/}/);	# count closing braces
  #print "$countopen, $countclose\n";
  return $countopen - $countclose;		# return the balance
}


my %options;
getopts('h', \%options);
&dohelp if defined $options{'h'};
($ARGV[0])                   or &print_debug("Error","No filename provided.\nTry $0 -h\n");
($ARGV[0] =~ /\.src\.tcl$/ ) or &print_debug("Error","Filename does not have extension '.src.tcl'.\nTry $0 -h\n");

$infilenm=$ARGV[0];
$outfilenm = $infilenm;
$outfilenm =~s/\.src\.tcl$/\.tcl/;
open( $infileh, "$infilenm")     or &print_debug("Error", "Cannot open file $infilenm for reading.\n");
open( $outfileh, "> $outfilenm") or &print_debug("Error", "Cannot open file $outfilenm for writing.\n");

my $unbalancedbrace = 0;
while (<$infileh>){
  my $line = $_;
  $line =~ s/^\s+// if $unbalancedbrace > 0;	# Delete leading whitespace
  $unbalancedbrace += &unbalancedbraces($line);
  $line =~ s/\s+$/ / if $unbalancedbrace > 0;	# Delete trailing shitespace
  print $outfileh $line;
}

close($infileh)  or print_debug("Warning", "Closing $infilenm failed.");
close($outfileh) or print_debug("Warning", "Closing $outfilenm failed.");
