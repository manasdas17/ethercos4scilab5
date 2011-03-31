 /**************************************************************************************************
*
*                          msr-hex-bin.c
*
*           Kodierung eines byte array in hex und umgekehrt
*           
*           Autor: Wilhelm Hagemeister
*
*           (C) Copyright IgH 2001
*           Ingenieurgemeinschaft IgH
*           Heinz-B�cker Str. 34
*           D-45356 Essen
*           Tel.: +49 201/61 99 31
*           Fax.: +49 201/61 98 36
*           E-mail: hm@igh-essen.com
*
*
*           $RCSfile: msr_base64.c,v $
*           $Revision: 1.1 $
*           $Author: hm $
*           $Date: 2005/06/14 12:34:23 $
*           $State: Exp $
*
*
*
*
*
*
**************************************************************************************************/


/*--Schutz vor mehrfachem includieren------------------------------------------------------------*/

#ifndef _MSR_HEXBIN_H_
#define _MSR_HEXBIN_H_

/*--includes-------------------------------------------------------------------------------------*/


/*
***************************************************************************************************
*
* Function: bin_to_hex
*           Formatiert einen  hexadezimalen String in einen bin�ren Output 
*
*
* Parameter: src: String, target: Outputbuffer, cnt: Anzahl Eingangsbytes = strlen(src), 
*            targsize: Gr��e des zur Verf�gung stehenden Outputbuffer; = -1 dann keine �berpr�fung
*
* R�ckgabe: -1 wenn targsize zu klein, sonst Anzahl geschriebenen bytes in Targsize
*           -2 wenn cnt ungerade 
*
* Status: exp
*
***************************************************************************************************
*/

int hex_to_bin(char const *src,unsigned char *target,int cnt, int targsize);

/*
***************************************************************************************************
*
* Function: bin_to_hex
*           Formatiert einen bin�ren Inputbuffer in einen hexadezimalen String 
*           (die Funktion h�ngt keine Null an das Ende des Strings !!!)
*
*
* Parameter: src: bin�rer Inputbuffer, target: Outputstring, cnt: Anzahl Eingangsbytes, 
*            targsize: Gr��e des zur Verf�gung stehenden Outputbuffer; = -1 dann keine �berpr�fung
*
* R�ckgabe: -1 wenn Fehler, sonst Anzahl geschriebenen Zeichen in targsize
*
* Status: exp
*
***************************************************************************************************
*/


int bin_to_hex(unsigned char const *src,char *target,int cnt, int targsize);

#endif
