/**************************************************************************************************
*
*                         msr_korrelation.h
*
*           Korrelationsverfahren zur Frequenzgangbestimmung
*           
*           Autor: Wilhelm Hagemeister
*
*           (C) Copyright IgH 2002
*           Ingenieurgemeinschaft IgH
*           Heinz-B�cker Str. 34
*           D-45356 Essen
*           Tel.: +49 201/61 99 31
*           Fax.: +49 201/61 98 36
*           E-mail: hm@igh-essen.com
*
*
*           $RCSfile: msr_korrelation.h,v $
*           $Revision: 1.11 $
*           $Author: ab $
*           $Date: 2005/12/13 14:21:34 $
*           $State: Exp $
*
*
*
**************************************************************************************************/
#ifndef _KORRELATION_H_
#define _KORRELATION_H_

/*--defines--------------------------------------------------------------------------------------*/

#define KOR_SCAN      0X1  /* bin am Messen */
#define KOR_WAIT      0x2  /* warte auf Einschwingen */
#define KOR_ACTIVE    0x4  /* Ablauf ist aktiv */
#define KOR_READY     0x8  /* fertig */
#define KOR_START     0x10 /* mu� gesetzt werden wenn der Ablauf starten soll, wird automatisch zur�ckgesetzt */
#define KOR_FREQ      0x20 /* neue Frequenz*/
#define KOR_ERROR     0x40

/*--external data--------------------------------------------------------------------------------*/

/*--structs/typedefs-----------------------------------------------------------------------------*/


struct ampl_korrelation_params
{
    double *input;            /*Eingang von dem die Amplitude ermittelt werden soll*/
    double freq;              /* Frequenz des anregenden Signales*/
    double dt;                /*Zeitschrittweite je Abtastschritt*/
    double sinarg;            /*Sinusargument Wertebereich 0-1*/
    double RE_int;            /*tempor�re Integratorgr��e, wird �ber einen Sinuszyklus hochintegriert*/
    double IM_int;            /*tempor�re Integratorgr��e, wird �ber einen Sinuszyklus hochintegriert*/
    double RE_pt1;            /*Realteil, wird einmal je Sinuszyklus aktualisiert*/
    double IM_pt1;            /*Imagin�rteil, wird einmal je Sinuszyklus aktualisiert*/
    double cycles;            /*Zyklenzahl der Anregung �ber die der Frequenzgang bestimmt werden soll*/
    double pt1konst;          /*PT1-Zeitkonstante*/
    double ampl;              /*aktuelle Amplitude*/
    double phase;             /*aktuelle Phase*/
    int    abtastfrequenz;    /*Abtastfrequenz des Prozesses*/
};




struct msr_korrelation_params {
    char *name;                    /* Basisname */
    char *unit_in;                 /*Anregungseinheit*/
    char *unit_out;                /*Einheit Antwort Strecke*/  
    /*----die nachfolgenden Variablen m�ssen alle belegt werden, damit kor_run aufgerufen werden kann */
    double *frequencies;           /* Array, in dem die Me�frequenzen abgelegt sind in HZ*/
    int num_frequencies;           /* Gr��e dieses Arrays (Anzahl der Frequenz, die durchfahren werden) */
    int num_frequencies_run;     /* Anzahl der Frequenzen, die durchfahren werden sollen (�nderung der Tabelleneintragungen)*/
    int valid_values;              /* Anzahl dargestellter Eintr�ge */
    int valid_anz;                 /*G�ltige Eintr�ge in den Arrays*/
    double out_ampl;               /* Amplitude der Anregung A*sin(wt)  */
    double t_mess;                 /* Me�zeit (in s) die reale Me�zeit weicht etwas ab, 
				     da auf auf volle sin-Durchl�ufe gewartet wird */
    double *ausg;                  /* Zeiger auf Ausgangssignal (von dem der Frequenzgang bestimmt werden soll) */
    double *anreg;                 /*Zeiger auf das anregende Signal*/
    /* die Werte werden jeden Zeitschritt ausgewertet */
    /* Ergebnisse (die Array m�ssen mindestens so lang sein, wie frequencies)*/
    double *ampl;                  /* Array, f�r Amplitude in A/E */   
    double *phase;                 /* Phase in � */
    int start;                     /* Start Korrelation*/
    int stop;                      /* Stop Korrelation*/
    int running;                   /* Korrelation running*/
    struct msr_statemaschine* statemaschine; /*Pointer auf kontrollierende Statemaschine*/
    /* -----------diese Variablen d�rfen nur gelesen werden (au�er Flags)---------------- */
    /* Flags und Proze�info*/
    unsigned int flags;            /* siehe bei Defines */  
    int akt_index;                 /* Index im Frequenzarray, der gerade durchfahren wird */
    int instanz;                   /* Anzahl der laufenden Korrelation die mit diesen Parametern verkn�pft sind inklusive ihrer selbst*/
    int abtastfrequenz;            /*Abtastfrequenz des Basismoduls*/

    /* interne Gr��en (nicht anfassen) */
    struct ampl_korrelation_params korr_ampl;
    int counter;                   /*Anzahl Abtastschritte seit start Messung bei einer Frequenz*/
    double dt;                     /*Zeitschrittweite pro Abtastschritt*/
    int enable_controller;         /* Falls 1 wird die Amplitude nachgeregelt*/
    double ki;                     /* Integratorfaktor der Amplitudenregelung*/
    double ki_max;                 /* max. Begrenzung I-Anteil*/
    double ki_min;                 /* min. Begrenzung I-Anteil*/
    double i_temp;                 /* tempor�rer I-Anteil*/
    int reg_channel;               /*wenn 1 werden die Amplituden und Phasen zus�tzlich als Kanal registriert*/
};

