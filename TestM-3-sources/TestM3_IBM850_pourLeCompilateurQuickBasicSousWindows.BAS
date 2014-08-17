'Copyright Th‚o Zimmermann, f‚vrier 2005
'
'Contactez-moi … admin@test-pedago.fr
'
'Ce logiciel est un programme informatique servant … s'entraŒner sur
'les tables de multiplication. 
'
'Ce logiciel est r‚gi par la licence CeCILL soumise au droit fran‡ais et
'respectant les principes de diffusion des logiciels libres. Vous pouvez
'utiliser, modifier et/ou redistribuer ce programme sous les conditions
'de la licence CeCILL telle que diffus‚e par le CEA, le CNRS et l'INRIA 
'sur le site "http://www.cecill.info".
'
'En contrepartie de l'accessibilit‚ au code source et des droits de copie,
'de modification et de redistribution accord‚s par cette licence, il n'est
'offert aux utilisateurs qu'une garantie limit‚e.  Pour les mˆmes raisons,
'seule une responsabilit‚ restreinte pŠse sur l'auteur du programme,  le
'titulaire des droits patrimoniaux et les conc‚dants successifs.
'
'A cet ‚gard  l'attention de l'utilisateur est attir‚e sur les risques
'associ‚s au chargement,  … l'utilisation,  … la modification et/ou au
'd‚veloppement et … la reproduction du logiciel par l'utilisateur ‚tant 
'donn‚ sa sp‚cificit‚ de logiciel libre, qui peut le rendre complexe … 
'manipuler et qui le r‚serve donc … des d‚veloppeurs et des professionnels
'avertis poss‚dant  des  connaissances  informatiques approfondies.  Les
'utilisateurs sont donc invit‚s … charger  et  tester  l'ad‚quation  du
'logiciel … leurs besoins dans des conditions permettant d'assurer la
's‚curit‚ de leurs systŠmes et ou de leurs donn‚es et, plus g‚n‚ralement, 
'… l'utiliser et l'exploiter dans les mˆmes conditions de s‚curit‚. 
'
'Le fait que vous puissiez acc‚der … cet en-tˆte signifie que vous avez 
'pris connaissance de la licence CeCILL, et que vous en avez accept‚ les
'termes.


' Parm‚trages initiaux:

1       SCREEN 0: CLS
2       DIM A(150, 2), RR(150), TBLE(14)
10      CLS


' Affichage de l'‚cran d'accueil :
20      PRINT " ", , "TEST M 3.0"
22      PRINT "Programme con‡u et r‚alis‚ dans sa 1Šre version par Th‚o Zimmermann - Avril 2005"
	'PRINT "Pour plus de d‚tails et pour la documentation, voir le site internet :"
' R‚glage des options :

' Initialisation du tableau TBLE destin‚ … stocker sur quelles tables l'utilisateur
' veut s'entraŒner
25      FOR I = 0 TO 14
		TBLE(I) = 0
	NEXT

26      PRINT
	PRINT "Si tu veux t'entraŒner sur une seule table, tape son chiffre (1 … 15)"
	INPUT "Si tu veux t'entraŒner sur toutes les tables de 1 … 10, tape le chiffre 0 : ", TABLE$
	'PRINT "Tu peux aussi choisir une plage par exemple 4-6 pour t'entraŒner sur les tables"
	'PRINT "de 4 … 6 ou en entrant simplement -15 toutes les tables … partir de 3"
	'PRINT "Enfin, tu peux combiner les plages avec l'op‚rateur '+' (ex: -6+11-12)"
	'INPUT "", TABLE$
	IF (LEN(TABLE$) = 0) THEN 26
	IF (NOT (LEN(TABLE$) = 1 OR (VAL(LEFT$(TABLE$, 2)) < 16 AND VAL(LEFT$(TABLE$, 2)) > 9))) THEN 27
	NB = VAL(TABLE$)
	IF (NB = 0) THEN FOR I = 0 TO 9: TBLE(I) = -1: NEXT: GOTO 28
	IF (NB > 0 AND NB < 16) THEN TBLE(NB - 1) = -1: GOTO 28
