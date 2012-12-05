#!/usr/bin/perl -w
#/******************************************************************************
# *
# *  Copyright (C) 2008-2009  Andreas Stewering-Bone, Ingenieurgemeinschaft IgH
# *  Copyright (C) 2012       Len Remmerswaal,        Revolution Controls
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


use IO::File;
eval{ require XML::LibXML };
if ($@) {
    die "Error: Cannot load 'XML::LibXML'.\nPlease install perl library libxml (libxml-libxml-perl on Debian).\n";
} else {
    import XML::LibXML;
}
use Getopt::Std;
use strict;


my $inputfile;
my $outputfilehandle;
my $outputfile;
my $datfile;

sub print_debug
{
    my($leveltype,$output)=@_;
    
    print"$leveltype : $output\n";
    exit 0;
}


sub dohelp {
    print 
        "XML to Scilab matrix parser\n\n", 
        "usage: $0 [-h] [-f Inputfile.xml]\n\n", 
	"-h: this help\n",
	"-f: Inputfile\n";
    exit 0;
}

sub getnum 
{
    use POSIX qw(strtod);
    my $str = shift;
    $str =~ s/^\s+//;
    $str =~ s/\s+$//;
    $! = 0;
    my($num, $unparsed) = strtod($str);
    if (($str eq '') || ($unparsed != 0) || $!) {
        return undef;
    } else {
        return $num;
    }
}

sub is_numeric { defined getnum($_[0]) }


# Encapsulate a key value pair in a (bunch of) scilab statements.
# Observed: - Appending each (key,value) pair to slavedesc individually makes scilab very slow.
#           - Appending all (key, value) pairs in one giant statement makes scilab choke after some 800+ pairs.
# This routine appends at most 500 in one bunch, then starts another statement.
# Call this with an empty key ('') to wrap up scilab generation up before closing the file. Use the value to 
sub dump_line
{
    use feature 'state';
    state $lines = 0;
    state $chunks = 0;

    my ($outputfilehandle, $key, $value) = @_;

    if (length $key != 0){
        if ( !($lines % 500) ){
            # Begin a new scilab statement, i.e. a new chunk
            print $outputfilehandle "];\n" if $lines != 0;           # Close the previous one if needed
            $chunks++;
            print $outputfilehandle "slavedesc" . $chunks . " = [\'" . $key . "\', \'" . $value . "\'..\n";
        }
        else {
            # Just output another line into the chunk
            print $outputfilehandle     "     ; \'" . $key . "\', \'" . $value . "\'..\n";
        }
        $lines++;
    }
    else {  # length $key == 0
        # Last line has been done. Close things up.
        print $outputfilehandle "];\n";                                 # Close the last chunk
        print $outputfilehandle "slavedesc = [";                        # Start naming the final variable
        for (my $i = 1; $i < $chunks; $i++){
            print $outputfilehandle "slavedesc" . $i . "; ";            # Concatenate all chunks but 1.
        }
        print $outputfilehandle "slavedesc" . $chunks . "];\n";         # Concatenate last chunk,
        for (my $i = 1; $i <= $chunks; $i++){
            print $outputfilehandle "clear slavedesc" . $i . ";\n";     # clear all chunk variables
        }
        print $outputfilehandle "save(\'" . $datfile . "\', slavedesc);\n";
        
    }
    return undef;
}

# If a prospective key matches any item in this list, it is not output. Use wisely.
my @prune = (qr/^Descriptions\.Devices\.Device\(\d+\)\.Profile/,
             qr/ImageData/,
             qr/VendorSpecific/);
             
# Some items can have a text only in some instances, and have an attribute also in other instances.
# This would make then appear as .../node in one place and as.../node/TextContent in another.
# For any leaf node that matches this list, a TextContent node is always created.
# Doing this for all text nodes is 
#my @forceText = (qr/DataType$/);

sub inList
{
    my ($searchStr, @aList) = @_;
    my $found = 0;
    foreach my $pruneStr (@aList){
        $found = 1, last if $searchStr =~ /$pruneStr/;
    }
    #print $searchStr . ": " . $found, "\n";
    $found;
}

