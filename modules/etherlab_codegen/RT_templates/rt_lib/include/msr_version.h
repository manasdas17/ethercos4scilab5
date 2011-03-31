#ifndef _MSR_VERSION_H_
#define _MSR_VERSION_H_

// Version der MSR_LIBRARIES
#define VERSION  5
#define PATCHLEVEL 0
#define SUBLEVEL  0


#define MSR_VERSION (((VERSION) << 16) + ((PATCHLEVEL) << 8) + (SUBLEVEL))

//Liste der Features der aktuellen rtlib-Version, wichtig, mu� aktuell gehalten werden
//da der Testmanager sich auf die Features verl��t

#define MSR_FEATURES "pushparameters,binparameters,maschinehalt"

/* pushparameters: Parameter werden vom Echtzeitprozess an den Userprozess gesendet bei �nderung
   binparameters: Parameter k�nnen Bin�r �bertragen werden
   maschinehalt: Rechner kann durch Haltbefehl heruntergefahren werden
*/
#endif
