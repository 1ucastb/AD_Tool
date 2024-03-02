@echo off
title --- BIENVENUE DANS L'UTILITAIRE UTILISATEUR AD ---
:: fichier bat interactif creation utilisateur
:: il y a un menu principal et 3 sous menu
:: utilitaire (choix 1) vous lance l'utilitaire de creation d'user, il creera un utilisateur, son dossier r‚seau, le partagera ainsi que son script d'ouverture de session, il proposera aussi les horaires de connexion, lexpiration du compte ainsi que la creation ou le rajout a un groupe existant. 
:: sous menu et utilitaire suppression qui affiche la liste users ou groupe pour aide a la suppression
:: sous menu groupe qui vous permets de choisir si vous creer ou rajouter un utilisateur a un groupe existant
:: les choix 3,4,5,6,7 permets de faire s‚par‚ment ce que fait le choix 1. 
:: le choix 8 fait ce qu'il indique

:: Menu principal
:menuprincipal
cls
echo.
echo -----------------------------------------------------------------------
echo ------------------------ MENU UTILITAIRE AD ---------------------------
echo -----------------------------------------------------------------------
echo - 1 - Utilitaire creation d utilisateur - Le PW sera Azerty1+ et l'user devra le changer a sa premiere connexion.
echo - 2 - Utilitaire de suppression.
echo - 3 - Creer seulement un utilisateur avec Azerty1+ comme PW, l'user devra le changer a sa premiere connexion.
echo - 4 - Creer un dossier reseau pour un utilisateur, le partager et mettre en place un script d ouverture de session. 
echo - 5 - Creer un groupe ou rajouter un utilisateur a un groupe. 
echo - 6 - Definir les horaires de connexion d un utilisateur. 
echo - 7 - Definir la date d expiration de compte d un utilisateur. 
echo - 8 - Afficher la liste des utilisateurs, des dossiers partages et de les afficher dans un dossier que vous nommerez. 
echo - 9 - Quitter cet utilitaire en style.
echo -----------------------------------------------------------------------
echo -----------------------------------------------------------------------


::choix
choice /C 123456789 /M "Faites votre choix et valider avec entree"

:: rajout des errorlevels pour menu principal
IF ERRORLEVEL ==9 goto discotime
IF ERRORLEVEL ==8 goto menulist
IF ERRORLEVEL ==7 goto expiration
IF ERRORLEVEL ==6 goto horaireco
IF ERRORLEVEL ==5 goto menugroupe
IF ERRORLEVEL ==4 goto dossiercreation
IF ERRORLEVEL ==3 goto usercreation
IF ERRORLEVEL ==2 goto menu_suppression
IF ERRORLEVEL ==1 goto debutcreation


:: debut utilitaire creation utilisateur 
:debutcreation
cls
echo -----------------------------------------------------------------------
echo -----------------------------------------------------------------------
echo UTILITAIRE CREATION UTILISATEURS ACTIVE DIRECTORY  
echo MERCI DE RESPECTER LE FORMAT DEMANDE
echo -----------------------------------------------------------------------
echo -----------------------------------------------------------------------
echo.

::creation de l'identifiant et de la valeur login

echo Rentrer l'identifiant voulu pour votre utilisateur, ne pas mettre d espace et valider par entree. Ex : 20240101estluc
set /p login=

:: creation repertoire users
MD C:\UtilisateursAD\%login%

:: creation compte, partage et rajout du script connexion au lecteur reseau
NET USER %login% /ADD Azerty1+ /SCRIPTPATH:%login%.bat /LOGONPASSWORDCHG:YES
NET SHARE %login%=C:\UtilisateursAD\%login% /GRANT:%login%,FULL

:: creation du script bat dans dossier netlogon (je sais qu'il y a d'autres methode ou un seul script peut fonctionner avec tous via username par ex mais l'idee d'un script qui creer des scripts me plait beaucoup)

