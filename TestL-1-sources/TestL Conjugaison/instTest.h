/* 
Copyright Théo Zimmermann, janvier 2008.
Distribué sous licence GNU GPL v3.
*/


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

    instTest(); // constructeur pour initialiser les pointeurs vers string à NULL
    bool preparer(); // pour préparer le Test
    bool preparer(int nbQ, int tpsRep, unsigned int tpsVb, unsigned int gr, bool recommencer);
    void afficherRecapitulatif(int impression = 1);
    bool lancerTest();
    ~instTest(); // destructeur

    private:

    // méthode : pour les delete
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

    // pour la préparation
    int m_nbLignes;

    // les options du test précédent
    unsigned int m_optPrecGr, m_optPrecTpsVb;
    int m_optPrecNbQ;

};

#endif // INSTTEST_H



