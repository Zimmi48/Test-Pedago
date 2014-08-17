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
#include <time.h>
//#include <ctime.h>
#include <fstream>
#include "mode_raw/mode_raw.h"
#include "instTest.h"

using namespace std;

instTest::instTest() : m_testVerbe(NULL), m_testTemps(NULL), m_testPersonne(NULL), m_testSolution(NULL), m_testReponse(NULL), m_optPrecGr(0), m_optPrecTpsVb(0), m_optPrecNbQ(0)
{
    srand(time(NULL));
}

bool instTest::preparer()
{

    // cout << "Fonction preparer(sans options)" << endl;

    // pas d'alloc dynamique
    // on tire juste au hasard ce qu'on met dans le test

    FILE *tableau = NULL;
    int nbHasard;
    string ligne, *sousChaine, *tableauTemp;

    // si les options groupes ou temps ont chang‚
    if ((m_optGr != m_optPrecGr) or (m_optTpsVb != m_optPrecTpsVb))
    {
        m_nbLignes = 0;
        // 1ere ‚tape : r‚alisation d'un fichier contenant tous les verbes, temps... possibles

        // ouverture du fichier dans lequel on stocke temporairement les donn‚es du tableau
        // (pour ne pas avoir … faire des allocations dynamiques intempestives)
        tableau = fopen("tableauTemp", "w+");
        if (tableau != NULL)
        {

            if (m_optGr & AUX)
            {
                // cout << "appel de remplit" << endl;
                if (!this->remplit("gr_aux", tableau)) // aux devient gr_aux pour ‚viter les conflits
                    return false; //                      de noms sous Windows
            }
            if (m_optGr & GR1FACILE)
            {
                if (!this->remplit("1grfacile", tableau))
                    return false;
            }
            if (m_optGr & GR1MOYEN)
            {
                if (!this->remplit("1grmoyen", tableau))
                    return false;
            }
            if (m_optGr & GR1DUR)
            {
                if (!this->remplit("1grdur", tableau))
                    return false;
            }
            if (m_optGr & GR2)
            {
                if (!this->remplit("2gr", tableau))
                    return false;
            }
            if (m_optGr & GR3FACILE)
            {
                if (!this->remplit("3grfacile", tableau))
                    return false;
            }
            if (m_optGr & GR3MOYEN)
            {
                if (!this->remplit("3grmoyen", tableau))
                    return false;
            }
            if (m_optGr & GR3DUR)
            {
                if (!this->remplit("3grdur", tableau))
                    return false;
            }

            //cout << "Fin de la 1Šre ‚tape" << endl;
            // 2Šme ‚tape : passage du fichier … un tableau
            tableauTemp = new string[m_nbLignes];
            //cout << "TableauTemp a ‚t‚ d‚fini" << endl;

            rewind(tableau);
            //cout << "Le tableau est pris du d‚part" << endl;
            for (int i = 0 ; i < m_nbLignes ; i++)
                this->getLigne(&tableauTemp[i], tableau);
            //cout << "Fin de la 2nde ‚tape" << endl;
        }
        else
        {
            cout << "Erreur le fichier tableauTemp n'a pas pu ˆtre ouvert en lecture-‚criture." << endl;
            cout << "Le test ne peut ˆtre pr‚par‚." << endl;
            return false;
        }
    }
    else
    {
        //cout << "remplissage" << endl;
        tableau = fopen("tableauTemp", "r");
        tableauTemp = new string[m_nbLignes];
        for (int i = 0 ; i < m_nbLignes ; i++)
            this->getLigne(&tableauTemp[i], tableau);
        //cout << "fini" << endl;
    }



    // 3Šme ‚tape : tirage au sort … partir du tableau et remplissage des tableaux servant au test
    if (m_nbLignes == 0)
    {
        cout << "D‚sol‚ il n'y a pas de verbes r‚pondant aux options que tu as choisi." << endl;
        return false;
    }
    else if (m_optNbQ > m_nbLignes)
    {
        m_optNbQ = m_nbLignes;
        cout << "Tu as rentr‚ un nombre de questions trop grand." << endl;
        cout << "Le test se fera sur " << m_optNbQ << " questions." << endl;
    }

    if (m_optNbQ != m_optPrecNbQ)
    {
        //cout << "alloc" << endl;
        // alloc dynamiques
        m_testVerbe = new string[m_optNbQ];
        m_testTemps = new string[m_optNbQ];
        m_testPersonne = new string[m_optNbQ];
        m_testSolution = new string[m_optNbQ];
        m_testReponse = new string[m_optNbQ];
    }


    for (int i = 0 ; i < m_optNbQ ; i++)
    {
        nbHasard = rand() % m_nbLignes;
        //cout << "appel de la fonction : " << nbHasard << endl;
        sousChaine = this->decoupeSelonVirgule(tableauTemp[nbHasard], 3); // d‚coupe en 4 la ligne

        m_testVerbe[i] = sousChaine[0];
        m_testTemps[i] = sousChaine[1];
        m_testPersonne[i] = sousChaine[2];
        m_testSolution[i] = sousChaine[3];
        //cout << "chaine d‚coup‚e" << endl;

        // v‚rification que la ligne n'a pas d‚j… ‚t‚ tir‚e
        for (int j = 0 ; j < i ; j++)
        {
            if (m_testVerbe[i] == m_testVerbe[j] and m_testTemps[i] == m_testTemps[j] and m_testPersonne[i] == m_testPersonne[j])
            {
                i--;
                break;
            }
        }
    }

    // fermeture de tableau
    fclose(tableau);

    // on enregistre les valeurs des options groupes et temps
    m_optPrecGr = m_optGr;
    m_optPrecTpsVb = m_optTpsVb;
    m_optPrecNbQ = m_optNbQ;


/*    m_testVerbe[0] = "manger"; // en attendant
    m_testVerbe[1] = "boire";
    m_testVerbe[2] = "voir";
    m_testVerbe[3] = "chanter";
    m_testVerbe[4] = "avoir";
    m_testVerbe[5] = "prendre";
    m_testVerbe[6] = "comprendre";
    m_testVerbe[7] = "lire";
    m_testVerbe[8] = "devoir";
    m_testVerbe[9] = "finir";

    m_testTemps[0] = "Pr‚s.";
    m_testTemps[1] = "Subj.";
    m_testTemps[2] = "Pass‚ s.";
    m_testTemps[3] = "P-Q-P.";
    m_testTemps[4] = "Cond.";
    m_testTemps[5] = "Imper.";
    m_testTemps[6] = "Pass‚ Ant‚.";
    m_testTemps[7] = "Imparf.";
    m_testTemps[8] = "Pass‚ s.";
    m_testTemps[9] = "Pass‚ compo.";

    m_testPersonne[0] = "Tu";
    m_testPersonne[1] = "Je";
    m_testPersonne[2] = "Vous";
    m_testPersonne[3] = "Elles";
    m_testPersonne[4] = "Tu";
    m_testPersonne[5] = "2PS :";
    m_testPersonne[6] = "Nous";
    m_testPersonne[7] = "On";
    m_testPersonne[8] = "Ils";
    m_testPersonne[9] = "Vous";

    m_testSolution[0] = "manges";
    m_testSolution[1] = "boive";
    m_testSolution[2] = "vŒtes";
    m_testSolution[3] = "avaient chant‚";
    m_testSolution[4] = "aurais";
    m_testSolution[5] = "prends";
    m_testSolution[6] = "e–mes compris";
    m_testSolution[7] = "lisait";
    m_testSolution[8] = "durent";
    m_testSolution[9] = "avez fini";*/

    return true;
}

