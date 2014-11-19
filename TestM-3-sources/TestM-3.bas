'Copyright Théo Zimmermann, février 2005
'
'Distribué sous licence GNU GPL v3


' Parmétrages initiaux:

1       SCREEN 0: CLS
2       DIM A(150, 2), RR(150), TBLE(14)
10      CLS


' Affichage de l'écran d'accueil :
20      PRINT " ", , "TEST M 3.0"
22      PRINT "Programme conçu et réalisé dans sa 1ère version par Théo Zimmerman - Janvier-"
	PRINT "Février 2005. Pour plus de détails et pour la documentation, voir le site"
	'2ème version : Avril 2005
	'3ème version : Janvier 2008
	PRINT "internet : www.theozimmermann.net/test-pedago"
' Réglage des options :

' Initialisation du tableau TBLE destiné à stocker sur quelles tables l'utilisateur
' veut s'entraîner
25      FOR I = 0 TO 14
		TBLE(I) = 0
	NEXT

26      PRINT
	PRINT "Si tu veux t'entraîner sur une seule table, tape son chiffre (1 à 15)"
	INPUT "Si tu veux t'entraîner sur toutes les tables de 1 à 10, tape le chiffre 0 : ", TABLE$
	'PRINT "Tu peux aussi choisir une plage par exemple 4-6 pour t'entraîner sur les tables"
	'PRINT "de 4 à 6 ou en entrant simplement -15 toutes les tables à partir de 3"
	'PRINT "Enfin, tu peux combiner les plages avec l'opérateur '+' (ex: -6+11-12)"
	'INPUT "", TABLE$
	IF (LEN(TABLE$) = 0) THEN 26
	IF (NOT (LEN(TABLE$) = 1 OR (VAL(LEFT$(TABLE$, 2)) < 16 AND VAL(LEFT$(TABLE$, 2)) > 9))) THEN 27
	NB = VAL(TABLE$)
	IF (NB = 0) THEN FOR I = 0 TO 9: TBLE(I) = -1: NEXT: GOTO 28
	IF (NB > 0 AND NB < 16) THEN TBLE(NB - 1) = -1: GOTO 28
' gestion de chaînes plus complexes
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
30      PRINT "Choisis le nombre de questions (1 à "; NTA; "): ";
31      INPUT "", N
32      IF (N > NTA OR N < 1) THEN 30
33      INPUT "Choisis la durée maximale pour répondre à chaque question (1 à 10 secondes): ", T
34      IF (T > 10 OR T < 1) THEN 33

' Fin du réglage des options
40      CLS
50      PRINT " ", , "TEST M 3.0"
51      PRINT

' Les tableaux sont vidés
52      FOR I = 1 TO N
53              RR(I) = 0
54              FOR J = 1 TO 2
55                      A(I, J) = 0
56              NEXT J
57      NEXT I

' Récapitulatif des paramètres définis
60      PRINT "Tu as DEUX ESSAIS et "; T; " SECONDES par essai pour répondre"
70      PRINT "Le premier essai vaut 3 points, le deuxième vaut 1 point"
	PRINT
72      PRINT "Tape simplement ta réponse, tu n'as pas besoin de taper sur Entrée"
	PRINT "Par contre si tu as choisi un temps long et que tu ne veux pas attendre, tu peux"
	PRINT "toujours utiliser la touche Entrée pour passer à la question suivante"
	PRINT
	PRINT "Tu peux aussi utiliser la touche Retour arrière pour te corriger mais méfie-toi:"
	PRINT "si tu as choisi un temps très court cela pourrait te déconcentrer plus qu'autre"
	PRINT "chose... "; ""
	PRINT
74      PRINT "Si tu veux t'arrêter tape sur la touche Echap"
80      PRINT "Appuie d'abord sur une touche quelconque pour démarrer"
82      A$ = ""

' Cette boucle permet de faire deux choses :

' 1: Attendre que l'utilisateur appuie sur une touche du clavier

' 2: Démarrer la série aléatoire car sinon les questions se suivent toujours dans le même ordre (le hasard est initialisé

