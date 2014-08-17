/* Cette bibliothäque de fonctions est disponible sur developpez.com :
http://c.developpez.com/faq/?page=clavier_ecran#SCREEN_ecoute_clavier_unix et
http://c.developpez.com/faq/?page=clavier_ecran#SCREEN_mode_raw */

#include <termios.h>
#include <unistd.h>
#include <sys/time.h>


using namespace std;

void mode_raw(int activer)
{
   static struct termios cooked;
   static int raw_actif = 0;

   if (raw_actif == activer)
   {
      return;
   }

   if (activer)
   {
      struct termios raw;

      tcgetattr(STDIN_FILENO, &cooked);

      raw = cooked;
      cfmakeraw(&raw);
      tcsetattr(STDIN_FILENO, TCSANOW, &raw);

   }
   else
   {
      tcsetattr(STDIN_FILENO, TCSANOW, &cooked);
   }

   raw_actif = activer;
}

int unix_kbhit(void)
{
   struct timeval tv = { 0, 0 };
   fd_set readfds;

   FD_ZERO(&readfds);
   FD_SET(STDIN_FILENO, &readfds);

   return select(STDIN_FILENO + 1, &readfds, NULL, NULL, &tv) == 1;
}