bool instTest::remplit(const char *fichierALire, FILE *fichierARemplir)
{
    FILE *fichierGr;
    // ouvrir le fichier … lire

    fichierGr = fopen(fichierALire, "r");

    if (fichierGr != NULL)
    {
        // cout << "Fichier … lire : " << fichierALire << " ouvert" << endl;
        string temps = "", ligne, *sousChaine, lettre;
        const char *chaine;
        int eExiste;

        while (this->getLigne(&ligne, fichierGr) != "fin")
        {
            // cout << "Lecture de ligne : " << ligne << endl;
            if ((ligne == "") or (ligne == "pr‚sent" and (m_optTpsVb & PRES)) or (ligne == "imparfait" and (m_optTpsVb & IMP)) or (ligne == "futur" and (m_optTpsVb & FUT)) or (ligne == "pass‚ simple" and (m_optTpsVb & PS)) or (ligne == "pass‚ compos‚" and (m_optTpsVb & PC)) or (ligne == "plus-que-parfait" and (m_optTpsVb & PQP)) or (ligne == "futur ant‚rieur" and (m_optTpsVb & FANT)) or (ligne == "pass‚ ant‚rieur" and (m_optTpsVb & PANT)) or (ligne == "imp‚ratif" and (m_optTpsVb & IMPER)) or (ligne == "conditionnel" and (m_optTpsVb & COND)) or (ligne == "subjonctif" and (m_optTpsVb & SUBJ)))
                // cout << "Enregistrement de temps" << endl;
                temps = ligne; /* enregistre le temps sur lequel on travaille actullement ou chaine
                vide si aucun temps*/
            else if (temps != "") // si on est actuellement dans un temps correspondant aux options
            {
                if (temps == "imp‚ratif")
                {
                    sousChaine = this->decoupeSelonVirgule(ligne, 3);
                    // cout << "d‚coup‚ selon virgule" << endl;
                    fprintf(fichierARemplir, "%s,imp‚ratif,2PS:,%s\n", sousChaine[0].c_str(), sousChaine[1].c_str());
                    // cout << "1ere ligne enregistr‚e" << endl;
                    fprintf(fichierARemplir, "%s,imp‚ratif,1PP:,%s\n", sousChaine[0].c_str(), sousChaine[2].c_str());
                    // cout << "2eme ligne enregistr‚e" << endl;
                    fprintf(fichierARemplir, "%s,imp‚ratif,2PP:,%s\n", sousChaine[0].c_str(), sousChaine[3].c_str());
                    // cout << "3eme ligne enregistr‚e" << endl;

                    delete[] sousChaine;
                    m_nbLignes += 3;
                }
                else if (temps == "subjonctif")
                {
                    sousChaine = this->decoupeSelonVirgule(ligne);
                    // cout << "d‚coup‚ selon virgule" << endl;

                    /* La proc‚dure suivante a pour but de d‚terminer si la solution commence par une
                    voyelle et dans ce cas enregistrer J' au lieu de Je

                    pour ce qui est des voyelles "simples" le problŠme est minime :
                    on enregistre dans la chaine lettre le premier caractŠre de sousChaine[1]
                    et on v‚rifie que ce n'est pas un a, e, i, o, u

                    pour le ‚ qui est cod‚ diff‚remment on procŠde avec les fonctions de C de
                    manipulation des chaines: on recherche le ‚ dans la sousChaine[1] et on r‚cupŠre
                    un pointeur qui, consid‚r‚ comme une chaine, constitue toute la chaine … partir
                    du premier ‚ trouv‚. Si un ‚ a ‚t‚ trouv‚ et donc le pointeur ne contient pas
                    NULL on compare la chaine … celle de base, et si elles sont identiques cela
                    veut dire que le ‚ est la premiŠre lettre de sousChaine[1] */

                    chaine = strstr(sousChaine[1].c_str(), "‚");
                    if (chaine != NULL)
                        eExiste = !strcmp(sousChaine[1].c_str(), chaine);
                    else
                        eExiste = 0;
                    if (eExiste or (lettre = sousChaine[1].substr(0,1)) == "i" or lettre == "a" or lettre == "e" or lettre == "o" or lettre == "u")
                        fprintf(fichierARemplir, "%s,subjonctif,Que j',%s\n", sousChaine[0].c_str(), sousChaine[1].c_str());
                    else
                        fprintf(fichierARemplir, "%s,subjonctif,Que je,%s\n", sousChaine[0].c_str(), sousChaine[1].c_str());
                    // cout << "1ere ligne enregistr‚e" << endl;
                    fprintf(fichierARemplir, "%s,subjonctif,Que tu,%s\n", sousChaine[0].c_str(), sousChaine[2].c_str());
                    // cout << "2eme ligne enregistr‚e" << endl;
                    fprintf(fichierARemplir, "%s,subjonctif,Qu'il,%s\n", sousChaine[0].c_str(), sousChaine[3].c_str());
                    // cout << "3eme ligne enregistr‚e" << endl;
                    fprintf(fichierARemplir, "%s,subjonctif,Que nous,%s\n", sousChaine[0].c_str(), sousChaine[4].c_str());
                    // cout << "4eme ligne enregistr‚e" << endl;
                    fprintf(fichierARemplir, "%s,subjonctif,Que vous,%s\n", sousChaine[0].c_str(), sousChaine[5].c_str());
                    // cout << "5eme ligne enregistr‚e" << endl;
                    fprintf(fichierARemplir, "%s,subjonctif,Qu'ils,%s\n", sousChaine[0].c_str(), sousChaine[6].c_str());
                    // cout << "6eme ligne enregistr‚e" << endl;

                    delete[] sousChaine;
                    m_nbLignes += 6;
                }
                else
                {
                    sousChaine = this->decoupeSelonVirgule(ligne);
                    //cout << "d‚coup‚ selon virgule" << endl;
                    chaine = strstr(sousChaine[1].c_str(), "‚");
                    if (chaine != NULL)
                        eExiste = !strcmp(sousChaine[1].c_str(), chaine);
                    else
                        eExiste = 0;
                    if (eExiste or (lettre = sousChaine[1].substr(0,1)) == "i" or lettre == "a" or lettre == "e" or lettre == "o" or lettre == "u")
                        fprintf(fichierARemplir, "%s,%s,J',%s\n", sousChaine[0].c_str(), temps.c_str(), sousChaine[1].c_str());
                    else
                        fprintf(fichierARemplir, "%s,%s,Je,%s\n", sousChaine[0].c_str(), temps.c_str(), sousChaine[1].c_str());
                    //cout << lettre << " est la premiŠre lettre de " << sousChaine[1] << endl;
                    // cout << "1ere ligne enregistr‚e" << endl;
                    fprintf(fichierARemplir, "%s,%s,Tu,%s\n", sousChaine[0].c_str(), temps.c_str(), sousChaine[2].c_str());
                    // cout << "2eme ligne enregistr‚e" << endl;
                    fprintf(fichierARemplir, "%s,%s,Il,%s\n", sousChaine[0].c_str(), temps.c_str(), sousChaine[3].c_str());
                    // cout << "3eme ligne enregistr‚e" << endl;
                    fprintf(fichierARemplir, "%s,%s,Nous,%s\n", sousChaine[0].c_str(), temps.c_str(), sousChaine[4].c_str());
                    // cout << "4eme ligne enregistr‚e" << endl;
                    fprintf(fichierARemplir, "%s,%s,Vous,%s\n", sousChaine[0].c_str(), temps.c_str(), sousChaine[5].c_str());
                    // cout << "5eme ligne enregistr‚e" << endl;
                    fprintf(fichierARemplir, "%s,%s,Ils,%s\n", sousChaine[0].c_str(), temps.c_str(), sousChaine[6].c_str());
                    // cout << "6eme ligne enregistr‚e" << endl;

                    delete[] sousChaine;
                    m_nbLignes += 6;
                }
            }
        }

        // fermer
        fclose(fichierGr);
        return true;
    }
    else
    {
        cout << "Erreur le fichier " << fichierALire << " n'a pas pu ˆtre ouvert." << endl;
        cout << "Le test ne peut ˆtre pr‚par‚." << endl;
        return false;
    }
}