' gestion de chaŒnes plus complexes
' ne pas oublier de commenter ces lignes
' attention gestion des nb >=10
27      IF (LEFT$(TABLE$, 1) = "-") THEN BORNEMIN = 3 ELSE BORNEMIN = VAL(LEFT$(TABLE$, 1)): TABLE$ = RIGHT$(TABLE$, LEN(TABLE$) - 1)
	NB = VAL(LEFT$(TABLE$, 1))
	IF (BORNEMIN = 1 AND NB >= 0 AND NB <= 5 AND LEFT$(TABLE$, 1) <> "-") THEN BORNEMIN = 10 + NB: TABLE$ = RIGHT$(TABLE$, LEN(TABLE$) - 1)
	IF (NOT (BORNEMIN > 0 AND BORNEMIN < 15)) THEN 25
	IF (LEFT$(TABLE$, 1) = "-") THEN TABLE$ = RIGHT$(TABLE$, LEN(TABLE$) - 1) ELSE GOTO 25
	IF (LEN(TABLE$) = 0) THEN 25
	BORNEMAX = VAL(LEFT$(TABLE$, 1))
	TABLE$ = RIGHT$(TABLE$, LEN(TABLE$) - 1)
	NB = VAL(LEFT$(TABLE$, 1))
	IF (LEN(TABLE$) > 0 AND BORNEMAX = 1 AND NB >= 0 AND NB <= 5) THEN BORNEMAX = 10 + NB: TABLE$ = RIGHT$(TABLE$, LEN(TABLE$) - 1)
	IF (NOT (BORNEMAX > BORNEMIN AND BORNEMAX < 16)) THEN 25
	FOR I = BORNEMIN TO BORNEMAX
		TBLE(I - 1) = -1
	NEXT
28      IF (LEFT$(TABLE$, 1) = "+") THEN TABLE$ = RIGHT$(TABLE$, LEN(TABLE$) - 1): GOTO 27

' NTA: nb de questions max
29      NTA = 0
	FOR I = 0 TO 14
		IF (TBLE(I) = -1) THEN NTA = NTA + 10
	NEXT
30      PRINT "Choisis le nombre de questions (1 … "; NTA; "): ";
31      INPUT "", N
32      IF (N > NTA OR N < 1) THEN 30
33      INPUT "Choisis la dur‚e maximale pour r‚pondre … chaque question (1 … 10 secondes): ", T
34      IF (T > 10 OR T < 1) THEN 33

' Fin du r‚glage des options
40      CLS
50      PRINT " ", , "TEST M 3.0"
51      PRINT

' Les tableaux sont vid‚s
52      FOR I = 1 TO N
53              RR(I) = 0
54              FOR J = 1 TO 2
55                      A(I, J) = 0
56              NEXT J
57      NEXT I

' R‚capitulatif des paramŠtres d‚finis
60      PRINT "Tu as DEUX ESSAIS et "; T; " SECONDES par essai pour r‚pondre"
70      PRINT "Le premier essai vaut 3 points, le deuxiŠme vaut 1 point"
	PRINT
72      PRINT "Tape simplement ta r‚ponse, tu n'as pas besoin de taper sur Entr‚e"
	PRINT "Par contre si tu as choisi un temps long et que tu ne veux pas attendre, tu peux"
	PRINT "toujours utiliser la touche Entr‚e pour passer … la question suivante"
	PRINT
	PRINT "Tu peux aussi utiliser la touche Retour arriŠre pour te corriger mais m‚fie-toi:"
	PRINT "si tu as choisi un temps trŠs court cela pourrait te d‚concentrer plus qu'autre"
	PRINT "chose... "; ""
	PRINT
74      PRINT "Si tu veux t'arrˆter tape sur la touche Echap"
80      PRINT "Appuie d'abord sur une touche quelconque pour d‚marrer"
82      A$ = ""

' Cette boucle permet de faire deux choses :

' 1: Attendre que l'utilisateur appuie sur une touche du clavier

' 2: D‚marrer la s‚rie al‚atoire car sinon les questions se suivent toujours dans le mˆme ordre (le hasard est initialis‚

' de cette maniŠre).
84      WHILE A$ = ""
86              A1 = INT(RND * 10)
87              A$ = INKEY$
88      WEND

' D‚finitions de quelques variables
98      SCORE = 0
99      NR = 0

' Boucle principale : c'est ici que tout le test se passe
100     FOR M = 1 TO N
108             PRINT

' Affichage du num‚ro de la question
110             PRINT "Question nø"; M

' Tirage au hasard de la question (correspondant aux paramˆtres entr‚s par l'utilisateur)
112             MM = M - 1
120             K = 1
125             A1 = INT(RND * 15)
		IF (NOT TBLE(A1) = -1) THEN 125
140             A1 = A1 + 1
150             A2 = INT(RND * 10) + 1
161             IF M = 1 THEN 167

' V‚rification que cette question n'a encore jamais ‚t‚ pos‚e
162             DEJA = 0
163             FOR I = 1 TO MM
164                     IF (A1 = A(I, 1) AND A2 = A(I, 2)) THEN DEJA = 1
165             NEXT I
166             IF DEJA = 1 THEN 125