sub dump_nodes
{
    my ($node,$outputfilehandle) = @_;
    my $content;
    my $replacestring;
    my $replacevalue;
    my $redname;
    my $attr;
    my $subnode;
    #print $node->nodeName, $node->nodePath(), "\n";
    
    if($node->nodeName eq '#text' or $node->nodeName eq '#cdata-section')
    {
 
      $replacestring = $node->parentNode->nodePath();     # Get owner of the text
      $replacestring =~ s/\//./g;                         # replace all"/" with .
      $replacestring =~ s/\[/\(/g;                        # replace all "[" with "("
      $replacestring =~ s/\]/\)/g;                        # ...exactly.
      $replacestring =~ s/^\.//;                          # remove all leading dots
      $replacestring =~ s/^EtherCATInfo\.//;              # Remove the uninformative leading EtherCATInfo, if present
      $redname = $node->nodePath();                       # path of the text node
      $redname =~ s/\/text\(\)//;                         # remove "/text()"

      return if &inList($replacestring, @prune);

      # In cases where the node has text only, the nodename serves as the leaf identifier
      # In cases where there are only attributes, the nodename is not a leaf identifier
      # in cases where we have both, we invent an attribute "TextContent" that holds the text
      # In cases where the node is in the doubleText array, we do both.
 #     if(($redname eq $node->parentNode->nodePath()) && ($node->parentNode->hasAttributes))
 #     {
 #         $replacestring = $replacestring . ".TextContent";
 #     }

      # Now we can analyze the value of the item.
      if($node->textContent =~/[a-zA-Z0-9\#]+/)           # if we have one or more alphanumerical or hash characters
      {
          if(&is_numeric($node->textContent))
          {
          	  $replacevalue = $node->textContent;
          }
          else
          {
              if($node->textContent =~/\#x/)              #Hex-String
              {
                  $replacevalue = $node->textContent;     # pass hex strings as is: let scilab detect hex
              }
              else
              {
              	  $replacevalue = $node->textContent;
              	  $replacevalue =~ s/\n/\\n/g;				  # replace a \n symbol with a \ and an n symbol
                  $replacevalue =~ s/(\'|\")/$1$1/g;    # Quote any quote
              }
          }
          &dump_line($outputfilehandle, $replacestring, $replacevalue);
#          if( &inList($replacestring) ){
#          	  # this node is known to handle differently in different places. Add an escape.
#          	  $replacestring .= "TextContent";
#           	  &dump_line($outputfilehandle, $replacestring, $replacevalue);
#          }
      }
    }

    if ($node->hasAttributes) 
    {
        foreach $attr ( $node->attributes ) 
        {
            next if $attr->name =~ /:/;                   # ignore namespace specifiers

            $replacestring = $node->nodePath();
            $replacestring =~ s/\//./g;                   # Replace '/' with '.'
            $replacestring =~ s/\[/\(/g;                  # Replace [ with (
            $replacestring =~ s/\]/\)/g;                  #...yeap
            $replacestring =~ s/^\.//;                    # Remove leading dots
            $replacestring =~ s/^EtherCATInfo\.//;        # Remove the uninformative leading EtherCATInfo, if present
            
      		return if &inList($replacestring, @prune);
      		
    	    if(&is_numeric($attr->value))
            {
                &dump_line($outputfilehandle, $replacestring . "." . $attr->name, $attr->value);
            }
            else
            {
                if($attr->value =~/\#x/) #Hex-String
                {
                    $replacevalue = $attr->value;
                }
                else
                {
                    $replacevalue = $attr->value;
               	    $replacevalue =~ s/\n/\\n/g;				# replace a \n symbol with a \ and an n symbol
                    $replacevalue =~ s/(\'|\")/$1$1/g;  # double any quote
                }
                &dump_line( $outputfilehandle, $replacestring ."." . $attr->name, $replacevalue);
            }
        }
    }

    foreach $subnode ($node->getChildnodes)
    {
        &dump_nodes($subnode,$outputfilehandle);
    }
}

# List all possible file leaders and the expected replacement file leader.
# Mostly, the replacement file leader will be "EtherCATInfo_"
my %filenameleader = ("beckhoff "    => "EtherCATInfo_",
                      "temposonics_" => "EtherCATInfo_");

my %opts = (
	    h => 0,
	    f => '',
            );

getopts('hf:', \%opts);

&dohelp if $opts{'h'};
&dohelp if not $opts{'f'};

$inputfile=$opts{'f'};
$outputfile = $inputfile;
$outputfile =~ tr/[A-Z]/[a-z]/;
foreach my $leader (keys %filenameleader)
{
    $outputfile =~ s/$leader/$filenameleader{$leader}/i;
   #$outputfile =~ s/beckhoff /EtherCATInfo_/;
}
$outputfile =~s/ //g;
$outputfile =~s/\.xml/\.sce/;
$datfile = $outputfile;
$datfile =~ s/\.sce/\.dat/;

# Get a parser object
my $parser = XML::LibXML->new(validation => 0);
# Parse the XML file, passed by the user's parameter
my $doc = $parser->parse_file($inputfile);

#Open outputfile
$outputfilehandle = IO::File->new("> $outputfile") 
    or print_debug("Error","Cannot write file to $outputfile!\n");

# Dish out all element names, starting with the root element.
&dump_nodes($doc->getDocumentElement,$outputfilehandle);
&dump_line($outputfilehandle, '', $datfile);    # Close any pending statement and put in the save instruction to file
#print $outputfilehandle "];";
$outputfilehandle->close();