const char* instTest::getLigne(string *chaine, FILE *fichier)
{
    char car;
    *chaine = "";
    while ((car = fgetc(fichier)) != '\n' and (car != EOF))
        *chaine = *chaine + car; // renvoie dans le string
    if (car == EOF) // si la fin du fichier est atteinte
        return "fin";

    return chaine->c_str(); // renvoie d'un tableau de char
}

string* instTest::decoupeSelonVirgule(string chaine, int imax, string separateur)
{
    string *tableau = NULL;
    tableau = new string[imax + 1];
    string car;
    int j = -1;
    chaine = chaine + separateur;

    //cout << "d‚coupe selon virgule" << endl;
    //cout << "le d‚coupage commence" << endl;

    for (int i = 0; i <= imax; i++)
    {
        j++;
        while ((car = chaine.substr(j,1)) != separateur)
        {
            j++;
            tableau[i] =tableau[i] + car;
        }
    }

    //cout << "le d‚coupage a abouti" << endl;
    return tableau;
}

bool instTest::preparer(int nbQ, int tpsRep, unsigned int tpsVb, unsigned int gr, bool dejaAlloue)
{
    // cout << "Fct preparer(avec des options)" << endl;
    // assignement des valeurs des options
    m_optNbQ = nbQ;
    m_optTpsRep = tpsRep;
    m_optTpsVb = tpsVb;
    m_optGr = gr;

    // delete d'un pr‚c‚dent test
    if (dejaAlloue and m_optNbQ != m_optPrecNbQ)
        this->detruit();

    // puis appel de la m‚thode surcharg‚e pour remplir les tableaux :
    return this->preparer();
}