echo net use U: %LOGONSERVER%\%login% > C:\Windows\SYSVOL\sysvol\S6SERV01.local\scripts\%login%.bat

:: partage dossier utilisateur
NET SHARE %login%=C:\UtilisateursAD\%login% /GRANT:%login%,FULL

cls
echo. 
echo ---------------------------------------------------------------------------------------------------------
echo Utilisateur %login% cree, dossier cree et partage, script ouverture session cree et configure
echo Vous allez continuer sur l'utilitaire dans deux secondes...
echo ---------------------------------------------------------------------------------------------------------
timeout /T 3

:: definition horaires d'ouverture
cls
echo Veuillez rentrer les dates et horaire de connexion au format suivant ex: [lundi-vendredi,8am-5pm] - Rentrer ALL pour que l'user puisse se connecter a n'importe quelle heure. 

set /p horairelogin=
NET USER %login% /TIMES:%horairelogin%

:: expiration au bout d'une date souhaite

cls
echo Veuillez rentrer jusqu'a quand vous souhaitez que les identifiants soient valide avec le format suivant ex: [26/06/24] taper NEVER si vous souhaitez que les identifiants soient valide advitam. 

set /p expirationdate=
NET USER %login% /EXPIRES:%expirationdate%

::creation groupe
cls
echo Veuillez rentrer un nom de groupe SI vous souhaitez en creer, si vous ne souhaitez pas en creer, taper entrer. 

set /p nomgroupecreation=
NET GROUP %nomgroupecreation% /ADD

::rajout groupe
cls
echo Veuillez rentrer le groupe auquel vous souhaitez rajouter votre utilisateur. 

set /p nomgrouperajout=
NET GROUP %nomgrouperajout% %login% /ADD

cls
echo.
echo ---------------------------------------------------------------------------------------------------------
echo Vous avez termine la creation de l'utilisateur %login% sur le domaine %LOGONSERV%
echo Utilisateur rajout‚ au groupe %nomgrouperajout%
echo Horaire : %horairelogin%
echo Date d expiration du compte : %expirationdate%
echo Retour sur le menu principal dans 3 secondes...
echo ---------------------------------------------------------------------------------------------------------

timeout /T 3
:: retour sur le menu principal
goto menuprincipal

:: debut du menu suppression 
:: choix 1 permets d'afficher la liste des utilisateurs pour les supprimer plus facilement
:: choix 2 permets d'afficher la liste des groupes pour les supprimer plus facilement 
:menu_suppression
cls
echo.
echo -----------------------------------------------------------------
echo ---------------------  MENU SUPPRESSION -------------------------  
echo -----------------------------------------------------------------
echo - 1. Afficher la liste des utilisateurs et en supprimer un ainsi que son dossier partage.
echo - 2. Afficher la liste des groupes et supprimer un groupe.
echo - 3. Retour au menu principal
echo -----------------------------------------------------------------

:: RAJOUT DES ERRORLEVELS POUR LE MENU

choice /C 123 /M "Faites votre choix et valider avec entree"

IF ERRORLEVEL ==3 goto menuprincipal
IF ERRORLEVEL ==2 goto suppression_groupe
IF ERRORLEVEL ==1 goto suppression_utilisateur


::sous menu delete user
:suppression_utilisateur
cls
::affichage des utilisateurs
NET USER
echo Veuillez rentrer le nom de l utilisateur que vous souhaitez supprimer, son dossier reseau sera aussi supprime.
set /p nomuserdelete=
NET USER %nomuserdelete% /DELETE
DEL C:\UtilisateursAD\%nomuserdelete% /Q

cls
echo ---------------------------------------------------------------------------------------------------------
echo Vous avez supprime l'utilisateur %nomuserdelete% ainsi que son dossier reseau, retour sur le menu suppression dans 3 secondes...
echo ---------------------------------------------------------------------------------------------------------

timeout /T 3