struct msr_korrelation_sec_params {
    /*----die nachfolgenden Variablen m�ssen alle belegt werden, damit kor_add_run aufgerufen werden kann */

    /* Ergebnisse (die Array m�ssen mindestens so lang sein, wie frequencies)*/
    char *unit_out;          /*Einheit Antwort Strecke*/
    double *ampl;                 /* Array, f�r Amplitude in A/E */   
    double *phase;                /* Phase in � */
    struct ampl_korrelation_params korr_ampl;
    double *ausg;                 /* Zeiger auf Ausgangssignal (von dem der Frequenzgang bestimmt werden soll) */
    int use_ref;                  /* wenn use_ref auf 1 steht, wird der Frequenzgang im Verh�ltnis zu
                                     Referenzfrequenzgang gebildet */
};





/*--external functions---------------------------------------------------------------------------*/

/*--prototypes-----------------------------------------------------------------------------------*/


/*
***************************************************************************************************
*
* Function: msr_korrelation_init
*
* Beschreibung: Initialisiert die Struktur f�r die Korrelation
*
* Parameter: name: Basisname in der Parameterstruktur
*            unit: Einheit des Ausgangssignals (f�r die Kanal und Parameterregistrierung)
*            statemaschine :Zustandsmaschine, die den Regler kontrolliert
*            abtastfrequenz: mit der der Regler aufgerufen wird
*
* R�ckgabe: 
*               
* Status: exp
*
***************************************************************************************************
*/
void msr_korrelation_init(struct msr_korrelation_params *par,
			  char *name,              /* Basisname */
			  char *unit_in,            /*Anregungseinheit*/
			  char *unit_out,          /*Einheit Antwort Strecke*/  
			  struct msr_statemaschine* statemaschine, /*Zustandsmaschine, die den Regler
								     kontrolliert*/
			  int abtastfrequenz,       /*Abtastfrequenz der Interruptroutine*/
			  double *frequencies,          /* Array, in dem die Me�frequenzen abgelegt sind in HZ*/
			  int num_frequencies,          /* Gr��e dieses Arrays (Anzahl der Frequenz, die durchfahren werden) */
			  double *anreg,                /* Zeiger auf das anregende Signal*/
			  double *ausg,                 /* Zeiger auf Ausgangssignal (von dem der Frequenzgang bestimmt werden soll) */
			 /* die Werte werden jeden Zeitschritt ausgewertet */
			 /* Ergebnisse (die Array m�ssen mindestens so lang sein, wie frequencies)*/
			  double *ampl,                 /* Array, f�r Amplitude in A/E */   
			  double *phase,                /* Phase in � */
			  double cycles,
			  double t_mess,
			  double ki,
			  double ki_max,
			  double ki_min,
			  int reg_channel
			  );


void msr_korrelation_init_sec(struct msr_korrelation_params *par,
			       struct msr_korrelation_sec_params *par_sec,
			       char *unit_out,          /*Einheit Antwort Strecke*/  
			       double *ausg,                 /* Zeiger auf Ausgangssignal (von dem der Frequenzgang bestimmt werden soll) */
			       /* die Werte werden jeden Zeitschritt ausgewertet */
			       /* Ergebnisse (die Array m�ssen mindestens so lang sein, wie frequencies)*/
			       double *ampl,                 /* Array, f�r Amplitude in A/E */   
			       double *phase,                /* Phase in � */
			       int use_ref                  /* wenn use_ref auf 1 steht, wird der Frequenzgang im Verh�ltnis zu
                                     Referenzfrequenzgang gebildet */
    );


/*
***************************************************************************************************
*
* Function: msr_korrelation_run
*
* Beschreibung: Berechnet Frequenzgang mit Korrelationsmethode, beschrieben in Umdruck RAT, 
*               Institut f�r Regelungstechnik, RWTH-Aachen
*
* Parameter:
*
* R�ckgabe: Fehlerstatus 0: alles ok,
*                        -1: num_frequencies <= 0
*                        -2: nicht initialisierter Zeiger 
*                        -3: hz = 0
*                        -4: eine Frequenz = 0 
*               
* Status: exp
*
***************************************************************************************************
*/

int msr_korrelation_run(struct msr_korrelation_params *prm);

void msr_korrelation_sec_run(struct msr_korrelation_params *base_prm,struct msr_korrelation_sec_params *prm);

/*
***************************************************************************************************
*
* Function: msr_korrelation_reset
*
* Beschreibung: Setzt Frequenzgangparameter zurueck
*
* Parameter:    struct msr_korrelation_params *prm
*
* Status: exp
*
***************************************************************************************************
*/

void msr_korrelation_reset(struct msr_korrelation_params *prm);


/*---------------------------------------------------------------------------------*/
void ampl_korrelation_init(struct ampl_korrelation_params *prm,
			   double *input,
			   double cycles,
			   int abtastfrequenz);
/*---------------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------------*/
void ampl_korrelation(struct ampl_korrelation_params *prm, double freq);
/*---------------------------------------------------------------------------------*/


/*---------------------------------------------------------------------------------*/
void ampl_korrelation_reset(struct ampl_korrelation_params *prm);
/*---------------------------------------------------------------------------------*/


#endif






























