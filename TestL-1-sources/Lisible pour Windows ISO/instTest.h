/*Copyright Th�o Zimmermann, janvier 2008

Contactez-moi � admin@test-pedago.fr

Le logiciel TestL Conjugaison 1.0 est un programme informatique servant 
� s'entra�ner sur les conjugaisons fran�aises. 

Ce logiciel est r�gi par la licence CeCILL soumise au droit fran�ais et
respectant les principes de diffusion des logiciels libres. Vous pouvez
utiliser, modifier et/ou redistribuer ce programme sous les conditions
de la licence CeCILL telle que diffus�e par le CEA, le CNRS et l'INRIA 
sur le site "http://www.cecill.info".

En contrepartie de l'accessibilit� au code source et des droits de copie,
de modification et de redistribution accord�s par cette licence, il n'est
offert aux utilisateurs qu'une garantie limit�e.  Pour les m�mes raisons,
seule une responsabilit� restreinte p�se sur l'auteur du programme,  le
titulaire des droits patrimoniaux et les conc�dants successifs.

A cet �gard  l'attention de l'utilisateur est attir�e sur les risques
associ�s au chargement,  � l'utilisation,  � la modification et/ou au
d�veloppement et � la reproduction du logiciel par l'utilisateur �tant 
donn� sa sp�cificit� de logiciel libre, qui peut le rendre complexe � 
manipuler et qui le r�serve donc � des d�veloppeurs et des professionnels
avertis poss�dant  des  connaissances  informatiques approfondies.  Les
utilisateurs sont donc invit�s � charger  et  tester  l'ad�quation  du
logiciel � leurs besoins dans des conditions permettant d'assurer la
s�curit� de leurs syst�mes et ou de leurs donn�es et, plus g�n�ralement, 
� l'utiliser et l'exploiter dans les m�mes conditions de s�curit�. 

Le fait que vous puissiez acc�der � cet en-t�te signifie que vous avez 
pris connaissance de la licence CeCILL, et que vous en avez accept� les
termes.


Copyright Th�o Zimmermann, january 2008

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


#ifndef INSTTEST_H
#define INSTTEST_H

// define pour les flags servant pour options de tps de vb et de groupes
#define PRES 1
#define IMP 2
#define FUT 4
#define PS 8
#define PC 16
#define PQP 32
#define FANT 64
#define PANT 128
#define IMPER 256
#define COND 512
#define SUBJ 1024

#define AUX 1
#define GR1FACILE 2
#define GR1MOYEN 4
#define GR1DUR 8
#define GR2 16
#define GR3FACILE 32
#define GR3MOYEN 64
#define GR3DUR 128


class instTest
{
    public:

    instTest(); // constructeur pour initialiser les pointeurs vers string � NULL
    bool preparer(); // pour pr�parer le Test
    bool preparer(int nbQ, int tpsRep, unsigned int tpsVb, unsigned int gr, bool recommencer);
    void afficherRecapitulatif(int impression = 1);
    bool lancerTest();
    ~instTest(); // destructeur

    private:

    // m�thode : pour les delete
    void detruit();
    bool remplit(const char *fichierALire, FILE *fichierARemplir);
    const char* getLigne(std::string *chaine, FILE *fichier);
    std::string* decoupeSelonVirgule(std::string chaine, int imax = 6, std::string separateur = ",");
    bool verificationReponse(int i);

    // attributs

    // pour le Test
    std::string *m_testVerbe, *m_testTemps, *m_testPersonne, *m_testSolution, *m_testReponse;

    // les options
    int m_points, m_optNbQ, m_optTpsRep;
    unsigned int m_optTpsVb, m_optGr;

    // pour la pr�paration
    int m_nbLignes;

    // les options du test pr�c�dent
    unsigned int m_optPrecGr, m_optPrecTpsVb;
    int m_optPrecNbQ;

};

#endif // INSTTEST_H



