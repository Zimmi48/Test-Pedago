//////////////////////////////////////////////////////////////////////////
//                          TEST L CONJUGAISON                          //
//                      UN LOGICIEL DE LA SUITE PEDAGO                  //
//  CE LOGICIEL PERMET DE S'INTERROGER SUR LES CONJUGAISONS FRANCAISES  //
//                         VERSION 1.0                                  //
//               PROGRAMME PAR                                          //
//                           THEO ZIMMERMANN                            //
//                        POUR                                          //
//                           ALINE MEMMI, INSTITUTRICE                  //
//       A LA SUITE DE TEST M 2.0                                       //
//                                                                      //
// A VENIR : UNE VERSION DE TEST L POUR LA CONJUGAISON ESPAGNOLE        //
//////////////////////////////////////////////////////////////////////////

/*Copyright Th‚o Zimmermann, janvier 2008

Contactez-moi … admin@test-pedago.fr

Le logiciel TestL Conjugaison 1.0 est un programme informatique servant 
… s'entraŒner sur les conjugaisons fran‡aises. 

Ce logiciel est r‚gi par la licence CeCILL soumise au droit fran‡ais et
respectant les principes de diffusion des logiciels libres. Vous pouvez
utiliser, modifier et/ou redistribuer ce programme sous les conditions
de la licence CeCILL telle que diffus‚e par le CEA, le CNRS et l'INRIA 
sur le site "http://www.cecill.info".

En contrepartie de l'accessibilit‚ au code source et des droits de copie,
de modification et de redistribution accord‚s par cette licence, il n'est
offert aux utilisateurs qu'une garantie limit‚e.  Pour les mˆmes raisons,
seule une responsabilit‚ restreinte pŠse sur l'auteur du programme,  le
titulaire des droits patrimoniaux et les conc‚dants successifs.

A cet ‚gard  l'attention de l'utilisateur est attir‚e sur les risques
associ‚s au chargement,  … l'utilisation,  … la modification et/ou au
d‚veloppement et … la reproduction du logiciel par l'utilisateur ‚tant 
donn‚ sa sp‚cificit‚ de logiciel libre, qui peut le rendre complexe … 
manipuler et qui le r‚serve donc … des d‚veloppeurs et des professionnels
avertis poss‚dant  des  connaissances  informatiques approfondies.  Les
utilisateurs sont donc invit‚s … charger  et  tester  l'ad‚quation  du
logiciel … leurs besoins dans des conditions permettant d'assurer la
s‚curit‚ de leurs systŠmes et ou de leurs donn‚es et, plus g‚n‚ralement, 
… l'utiliser et l'exploiter dans les mˆmes conditions de s‚curit‚. 

Le fait que vous puissiez acc‚der … cet en-tˆte signifie que vous avez 
pris connaissance de la licence CeCILL, et que vous en avez accept‚ les
termes.


Copyright Th‚o Zimmermann, january 2008

Write to me at admin@test-pedago.fr

This software is a computer program whose purpose is to train to
french conjugations.

This software is governed by the CeCILL license under French law and
abiding by the rules of distribution of free software.  You can  use, 
modify and/ or redistribute the software under the terms of the CeCILL
license as circulated by CEA, CNRS and INRIA at the following URL
"http://www.cecill.info". 

As a counterpart to the access to the source code and  rights to copy,
modify and redistribute granted by the license, users are provided only
with a limited warranty  and the software's author,  the holder of the
economic rights,  and the successive licensors  have only  limited
liability. 

In this respect, the user's attention is drawn to the risks associated
with loading,  using,  modifying and/or developing or reproducing the
software by the user in light of its specific status of free software,
that may mean  that it is complicated to manipulate,  and  that  also
therefore means  that it is reserved for developers  and  experienced
professionals having in-depth computer knowledge. Users are therefore
encouraged to load and test the software's suitability as regards their
requirements in conditions enabling the security of their systems and/or 
data to be ensured and,  more generally, to use and operate it in the 
same conditions as regards security. 

The fact that you are presently reading this means that you have had
knowledge of the CeCILL license and that you accept its terms.*/


#define UNIX

#include <iostream>
#include <string>
#include "mode_raw/mode_raw.h"
#include "instTest.h"


using namespace std;

