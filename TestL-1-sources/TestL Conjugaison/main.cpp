//////////////////////////////////////////////////////////////////////////
//                          TEST L CONJUGAISON                          //
//                      UN LOGICIEL DE LA SUITE PEDAGO                  //
//  CE LOGICIEL PERMET DE S'INTERROGER SUR LES CONJUGAISONS FRANCAISES  //
//                         VERSION 1.0                                  //
//               PROGRAMME PAR                                          //
//                           THEO ZIMMERMANN                            //
//       A LA SUITE DE TEST M 2.0                                       //
//                                                                      //
//////////////////////////////////////////////////////////////////////////

/* 
Copyright Théo Zimmermann, janvier 2008.
Distribué sous licence GNU GPL v3.
*/


#define UNIX

#include <iostream>
#include <string>
#include "mode_raw/mode_raw.h"
#include "instTest.h"


using namespace std;

/* NOTES : passage de la v0.8 (tests) à la v1.0 (stable)

             rajouter la gestion du temps dans la prochaine version UTILISER mode_raw FAIT
             ATTENTION : si 0 seconde REGLE
             ainsi que l'impression FAIT

             remplacer les cin en utilisant uniquement getchar() (NON)
             / vérifier tous les problèmes relatifs OK
ATTENTION : bug tout de même si utilisation de lettres pour reponseNb
          permettre l'existance de plusieurs solutions en utilisant "/" comme séparateur FAIT
+ remplacer 1 fois sur 3 il par elle, 1 fois par on... même chose au pluriel
          ATTENTION : problème avec garderOptions et recommencer tout court : Segmentation fault REGLE
ATTENTION : bug si utilisation des flèches
*/