bool instTest::lancerTest()
{
    mode_raw(1);

    long tps;
    int essai; // pour les deux essais
    //bool tpsNonEcoule;
    //long tps;
    char car;
    int nb;

    int points;
    m_points = 0;
    string reponsePrecedente, carac;
    char caracSpe[3];

    int k;

    for (int i = 0; i < m_optNbQ; i++)
    {
        cout << "Question nø" << i + 1 <<  "\r\n";
        cout << m_testVerbe[i] << "\t" << m_testTemps[i] << "\r\n";

        for (essai = 1 ; essai <= 2 ; essai++)
        {
            cout << m_testPersonne[i] << " "; // ATTENTION : n‚cessite un retour … la ligne pour ˆtre
                                            // affich‚

            if (essai == 2)
                reponsePrecedente = m_testReponse[i];
            m_testReponse[i] = "";

            car = 'a';
            // boucle servant … r‚cup‚rer la r‚ponse de l'utilisateur (avec la gestion du temps)
            tps = time(NULL);
            while ((int)car != 13)
            {
                fflush(stdout); // solution : cette fonction synchronise l'‚cran
                if (CARACTERE()) // problŠme : caractŠre bloque l'affichage de la personne
                {
                    //mode_raw(1);
                    //nb = getchar();
                    //car = (char)nb;
                    carac = cin.get();
                    nb = *(carac.c_str());
                    car = (char)nb;

                    if (car >= 'A' and car <='Z')
                        car += 32;
                    if ((car >= 'a' and car <= 'z') or car == ' ')
                    {
                        m_testReponse[i] = m_testReponse[i] + car;
                        cout << "\r" << m_testPersonne[i] << " " << m_testReponse[i];
                    }
                    else if (nb == -61) // or carac == "‚" or carac == "Š" or carac == "…" or carac == "ƒ" or carac == "ˆ" or carac == "Œ" or carac == "“" or carac == "–" or carac == "—")
                    {
                        carac = cin.get();
                        nb = *(carac.c_str());
                        caracSpe[0] = (char)-61;
                        caracSpe[1] = (char)nb;
                        caracSpe[2] = '\0';
                        m_testReponse[i] = m_testReponse[i] + caracSpe;
                        cout << "\r" << m_testPersonne[i] << " " << m_testReponse[i];
                    }
                    /*else if ((int)car == 27) // (nb == 0 or nb == 224 or nb == 195 or nb == 27)
                    {
                        //mode_raw(0);
                        if (CARACTERE())
                        {
                            //mode_raw(1);
                            car = (char)getchar();  CECI A FAIRE BIENTOT PERMETTRA D EVITER QUE LES
                            cout << endl;   TOUCHES SPECIALES COMME FLECHES SOIT COMPRISES COMME
                        }                              DES ECHAPS
                        else
                        {
                            cout << "\r\n";
                            mode_raw(0);
                            return 0;
                        }

                    }*/
                    else if ((int)car == 127 and m_testReponse[i].size() >= 1) // retour arriŠre
                    {
                        cout << "\r";
                        carac = m_testReponse[i].substr(m_testReponse[i].size() - 1, 1);
                        if (*(carac.c_str()) < 0)
                            k = 1;
                        else
                            k = 0;
                        for (unsigned int j = 1 ; j <= m_testPersonne[i].size() + 1 + m_testReponse[i].size() ; j++)
                            cout << " ";
                        m_testReponse[i] = m_testReponse[i].substr(0,m_testReponse[i].size() - 1 -k);
                        cout << "\r" << m_testPersonne[i] << " " << m_testReponse[i];
                    }
                    else if ((int)car == 27) // ECHAP
                    {
                        cout << "\r\n";
                        mode_raw(0);
                        return 0;
                    }
                    //mode_raw(0);
                }
                if (time(NULL) - tps >= m_optTpsRep and m_optTpsRep != 0)

                    car = 13;
            }

            // v‚rification et r‚ponse
            if (verificationReponse(i))
            {
                cout << "\r\nBonne r‚ponse !!!\t";
                points = 3 * (essai == 1) + 1 * (essai == 2);
                m_points += points;
                cout << points << " points" << "\r\n";
                essai = 2;
            }
            else
            {
                if (m_testReponse[i] == "")
                    essai = 2;
                else
                    cout << "\r\nMauvaise r‚ponse";
                if (essai == 1)
                    cout << "\r\nEssaie encore" << "\r\n";
                else
                {
                    cout << "\r\nLa bonne r‚ponse ‚tait : " << m_testSolution[i] << "\r\n";
                    if (m_testReponse[i] == "")
                        m_testReponse[i] = reponsePrecedente;
                    else
                        m_testReponse[i] = reponsePrecedente + " / " + m_testReponse[i];
                }
            }

        }
        cout << "\r\n";
    }

    mode_raw(0);

    return 1;
}