/* NOTES : passage de la v0.8 (tests) … la v1.0 (stable)

             rajouter la gestion du temps dans la prochaine version UTILISER mode_raw FAIT
             ATTENTION : si 0 seconde REGLE
             ainsi que l'impression FAIT

             remplacer les cin en utilisant uniquement getchar() (NON)
             / v‚rifier tous les problŠmes relatifs OK
ATTENTION : bug tout de mˆme si utilisation de lettres pour reponseNb
          permettre l'existance de plusieurs solutions en utilisant "/" comme s‚parateur FAIT
+ remplacer 1 fois sur 3 il par elle, 1 fois par on... mˆme chose au pluriel
          ATTENTION : problŠme avec garderOptions et recommencer tout court : Segmentation fault REGLE
ATTENTION : bug si utilisation des flŠches
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
    // durant la pr‚paration du test

    // les deux variables suivantes servent pour toutes les entr‚es au clavier
    char reponse; // un caractŠre
    int reponseNb; // un nombre

    // pour les options
    // les flags
    unsigned int tpsDeVerbe, groupes;
    // les autres
    int nbQuestions, tpsReponse;

    instTest Test; // pour pouvoir utiliser l'objet

    // affichage du "… propos"
    cout << "\t\tTestL Conjugaison" << endl;
    cout << "Logiciel pour s'interroger appartenant … la suite Pedago. Version 1.0" << endl;
    cout << "Con‡u \"sur mesure\" par Th‚o Zimmermann pour Aline Memmi, institutrice" << endl;
    cout << "d‚cembre 2007 - mars 2008 pour la premiŠre version" << endl;
    cout << "Pour en savoir plus, rendez-vous sur www.test-pedago.fr" << endl;

    // boucle principale : sert … recommencer le programme autant de fois que voulu
    do
    {

        // r‚glage des paramŠtres si on ne les garde pas du test pr‚c‚dent
        if (not gardeOptions)
        {
            // r‚glage des temps de verbe
            tpsDeVerbe = 0;
            // cette boucle sert si le choix devait ˆtre annul‚
            do
            {
                continuer = false;

                cout << endl << "Etre interrog‚ sur :" << endl << "1 : un seul temps" << endl;
                cout << "2: tous les temps de tous les modes" << endl << "3: les temps de l'indicatif" << endl;
                cout << "4: les temps simples de l'indicatif" << endl << "5: les temps compos‚s" << endl;
                do
                {
                    ssContinuer = false;

                    cin >> reponseNb;
                    while ((char)getchar() != '\n'); // pour vider le tampon

                    switch (reponseNb)
                    {
                    case 1: // si un seul tps
                        cout << endl << "Etre interrog‚ sur :" << endl << "1: le pr‚sent de l'indicatif" << endl;
                        cout << "2: l'imparfait" << endl << "3: le futur" << endl << "4: le pass‚ simple" << endl;
                        cout << "5: le pass‚ compos‚" << endl << "6: le plus-que-parfait" << endl;
                        cout << "7: le futur ant‚rieur" << endl << "8: le pass‚ ant‚rieur" << endl;
                        cout << "9: le pr‚sent de l'imp‚ratif" << endl << "10: le pr‚sent du conditionnel" << endl;
                        cout << "11: le pr‚sent du subjonctif" << endl << "12: revenir au menu principal" << endl;
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
                    case 5: // si temps compos‚s
                        tpsDeVerbe = PC | PQP | FANT | PANT;
                        break;
                    default: // si le nombre entr‚ ne correspond … rien
                        ssContinuer = true;
                        break;
                    }
                } while (ssContinuer);
            } while (continuer);

            // r‚glage des groupes
            groupes = 0;



            cout << endl << "Etre interrog‚ sur :" << endl << "1: les auxiliaires" << endl;
            cout << "2: le premier groupe (*)" << endl<< "3: le premier groupe (**)";
            cout << endl << "4: le premier groupe (***)" << endl << "5: tout le premier groupe";
            cout << endl << "6: le deuxiŠme groupe" << endl << "7: le troisiŠme groupe (*)"; // (verbes faciles)
            cout << endl << "8: le troisiŠme groupe (**)" << endl;
            cout << "9: le troisiŠme groupe (***)" << endl << "10: tout le troisiŠme groupe";
            cout << endl << "11: les premier et deuxiŠme groupes et les auxiliaires" << endl;
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
                case 6: // 2Šme gr
                    groupes = GR2;
                    break;
                case 7: // 3Šme facile
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
                case 11: // 1er et 2Šme + aux
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

            // r‚glage des autres paramŠtres
            cout << endl << "Choix d'un temps de r‚ponse maximum" << endl;
            cout << "(0 pour ne pas limiter le temps de r‚ponse) : "; // ajouter des indications
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

        // r‚capitulatif des options choisies
        cout << endl << "Pour chaque question, tu as DEUX ESSAIS et " << tpsReponse << " SECONDES pour r‚pondre" << endl;
        cout << "Le premier essai vaut 3 points, le deuxiŠme vaut 1 point" << endl;
        cout << endl << "Tu peux ˆtre interrog‚ sur toutes les personnes des verbes" << endl;
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
            cout << "… TOUS LES TEMPS de tous les modes (indicatif, imp‚ratif, conditionnel, subjonctif)" << endl;
        else // si pas tous les temps
        {
            // si tout l'indicatif
            if ((tpsDeVerbe & PRES) and (tpsDeVerbe & IMP) and (tpsDeVerbe & FUT) and (tpsDeVerbe & PS) and (tpsDeVerbe & PC) and (tpsDeVerbe & PQP) and (tpsDeVerbe & FANT) and (tpsDeVerbe & PANT))
                cout << "… tous les temps de l'INDICATIF" << endl;
            else // si pas tout l'indicatif
            {
                // si tous les temps simples
                if ((tpsDeVerbe & PRES) and (tpsDeVerbe & IMP) and (tpsDeVerbe & FUT) and (tpsDeVerbe & PS))
                    cout << "… tous les TEMPS SIMPLES de l'indicatif" << endl;
                else // si pas tous les temps simples
                {
                    if (tpsDeVerbe & PRES)
                        cout << "au PRESENT de l'indicatif" << endl;
                    if (tpsDeVerbe & IMP)
                        cout << "… l'IMPARFAIT" << endl;
                    if (tpsDeVerbe & FUT)
                        cout << "au FUTUR SIMPLE" << endl;
                    if (tpsDeVerbe & PS)
                        cout << "au PASSE SIMPLE" << endl;
                }
                // si tous les temps compos‚s
                if ((tpsDeVerbe & PC) and (tpsDeVerbe & PQP) and (tpsDeVerbe & FANT) and (tpsDeVerbe & PANT))
                    cout << "… tous les TEMPS COMPOSES de l'indicatif" << endl;
                else // si pas tous les temps compos‚s
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
                cout << "… l'IMPERATIF" << endl;
            if (tpsDeVerbe & COND)
                cout << "au pr‚sent du CONDITIONNEL" << endl;
            if (tpsDeVerbe & SUBJ)
                cout << "au pr‚sent du SUBJONCTIF" << endl;
        }

        cout << endl << "Tape simplement ta r‚ponse et quand tu veux passer … la question suivante, tape sur la touche Entr‚e" << endl;
        cout << "Et pense bien … tout ‚crire en majuscule, sans oublier les accents, c‚dilles..." << endl;
        cout << "Si tu veux t'arrˆter tape sur la touche ECHAP" << endl;
        cout << endl << "Le test est en cours de pr‚paration" << endl;

        // pr‚paration du test
        if (gardeOptions)
            testPrepare = Test.preparer();
        else
            testPrepare = Test.preparer(nbQuestions, tpsReponse, tpsDeVerbe, groupes, recommencer);

        if (testPrepare)
        {
            cout << "Le test est pr‚par‚" << endl;
            cout << endl << "Appuie sur une touche quelconque pour le lancer" << endl;

            mode_raw(1);
            reponse =(char)getchar(); // en attente d'un caractŠre tap‚ au clavier
            mode_raw(0);

            cout << endl;

            /*if (reponse !='\n')
                while ((char)getchar() != '\n'); // pour vider le tampon*/

            // test
            if (Test.lancerTest()) // si le test n'est pas arrˆt‚ en cours, on poursuit sinon on passe
            {
                // r‚capitulatif des questions rat‚es
                do
                {
                    continuer = false;
                    cout << "Le r‚capitulatif final va ˆtre affich‚. Veux-tu aussi l'imprimer ? (O/N) ";

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

        // Pour pouvoir recommencer avec les mˆmes options
        if (recommencer)
        {
            do
            {
                continuer = false;
                cout << "Garder les mˆmes options ? (O/N) ";

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




