/**************************************************************************************************
*
*                          msr_mdct.h
*
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
*           $RCSfile: msr_mdct.h,v $
*           $Revision: 1.1 $
*           $Author: hm $
*           $Date: 2005/06/14 12:34:59 $
*           $State: Exp $
*
*
*
*
**************************************************************************************************/


/*--Schutz vor mehrfachem includieren------------------------------------------------------------*/

#ifndef _MSR_MDCT_H_
#define _MSR_MDCT_H_

#define MAX_MDCT_DIM 10  //Gr��te Dimension f�r DCT = 2^MAX_DCT_DIM


struct mdct_buf {
    int dim;
    int refcount;    //Referenzz�hler
    double *swinbuf; //Puffer f�r das Sinusfenster
    double *cosbuf;  //Puffer f�r die Koefizienten
};

static struct mdct_buf mdct_buffers[MAX_MDCT_DIM];


/*
***************************************************************************************************
*
* Function: msr_mdct_init
*
* Beschreibung: initialisiert  das Sinusfenster und die Cosinuscoeffizienten f�r die Modifizierte Cosinus Transformation
*               Die Speicherreservierung erfolgt nur, wenn die Funktion mit einer vorher noch nicht initialisierten Dimension
*               aufgerufen wird
*
* Parameter:   x: exponent, die Dimension ergibt sich aus 2^exponent
*            
*
* R�ckgabe:   Zeiger auf struct mdct_buf
*               
* Status: exp
*
***************************************************************************************************
*/

int msr_mdct_init(unsigned int x);

/*
***************************************************************************************************
*
* Function: msr_mdct_free
*
* Beschreibung: Freigabe des Speichers (Runterz�hlen des Referenzz�hlers; wenn der Null ist wird der
*               Speicher freigegeben
*
* Parameter:   
*            
*
* R�ckgabe:   Refcount, -1: Fehler
*               
* Status: exp
*
***************************************************************************************************
*/

int msr_mdct_free(unsigned int x);

/*
***************************************************************************************************
*
* Function: msr_mdct_global_free
*
* Beschreibung: Freigabe des Speichers und Runterz�hlen aller Referenzz�hler
*
* Parameter:   
*            
*
* R�ckgabe: 
*               
* Status: exp
*
***************************************************************************************************
*/

void msr_mdct_global_free();
 
/*
***************************************************************************************************
*
* Function: msr_mdct
*
* Beschreibung: Berechnet die mdct
*
* Parameter: x: dim = x^2
*            in: Eingangsvektor (mu� von der Gr��e "dim" sein)
*            out: Ausgangsvektor (mu� von der Gr��e "dim/2" sein)
*            
*
* R�ckgabe:   Refcount, -1: Fehler x zu gro�
*                       -2: Fehler nicht initialisiert
*               
* Status: exp
*
***************************************************************************************************
*/

int msr_mdct(unsigned int x,double *in,double *out);

/*
***************************************************************************************************
*
* Function: msr_imdct
*
* Beschreibung: Berechnet die Inverse mdct
*
* Parameter: x: dim = x^2
*            in: Eingangsvektor (mu� von der Gr��e "dim/2" sein)
*            out: Ausgangsvektor (mu� von der Gr��e "dim" sein)
*            
*
* R�ckgabe:   Refcount, -1: Fehler: x zu gro�
*                       -2: Fehler: nicht initialisiert
*               
* Status: exp
*
***************************************************************************************************
*/

int msr_imdct(unsigned int x,double *in,double *out);

#endif

