' Et enregistrement de la question pour les v‚rifications futures
167             A(M, 1) = A1: A(M, 2) = A2

' Vidage du tampon gardant en m‚moire les touches tap‚es au clavier (accesible … l'aide d' INKEY$)
171             e$ = INKEY$
172             WHILE e$ <> ""
173                     e$ = INKEY$
174             WEND

' Affichage de la question
175             PRINT A1; " x "; A2; " = ";
176             R$ = ""

' D‚marrage de la gestion du temps (le TIMER donne un nombre en secondes)
180             TA = TIMER
190             TPS = 0

' Boucle pendant laquelle l'utilisateur entre (ou pas) sa r‚ponse
200             WHILE TPS < T

' V‚rfication du temps
201                     TB = TIMER
202                     TPS = TB - TA

' R‚cup‚ration de la plus ancienne touche tap‚e et non trait‚e
203                     C$ = INKEY$

' Si le tampon est vide on boucle de nouveau
204                     IF C$ = "" THEN 230

' Sinon on l'analyse, on l'affiche

			IF ASC(C$) = 13 THEN 235
205                     IF ASC(C$) = 27 THEN 459
206                     IF NOT (ASC(C$) = 8 AND LEN(R$) > 0) THEN 214
207                     L = LEN(R$): LL = L - 1
208                     IF L > 0 THEN R$ = LEFT$(R$, LL)
209                     LIN = CSRLIN: COL = POS(1) - 1: LOCATE LIN, COL
210                     PRINT " ": LOCATE LIN, COL
211                     GOTO 230

' et si c'est un chiffre et que le r‚sultat n'est pas encore trop long, on le raccroche … ce dernier
214                     IF (VAL(C$) = 0 AND NOT C$ = "0") THEN C$ = ""
216                     IF LEN(R$) > 2 THEN C$ = ""
218                     PRINT C$;
220                     R$ = R$ + C$
230             WEND

' Calcul du r‚sultat
235             RESUL = A1 * A2

' Si l'utilisateur a donn‚ une r‚ponse on la v‚rifie aprŠs l'avoir transform‚e en nombre (c'‚tait jusque l… une chaŒne
' de caractŠres)
250             IF R$ = "" THEN GOTO 313
280             R = VAL(R$)
300             IF R = RESUL THEN GOTO 360
310             PRINT "   FAUX": GOTO 315
313             PRINT

' Si l'utilisateur a donn‚ une r‚ponse fausse,

' Si c'est son deuxiŠme essai, on affiche le bon r‚sultat et on repose une nouvelle question
315             IF K = 2 THEN PRINT "Bon r‚sultat : "; RESUL
320             IF K > 1 THEN GOTO 400

' Sinon on lui donne une deuxiŠme chance
328             PRINT
330             PRINT "DeuxiŠme essai"
340             K = K + 1
350             GOTO 171

' Pour une bonne r‚ponse, on calcule les points et on les affiche
360             RR(M) = 1
361             NR = NR + 1
362             IF K = 1 THEN SC = 3
370             IF K = 2 THEN SC = 1
380             PRINT "   REPONSE EXACTE "; SC; " POINT(S)"

' Qu'on aditionne au score total
390             SCORE = SCORE + SC
400     NEXT M

' Fin de la boucle principale

' Vidage du tampon
402     e$ = INKEY$
404     WHILE e$ <> ""
406             e$ = INKEY$
408     WEND

' Calcul de la note sur 20
410     BAR = 3 * N
420     NOTE = INT(SCORE * 20 / BAR)

' Affichage
425     PRINT
430     PRINT "POINTS : "; SCORE; " / "; BAR
440     PRINT "NOTE : "; NOTE; " / 20"

' Commentaire si la note est bonne
450     IF NOTE >= 16 THEN PRINT "BRAVO!!!"

' Si il y a eu des erreurs, r‚capitulatif
451     IF NR < N THEN PRINT
452     IF NR < N THEN PRINT "Voici les r‚ponses que tu aurais d– trouver"
453     FOR M = 1 TO N
454             IF RR(M) = 1 THEN 458
455             RESUL = A(M, 1) * A(M, 2)
456             PRINT "Question nø"; M; " : "; A(M, 1); " x "; A(M, 2); " = "; RESUL
458     NEXT M
459     PRINT
' On demande si on recommence
460     INPUT "NOUVEAU TEST ? (O/N) ", REP$
470     IF (REP$ = "O" OR REP$ = "o") THEN GOTO 10
480     IF (REP$ = "N" OR REP$ = "n") THEN GOTO 500
490     GOTO 460

' Fin du programme
500     END