bool instTest::verificationReponse(int i)
{
    string *reponseDecoupe = decoupeSelonVirgule(m_testSolution[i] + "/", 1, "/");
    if (reponseDecoupe[1] != "")
        m_testSolution[i] = reponseDecoupe[0] + " ou " + reponseDecoupe[1];
    return (reponseDecoupe[0] == m_testReponse[i] or reponseDecoupe[1] == m_testReponse[i]);
}

void instTest::afficherRecapitulatif(int impression)
{
        if (impression)
        {
            // cr‚ation du fichier de r‚capitulatif
            ofstream fichier("imprime.txt", ios::out | ios::trunc);

            if(fichier)  // si l'ouverture a r‚ussi
            {
                char date[21];
                time_t temps = time(NULL);
                struct tm *temps2 = localtime(&temps);
                strftime(date, 20, "%d/%m/%Y … %H:%M", temps2);
                fichier << "Test avec TestL Conjugaison r‚alis‚ le " << date << endl << endl;
                fichier << "Points : " << m_points << " / " << 3 * m_optNbQ << endl;
                fichier << "Note : " << m_points * 20 / (3 * m_optNbQ) << " / 20" << endl << endl;

                bool fait = false; /* cette bool permet d'afficher au d‚but du r‚cpitulatif le message
                "bravo tu..." ou "tu as rat‚..." et de ne pas l'afficher s'il n'y a aucune bonne r‚ponse
                ou r‚ponse fausse */
                for (int i = 0; i < m_optNbQ; i++)
                {
                    if (m_testReponse[i] == m_testSolution[i])
                    {
                        if (!fait)
                        {
                            fichier << "\tBravo tu as r‚ussi :" << endl;
                            fait = true;
                        }

                        fichier << "Question " << i + 1 << " : " << m_testPersonne[i] << " " << m_testSolution[i] << " (";
                        fichier << m_testVerbe[i] << " / " << m_testTemps[i] << ")" << endl;
                    }
                }

                fait = false;
                for (int i = 0; i < m_optNbQ; i++)
                {
                    if (m_testReponse[i] != m_testSolution[i])
                    {
                        if (!fait)
                        {
                            fichier << endl << "\tTu as rat‚ (entraŒne-toi encore) :" << endl;
                            fait = true;
                        }

                        fichier << "Question " << i + 1 << " : " << m_testPersonne[i] << " " << m_testSolution[i] << " (";
                        fichier << m_testVerbe[i] << " / " << m_testTemps[i] << ")" << endl;
                        if (m_testReponse[i] == "")
                            fichier << "\tTu n'avais pas r‚pondu" << endl;
                        else
                            fichier << "\tTu avais r‚pondu : " << m_testReponse[i] << endl;
                    }
                }
                fichier.close();  // on referme le fichier

                // impression du r‚capitulatif
                system("./impression_systeme");
            }
            else
                    cout << "Erreur lors de l'impression : le fichier imprime.txt n'a pas pu ˆtre cr‚‚." << endl;
        }
        // affichage

        cout << endl << "Points : " << m_points << " / " << 3 * m_optNbQ << endl;
        cout << "Note : " << m_points * 20 / (3 * m_optNbQ) << " / 20" << endl << endl;

        bool fait = false; /* cette bool permet d'afficher au d‚but du r‚cpitulatif le message
        "bravo tu..." ou "tu as rat‚..." et de ne pas l'afficher s'il n'y a aucune bonne r‚ponse
        ou r‚ponse fausse */
        for (int i = 0; i < m_optNbQ; i++)
        {
            if (m_testReponse[i] == m_testSolution[i])
            {
                if (!fait)
                {
                    cout << "\tBravo tu as r‚ussi :" << endl;
                    fait = true;
                }

                cout << "Question " << i + 1 << " : " << m_testPersonne[i] << " " << m_testSolution[i] << " (";
                cout << m_testVerbe[i] << " / " << m_testTemps[i] << ")" << endl;
            }
        }

        fait = false;
        for (int i = 0; i < m_optNbQ; i++)
        {
            if (m_testReponse[i] != m_testSolution[i])
            {
                if (!fait)
                {
                    cout << endl << "\tTu as rat‚ (entraŒne-toi encore) :" << endl;
                    fait = true;
                }

                cout << "Question " << i + 1 << " : " << m_testPersonne[i] << " " << m_testSolution[i] << " (";
                cout << m_testVerbe[i] << " / " << m_testTemps[i] << ")" << endl;
                if (m_testReponse[i] == "")
                    cout << "\tTu n'avais pas r‚pondu" << endl;
                else
                    cout << "\tTu avais r‚pondu : " << m_testReponse[i] << endl;
            }
        }
        cout << endl;
}

void instTest::detruit()
{
    //cout << "detruit" << endl;
    delete[] m_testVerbe;
    delete[] m_testTemps;
    delete[] m_testPersonne;
    delete[] m_testSolution;
    delete[] m_testReponse;
}

instTest::~instTest()
{
    this->detruit();
}