goto :menu_suppression

::sous menu delete groupe
:suppression_groupe
cls
::affichage des utilisateurs
NET GROUP
echo Veuillez rentrer le nom du groupe que vous souhaitez supprimer. 
set /p groupdelete=
NET GROUP %groupdelete% /DELETE

cls
echo ----------------------------------------------------------------------------------------------------------
echo Vous avez supprime le groupe %groupdelete%, retour sur le menu suppression dans 3 secondes...
echo ----------------------------------------------------------------------------------------------------------

timeout /T 3

goto :menu_suppression

:: sous menu 3 - ne gere que la creation d'un utilisateur ainsi que la creation de son script d'ouverture de session
:usercreation
cls
echo Rentrer l'identifiant voulu pour votre utilisateur, ne pas mettre d espace. Ex : 20240101estluc
set /p login=
NET USER %login% /ADD Azerty1+ /SCRIPT:%login%.bat /LOGONPASSWORDCHG:YES
echo net use U: %LOGONSERVER%\%login% > C:\Windows\SYSVOL\sysvol\S6SERV01.local\scripts\%login%.bat

cls
echo ----------------------------------------------------------------------------------------------------------
echo Utilisateur %login% cree, script d'ouverture session cree, retour sur le menu principal dans 3 secondes...
echo ----------------------------------------------------------------------------------------------------------

timeout /T 3
goto :menuprincipal

:dossiercreation
:: sous menu 4 - creation dossier reseau, partage et co au dossier pour un utilisateur 
cls
echo Rentrer l'identifiant de votre utilisateur pour lequel vous souhaitez creer un dossier et le partager. 
set /p login=
MD C:\UtilisateursAD\%login%
NET SHARE %login%=C:\UtilisateursAD\%login% /GRANT:%login%,FULL

cls
echo ----------------------------------------------------------------------------------------------------------
echo Dossier pour %login% cree et partage, retour sur le menu principal dans 3 secondes...
echo ----------------------------------------------------------------------------------------------------------

timeout /T 3
goto :menuprincipal

:: sous menu 5
:: sous menu creation groupe
:: choix 1 creation dun groupe
:: choix 2 montre les groupes existant et permets de rajouter un utilisateur 
:menugroupe

cls
echo.
echo -----------------------------------------------------------------
echo -----------------------  MENU GROUPE ----------------------------  
echo -----------------------------------------------------------------
echo - 1. Creation d un groupe
echo - 2. Permets de rajouter un utilisateur a un groupe deja existant.
echo - 3. Retour au menu principal
echo -----------------------------------------------------------------

:: RAJOUT DES ERRORLEVELS POUR LE MENU

choice /C 123 /M "Faites votre choix et valider avec entree"

IF ERRORLEVEL ==3 goto menuprincipal
IF ERRORLEVEL ==2 goto rajoututilisateur
IF ERRORLEVEL ==1 goto creationgroupe


:creationgroupe
cls
echo Veuillez rentrer le nom du groupe que vous souhaitez cree. 
set /p nomgroupecreation=
NET GROUP %nomgroupecreation% /ADD

cls
echo ----------------------------------------------------------------------------------------------------------
echo ----------------------------------------------------------------------------------------------------------

timeout /T 3

goto :menugroupe

::rajout utilisateur a un groupe, affiche les groupes deja existant. 
:rajoututilisateur
cls
:: show group
net group
echo Veuillez rentrer l'utilisateur, valider avec entree PUIS rentrer le nom du groupe auquel vous souhaitez rajouter votre utilisateur. 
set /p nomuserajout=
set /p nomgrouperajout=
NET GROUP %nomgrouperajout% %nomuserajout% /ADD

cls
echo ----------------------------------------------------------------------------------------------------------
echo Utilisateur %nomuserajout% rajoute au groupe %nomgrouperajout%. Retour sur le menu groupe dans 2 secondes...
echo ----------------------------------------------------------------------------------------------------------
timeout /T 3