int main()
{
    /* initialisation :
    recommencer sert pour la boucle principale
    continuer pour toutes les petites boucles do
    gardeOptions pour garder les options lors d'un nouveau test
    */
    bool recommencer = false, continuer, ssContinuer, sssContinuer, gardeOptions = false;
    bool testPrepare; // pour continuer le programme s'il n'y a pas eu d'erreur
    // durant la préparation du test

    // les deux variables suivantes servent pour toutes les entrées au clavier
    char reponse; // un caractère
    int reponseNb; // un nombre

    // pour les options
    // les flags
    unsigned int tpsDeVerbe, groupes;
    // les autres
    int nbQuestions, tpsReponse;

    instTest Test; // pour pouvoir utiliser l'objet

    // affichage du "à propos"
    cout << "\t\tTestL Conjugaison" << endl;
    cout << "Logiciel pour s'interroger appartenant à la suite Pedago. Version 1.0" << endl;
    cout << "Conçu \"sur mesure\" par Théo Zimmermann pour Aline Memmi, institutrice" << endl;
    cout << "décembre 2007 - mars 2008 pour la première version" << endl;
    cout << "Pour en savoir plus, rendez-vous sur www.test-pedago.fr" << endl;

    // boucle principale : sert à recommencer le programme autant de fois que voulu
    do
    {

        // réglage des paramètres si on ne les garde pas du test précédent
        if (not gardeOptions)
        {
            // réglage des temps de verbe
            tpsDeVerbe = 0;
            // cette boucle sert si le choix devait être annulé
            do
            {
                continuer = false;

                cout << endl << "Etre interrogé sur :" << endl << "1 : un seul temps" << endl;
                cout << "2: tous les temps de tous les modes" << endl << "3: les temps de l'indicatif" << endl;
                cout << "4: les temps simples de l'indicatif" << endl << "5: les temps composés" << endl;
                do
                {
                    ssContinuer = false;

                    cin >> reponseNb;
                    while ((char)getchar() != '\n'); // pour vider le tampon

                    switch (reponseNb)
                    {
                    case 1: // si un seul tps
                        cout << endl << "Etre interrogé sur :" << endl << "1: le présent de l'indicatif" << endl;
                        cout << "2: l'imparfait" << endl << "3: le futur" << endl << "4: le passé simple" << endl;
                        cout << "5: le passé composé" << endl << "6: le plus-que-parfait" << endl;
                        cout << "7: le futur antérieur" << endl << "8: le passé antérieur" << endl;
                        cout << "9: le présent de l'impératif" << endl << "10: le présent du conditionnel" << endl;
                        cout << "11: le présent du subjonctif" << endl << "12: revenir au menu principal" << endl;
                        do
                        {
                            sssContinuer = false;

                            cin >> reponseNb;
                            while ((char)getchar() != '\n'); // pour vider le tampon

                            switch (reponseNb) // pour chaque tps
                            {
                            case 1:
                                tpsDeVerbe = PRES;
                                break;
                            case 2:
                                tpsDeVerbe = IMP;
                                break;
                            case 3:
                                tpsDeVerbe = FUT;
                                break;
                            case 4:
                                tpsDeVerbe = PS;
                                break;
                            case 5:
                                tpsDeVerbe = PC;
                                break;
                            case 6:
                                tpsDeVerbe = PQP;
                                break;
                            case 7:
                                tpsDeVerbe = FANT;
                                break;
                            case 8:
                                tpsDeVerbe = PANT;
                                break;
                            case 9:
                                tpsDeVerbe = IMPER;
                                break;
                            case 10:
                                tpsDeVerbe = COND;
                                break;
                            case 11:
                                tpsDeVerbe = SUBJ;
                                break;
                            case 12:
                                continuer = true;
                                break;
                            default:
                                sssContinuer = true;
                                break;
                            }
                        } while (sssContinuer);
                        break;
                    case 2: // si tous les temps
                        tpsDeVerbe = PRES | IMP | FUT | PS | PC | PQP | FANT | PANT | IMPER | COND | SUBJ;
                        break;
                    case 3: // si indicatif
                        tpsDeVerbe = PRES | IMP | FUT | PS | PC | PQP | FANT | PANT;
                        break;
                    case 4: // si temps simples
                        tpsDeVerbe = PRES | IMP | FUT | PS;
                        break;
                    case 5: // si temps composés
                        tpsDeVerbe = PC | PQP | FANT | PANT;
                        break;
                    default: // si le nombre entré ne correspond à rien
                        ssContinuer = true;
                        break;
                    }
                } while (ssContinuer);
            } while (continuer);

            // réglage des groupes
            groupes = 0;



            cout << endl << "Etre interrogé sur :" << endl << "1: les auxiliaires" << endl;
            cout << "2: le premier groupe (*)" << endl<< "3: le premier groupe (**)";
            cout << endl << "4: le premier groupe (***)" << endl << "5: tout le premier groupe";
            cout << endl << "6: le deuxième groupe" << endl << "7: le troisième groupe (*)"; // (verbes faciles)
            cout << endl << "8: le troisième groupe (**)" << endl;
            cout << "9: le troisième groupe (***)" << endl << "10: tout le troisième groupe";
            cout << endl << "11: les premier et deuxième groupes et les auxiliaires" << endl;
            cout << "12: tous les verbes" << endl;

            do
            {
                continuer = false;

                cin >> reponseNb;
                switch (reponseNb)
                {
                case 1: // auxiliaires
                    groupes = AUX;
                    break;
                case 2: // 1er groupe facile
                    groupes = GR1FACILE;
                    break;
                case 3: // 1gr moyen
                    groupes = GR1MOYEN;
                    break;
                case 4: // 1gr dur
                    groupes = GR1DUR;
                    break;
                case 5: // tout 1gr
                    groupes = GR1FACILE | GR1MOYEN | GR1DUR;
                    break;
                case 6: // 2ème gr
                    groupes = GR2;
                    break;
                case 7: // 3ème facile
                    groupes = GR3FACILE;
                    break;
                case 8: // 3gr moyen
                    groupes = GR3MOYEN;
                    break;
                case 9: // 3gr dur
                    groupes = GR3DUR;
                    break;
                case 10: // tout 3gr
                    groupes = GR3FACILE | GR3MOYEN | GR3DUR;
                    break;
                case 11: // 1er et 2ème + aux
                    groupes = AUX | GR1FACILE | GR1MOYEN | GR1DUR | GR2;
                    break;
                case 12: // tous
                    groupes = AUX | GR1FACILE | GR1MOYEN | GR1DUR | GR2 | GR3FACILE | GR3MOYEN | GR3DUR;
                    break;
                default:
                    continuer = true;
                    break;
                }
                while ((char)getchar() != '\n'); // pour vider le tampon
            } while (continuer);

            // réglage des autres paramètres
            cout << endl << "Choix d'un temps de réponse maximum" << endl;
            cout << "(0 pour ne pas limiter le temps de réponse) : "; // ajouter des indications
            do
            {
                continuer = false;

                cin >> reponseNb;
                if ((reponseNb >= 2 and reponseNb <= 40) or reponseNb == 0)
                    tpsReponse = reponseNb;
                else
                    continuer = true;
                while ((char)getchar() != '\n'); // pour vider le tampon

            } while (continuer);
            cout << endl << "Choix d'un nombre de questions : ";
            do
            {
                continuer = false;

                cin >> reponseNb;
                if (reponseNb > 0 and reponseNb < 101)
                    nbQuestions = reponseNb;
                else
                    continuer = true;
                while ((char)getchar() != '\n'); // pour vider le tampon

            } while (continuer);
        }

        // récapitulatif des options choisies
        cout << endl << "Pour chaque question, tu as DEUX ESSAIS et " << tpsReponse << " SECONDES pour répondre" << endl;
        cout << "Le premier essai vaut 3 points, le deuxième vaut 1 point" << endl;
        cout << endl << "Tu peux être interrogé sur toutes les personnes des verbes" << endl;
        // on affiche seulement les groupes choisis
        if (groupes & AUX)
            cout << "ETRE et AVOIR" << endl;
        if ((groupes & GR1FACILE) and (groupes & GR1MOYEN) and (groupes & GR1DUR))
            cout << "du 1ER GROUPE" << endl;
        else
        {
            if (groupes & GR1FACILE)
                cout << "FACILES du 1ER GROUPE" << endl;
            if (groupes & GR1MOYEN)
                cout << "MOYENS du 1ER GROUPE" << endl;
            if (groupes & GR1DUR)
                cout << "DIFFICILES du 1ER GROUPE" << endl;
        }
        if (groupes & GR2)
            cout << "du 2EME GROUPE" << endl;
        if ((groupes & GR3FACILE) and (groupes & GR3MOYEN) and (groupes & GR3DUR))
            cout << "du 3EME GROUPE" << endl;
        else
        {
            if (groupes & GR3FACILE)
                cout << "FACILES du 3EME GROUPE" << endl;
            if (groupes & GR3MOYEN)
                cout << "MOYENS du 3EME GROUPE" << endl;
            if (groupes & GR3DUR)
                cout << "DIFFICILES du 3EME GROUPE" << endl;
        }
        cout << endl;
        // pour les temps
        // si tous les temps
        if (tpsDeVerbe == (PRES | IMP | FUT | PS | PC | PQP | FANT | PANT | IMPER | COND | SUBJ))
            cout << "à TOUS LES TEMPS de tous les modes (indicatif, impératif, conditionnel, subjonctif)" << endl;
        else // si pas tous les temps
        {
            // si tout l'indicatif
            if ((tpsDeVerbe & PRES) and (tpsDeVerbe & IMP) and (tpsDeVerbe & FUT) and (tpsDeVerbe & PS) and (tpsDeVerbe & PC) and (tpsDeVerbe & PQP) and (tpsDeVerbe & FANT) and (tpsDeVerbe & PANT))
                cout << "à tous les temps de l'INDICATIF" << endl;
            else // si pas tout l'indicatif
            {
                // si tous les temps simples
                if ((tpsDeVerbe & PRES) and (tpsDeVerbe & IMP) and (tpsDeVerbe & FUT) and (tpsDeVerbe & PS))
                    cout << "à tous les TEMPS SIMPLES de l'indicatif" << endl;
                else // si pas tous les temps simples
                {
                    if (tpsDeVerbe & PRES)
                        cout << "au PRESENT de l'indicatif" << endl;
                    if (tpsDeVerbe & IMP)
                        cout << "à l'IMPARFAIT" << endl;
                    if (tpsDeVerbe & FUT)
                        cout << "au FUTUR SIMPLE" << endl;
                    if (tpsDeVerbe & PS)
                        cout << "au PASSE SIMPLE" << endl;
                }
                // si tous les temps composés
                if ((tpsDeVerbe & PC) and (tpsDeVerbe & PQP) and (tpsDeVerbe & FANT) and (tpsDeVerbe & PANT))
                    cout << "à tous les TEMPS COMPOSES de l'indicatif" << endl;
                else // si pas tous les temps composés
                {
                    if (tpsDeVerbe & PC)
                        cout << "au PASSE COMPOSE" << endl;
                    if (tpsDeVerbe & PQP)
                        cout << "au PLUS-QUE-PARFAIT" << endl;
                    if (tpsDeVerbe & FANT)
                        cout << "au FUTUR ANTERIEUR" << endl;
                    if (tpsDeVerbe & PANT)
                        cout << "au PASSE ANTERIEUR" << endl;
                }
            }

            if (tpsDeVerbe & IMPER)
                cout << "à l'IMPERATIF" << endl;
            if (tpsDeVerbe & COND)
                cout << "au présent du CONDITIONNEL" << endl;
            if (tpsDeVerbe & SUBJ)
                cout << "au présent du SUBJONCTIF" << endl;
        }

        cout << endl << "Tape simplement ta réponse et quand tu veux passer à la question suivante, tape sur la touche Entrée" << endl;
        cout << "Et pense bien à tout écrire en majuscule, sans oublier les accents, cédilles..." << endl;
        cout << "Si tu veux t'arrêter tape sur la touche ECHAP" << endl;
        cout << endl << "Le test est en cours de préparation" << endl;

        // préparation du test
        if (gardeOptions)
            testPrepare = Test.preparer();
        else
            testPrepare = Test.preparer(nbQuestions, tpsReponse, tpsDeVerbe, groupes, recommencer);

        if (testPrepare)
        {
            cout << "Le test est préparé" << endl;
            cout << endl << "Appuie sur une touche quelconque pour le lancer" << endl;

            mode_raw(1);
            reponse =(char)getchar(); // en attente d'un caractère tapé au clavier
            mode_raw(0);

            cout << endl;

            /*if (reponse !='\n')
                while ((char)getchar() != '\n'); // pour vider le tampon*/

            // test
            if (Test.lancerTest()) // si le test n'est pas arrêté en cours, on poursuit sinon on passe
            {
                // récapitulatif des questions ratées
                do
                {
                    continuer = false;
                    cout << "Le récapitulatif final va être affiché. Veux-tu aussi l'imprimer ? (O/N) ";

                    reponse = (char)getchar();
                    if (reponse !='\n')
                        while ((char)getchar() != '\n'); // pour vider le tampon
                    if (reponse == 'O' or reponse == 'o')
                        Test.afficherRecapitulatif();
                    else if (reponse == 'N' or reponse == 'n')
                        Test.afficherRecapitulatif(0);
                    else
                        continuer = true;
                } while (continuer);
            }
        }

        // on demande si l'utilisateur veut recommencer
        do
        {
            continuer = false;
            cout << "Recommencer ? (O/N) ";

            reponse = (char)getchar();
            if (reponse == 'O' or reponse == 'o')
                recommencer = true;
            else if (reponse == 'N' or reponse == 'n')
                recommencer = false;
            else
                continuer = true;
            if (reponse !='\n')
                while ((char)getchar() != '\n'); // pour vider le tampon

        } while (continuer);

        // Pour pouvoir recommencer avec les mêmes options
        if (recommencer)
        {
            do
            {
                continuer = false;
                cout << "Garder les mêmes options ? (O/N) ";

                reponse = (char)getchar();
                if (reponse == 'O' or reponse == 'o')
                    gardeOptions = true;
                else if (reponse == 'N' or reponse == 'n')
                    gardeOptions = false;
                else
                    continuer = true;
                if (reponse !='\n')
                    while ((char)getchar() != '\n'); // pour vider le tampon

            } while (continuer);
        }

    } while (recommencer);
    return 0;
}