' de cette manière).
84      WHILE A$ = ""
86              A1 = INT(RND * 10)
87              A$ = INKEY$
88      WEND

' Définitions de quelques variables
98      SCORE = 0
99      NR = 0

' Boucle principale : c'est ici que tout le test se passe
100     FOR M = 1 TO N
108             PRINT

' Affichage du numéro de la question
110             PRINT "Question n°"; M

' Tirage au hasard de la question (correspondant aux paramêtres entrés par l'utilisateur)
112             MM = M - 1
120             K = 1
125             A1 = INT(RND * 15)
		IF (NOT TBLE(A1) = -1) THEN 125
140             A1 = A1 + 1
150             A2 = INT(RND * 10) + 1
161             IF M = 1 THEN 167

' Vérification que cette question n'a encore jamais été posée
162             DEJA = 0
163             FOR I = 1 TO MM
164                     IF (A1 = A(I, 1) AND A2 = A(I, 2)) THEN DEJA = 1
165             NEXT I
166             IF DEJA = 1 THEN 125

' Et enregistrement de la question pour les vérifications futures
167             A(M, 1) = A1: A(M, 2) = A2

' Vidage du tampon gardant en mémoire les touches tapées au clavier (accesible à l'aide d' INKEY$)
171             e$ = INKEY$
172             WHILE e$ <> ""
173                     e$ = INKEY$
174             WEND

' Affichage de la question
175             PRINT A1; " x "; A2; " = ";
176             R$ = ""

' Démarrage de la gestion du temps (le TIMER donne un nombre en secondes)
180     	TA=TIMER
190     	TPS=0
195		TB=TIMER-TA
' Boucle pendant laquelle l'utilisateur entre (ou pas) sa réponse
200     	WHILE TPS<T
' Vérfication du temps
201     		TC=TIMER-TA
202     		TPS=TC-TB

' Récupération de la plus ancienne touche tapée et non traitée
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

' et si c'est un chiffre et que le résultat n'est pas encore trop long, on le raccroche à ce dernier
214                     IF (VAL(C$) = 0 AND NOT C$ = "0") THEN C$ = ""
216                     IF LEN(R$) > 2 THEN C$ = ""
218                     PRINT C$;
220                     R$ = R$ + C$
230             WEND

' Calcul du résultat
235             RESUL = A1 * A2

' Si l'utilisateur a donné une réponse on la vérifie après l'avoir transformée en nombre (c'était jusque là une chaîne
' de caractères)
250             IF R$ = "" THEN GOTO 313
280             R = VAL(R$)
300             IF R = RESUL THEN GOTO 360
310             PRINT "   FAUX": GOTO 315
313             PRINT

' Si l'utilisateur a donné une réponse fausse,

' Si c'est son deuxième essai, on affiche le bon résultat et on repose une nouvelle question
315             IF K = 2 THEN PRINT "Bon résultat : "; RESUL
320             IF K > 1 THEN GOTO 400

' Sinon on lui donne une deuxième chance
328             PRINT
330             PRINT "Deuxième essai"
340             K = K + 1
350             GOTO 171

' Pour une bonne réponse, on calcule les points et on les affiche
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

' Si il y a eu des erreurs, récapitulatif
451     IF NR < N THEN PRINT
452     IF NR < N THEN PRINT "Voici les réponses que tu aurais dû trouver"
453     FOR M = 1 TO N
454             IF RR(M) = 1 THEN 458
455             RESUL = A(M, 1) * A(M, 2)
456             PRINT "Question n°"; M; " : "; A(M, 1); " x "; A(M, 2); " = "; RESUL
458     NEXT M
459     PRINT
' On demande si on recommence
460     INPUT "NOUVEAU TEST ? (O/N) ", REP$
470     IF (REP$ = "O" OR REP$ = "o") THEN GOTO 10
480     IF (REP$ = "N" OR REP$ = "n") THEN GOTO 500
490     GOTO 460

' Fin du programme
500     END