goto :menugroupe

:: sous menu 6
:: definition horaires d'ouverture
:horaireco

cls
echo Veuillez rentrer le nom de votre utilisateur, valider avec entree PUIS les dates et horaire de connexion souhaites au format suivant ex: [lundi-vendredi,8am-5pm] - Rentrer ALL pour que l'user puisse se connecter a n'importe quelle heure.
set /p userco=
set /p horairelogin=
NET USER %userco% /TIMES:%horairelogin%

cls
echo ----------------------------------------------------------------------------------------------------------
echo Utilisateur %userco% a desormais les horaires de connexion %horairelogin%. Retour sur le menu principal dans 2 secondes...
echo ----------------------------------------------------------------------------------------------------------
timeout /T 3

goto :menuprincipal

:: sous menu 7 
:: mis en place de l'expiration
:expiration

cls
echo Veuillez rentrer le nom de votre utilisateur, valider avec entree PUIS rentrer la date limite pour la validite des identifiants avec le format suivant ex: [26/06/24] taper NEVER si vous souhaitez que les identifiants soient valide advitam. 
set /p userexpiration=
set /p expirationdate=
NET USER %userexpiration% /EXPIRES:%expirationdate%

cls
echo ----------------------------------------------------------------------------------------------------------
echo Le compte de %userexpiration% expirera a la date : %expirationdate%. Retour sur le menu principal dans 2 secondes...
echo ----------------------------------------------------------------------------------------------------------
timeout /T 3

goto :menuprincipal

:: sous menu 8 - permets d'afficher les users/groupes et dossiers partag‚s et les affiches dans un dossier choisis.
:: menu list.txt
:menulist
cls
echo Veuillez rentrer le nom du fichier que vous souhaitez creer pour afficher la liste des utilisateurs, des groupes et des dossiers partages le fichier  sera dans la racine C: en extension .txt  
set /p nomdossier=
net user > C:\%nomdossier%.txt
net group >> C:\%nomdossier%.txt
net share >> C:\%nomdossier%.txt

cls
echo ----------------------------------------------------------------------------------------------------------
echo Fichier C:\%nomdossier%.txt cree. Appuyer sur entree pour revenir au menu principal. 
echo ----------------------------------------------------------------------------------------------------------
pause

goto :menuprincipal

:discotime
::sous menu DISCO, permets de quitter le menu de maniere festive apres des taches effectuees avec brio. 
:disco
color 01
title "***"
timeout /T 0
color 12
cls
title "*** I"
timeout /T 0
color 21
cls
title "*** IT
timeout /T 0
color 32
cls
title "*** ITS"
timeout /T 0
color 42
cls
title "*** ITS D"
timeout /T 0
color 52
cls
title "*** ITS DI"
timeout /T 0
color 62
cls
title "*** ITS DIS"
timeout /T 0
color 72
cls
title "*** ITS DISC"
timeout /T 0
color 82
cls
title "*** ITS DISCO"
timeout /T 0
color 92
cls
title "*** ITS DISCO T"
timeout /T 0
color A2
cls
title "*** ITS DISCO TI"
timeout /T 0
color B2
cls
title "*** ITS DISCO TIM"
timeout /T 0
color C2
cls
title "*** ITS DISCO TIME"
timeout /T 0
color D2
cls
title "*** ITS DISCO TIME !"
timeout /T 0
color E2
cls
title "*** ITS DISCO TIME ! ***"
timeout /T 0
color 0F
cls
title "*** ITS DISCO TIME ! ***"

echo *** ITS DISCO TIME ! Merci d'avoir utilise cet utilitaire :) ***
echo *** ITS DISCO TIME ! Merci d'avoir utilise cet utilitaire :) ***
echo *** ITS DISCO TIME ! Merci d'avoir utilise cet utilitaire :) ***


timeout /T 3
exit
