#ifndef MODE_RAW_H
#define MODE_RAW_H

void mode_raw(int activer);

#ifdef UNIX
#define CARACTERE() unix_kbhit()
int unix_kbhit(void);
#endif

#ifdef WINDOWS
#define CARACTERE() kbhit()
#endif

#endif
