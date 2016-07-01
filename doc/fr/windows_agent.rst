====================================
Guide pour l'agent Windows NSClient+
====================================

Généralités
-----------

NSClient++ est un agent de supervision gratuit disponible sur le site web suivant : http://www.nsclient.org.
Ce projet consiste à réaliser un paquet de NSClient++ afin de permettre une meilleure utilisation sur des plate-formes Microsoft Windows avec les sondes fournies par Centreon.

.. note::
    La version de NSClient++ utilisée est la version 0.5.0.x. L'archive de cette version est incluse dans notre propre archive utilisée pour la construction des paquets.

Le principe est de compiler les sondes Perl disponibles dans le projet Centreon Plugins (https://github.com/centreon/centreon-plugins) et configurer NSClient++ pour les exécuter sur le serveur Windows cible.
Vous devez installer le Plugin Pack correspondant dans Centreon pour bénéficier des commandes compatibles pour communiquer avec NSClient++.

Pour installer NSClient++ sur vos serveurs Windows vous avez deux possibilités :

  * Installer l'exécutable fourni par Centreon : C'est un installeur NSClient++ contenant une commande Perl compilée incluant toutes les sondes disponibles pour Windows.
  * Construire votre propre exécutable NSClient++ : C'est un processus plus manuel qui vous autorise à choisir quelles sondes vous souhaitez embarquer dans l'archive.

La méthodologie pour les deux possibilités sont décrites ci-dessous.

Noter que dans tous les cas, NSClient++ est fourni de base avec une configuration par défaut fonctionnelle.

.. warning::
    Il est important que la valeur de l'option "payload length" corresponde absolument à la valeur utilisée par la sonde Centreon (check_centreon_nrpe), autrement la communication ne fonctionnera. Par défaut, toutes les requêtes NRPE doivent utiliser une valeur de 8192 afin d'éviter les problèmes de "long output"

Installation de l'exécutable fourni par Centreon
------------------------------------------------

Cette méthode est la plus simple à mettre oeuvre pour installer NSClient++ sur vos servers. NSClient++ est configuré pour fonctionner par défaut avec toutes les sondes Perls compilées sous la forme d'un binaire unique nommé "centreon_plugins.exe". Ce binaire contient toutes les fonctionnalités existantes au moment de sa génération. Actuellement les vérifications pour Active Directory et IIS sont incluses.

Le seul choix réside dans l'architecture adéquate (32bits ou 64bits) pour l'archive avant de l'installer sur votre serveur.

.. note::
    Cet agent fait partie de l'offre Centreon EMS ou s'une souscription Centreon IMP. Vous pouvez contacter Centreon pour obtenir plus d'informations.

Construction d'un exécutable personnalisé
-----------------------------------------

Cette méthode est vraiment utile si vous souhaitez compiler votre propre "centreon_plugins.exe" qui contiendra seulement les fonctionnalités dont vous avez besoin.
Premièrement vous devez compiler le binaire nommé "centreon_plugins.exe" avec les sondes voulues.
Puis vous devez construire l'archive NSClient++ qui incluera ce binaire.

.. note::
    Les outils nécessaires pour générer votre propre archive font partie de l'offre Centreon EMS ou s'une souscription Centreon IMP. Vous pouvez contacter Centreon pour obtenir plus d'informations

Génération de la sonde
======================

Pré-requis
**********

Premièrement, vous avez besoin de deux serveurs Windows Server >= 2008 : 32 bits et 64 bits.
Les logiciels suivants sont requis :

  * Strawberry Perl 5.18.2.1 (Téléchargeable sur http://strawberryperl.com/)
  * Trunk du dépôt centreon-plugins (git clone https://github.com/centreon/centreon-plugins.git)

La procédure suivante doit être réalisée sur les deux architecture : 32 bits et 64 bits.
Si vous ne possédez pas de serveur Windows 32 bits, il existe une procédure pour compiler un exécutable 32 bits sur un serveur 64 bits.

Installation
************

Les pré-requis doivent être installées avant de continuer l'installation.
Une fois tous les pré-requis correctement installés, installer le module CPAN "PAR::Packer" (remplacer <PERL_INSTALL_DIR>)::

  cmd> <PERL_INSTALL_DIR>\perl\bin\cpan.bat
  cpan> install PAR::Packer

L'installation du module CPAN peut prendre plusieurs minutes.

Dans le dossier parent contenant le répertoire "centreon-plugins", créer un fichier "build.bat" (remplacer <PERL_INSTALL_DIR>)::

  chdir /d %~dp0
  set PAR_VERBATIM=1
  <PERL_INSTALL_DIR>\perl\site\bin\pp --lib=centreon-plugins\ -o centreon_plugins.exe centreon-plugins\centreon_plugins.pl ^
  --link=<PERL_INSTALL_DIR>\c\bin\libxml2-2__.dll ^
  --link=<PERL_INSTALL_DIR>\c\bin\libiconv-2__.dll ^
  --link=<PERL_INSTALL_DIR>\c\bin\liblzma-5__.dll ^
  --link=<PERL_INSTALL_DIR>\c\bin\zlib1__.dll ^
  -M centreon::plugins::script ^
  -M apps::activedirectory::local::plugin ^
  -M apps::activedirectory::local::mode::dcdiag ^
  -M apps::activedirectory::local::mode::netdom ^
  -M apps::iis::local::plugin ^
  -M apps::iis::local::mode::listapplicationpools ^
  -M apps::iis::local::mode::applicationpoolstate ^
  -M apps::iis::local::mode::listsites ^
  -M apps::iis::local::mode::webservicestatistics ^
  -M apps::exchange::2010::local::plugin ^
  -M apps::exchange::2010::local::mode::activesyncmailbox ^
  -M apps::exchange::2010::local::mode::databases ^
  -M apps::exchange::2010::local::mode::listdatabases ^
  -M apps::exchange::2010::local::mode::imapmailbox ^
  -M apps::exchange::2010::local::mode::mapimailbox ^
  -M apps::exchange::2010::local::mode::outlookwebservices ^
  -M apps::exchange::2010::local::mode::owamailbox ^
  -M apps::exchange::2010::local::mode::queues ^
  -M apps::exchange::2010::local::mode::replicationhealth ^
  -M apps::exchange::2010::local::mode::services ^
  -M centreon::common::powershell::exchange::2010::powershell ^
  -M os::windows::local::plugin ^
  -M os::windows::local::mode::ntp ^
  --verbose
  
  pause

Ajouter les sondes et les modes dont vous avez besoin dans "centreon_plugins.exe" (dans l'exemple les sondes pour IIS et ActiveDirectory sont ajoutées).
Pour terminer, exécuter le fichier "buid.bat" pour créer l'exécutable "centreon_plugins.exe".

32 bits sur un serveur 64 bits
******************************

Installer Strawberry Perl 5.18.2.1 32 bits. Une fois l'installation terminée, installer le module CPAN "PAR::Packer" (remplacer <PERL_INSTALL_DIR_32BITS>)::

  cmd> PATH = <PERL_INSTALL_DIR_32BITS>\c\bin;<PERL_INSTALL_DIR_32BITS>\perl\bin;C:\Windows\System32
  cmd> <PERL_INSTALL_DIR_32BITS>\perl\bin\cpan.bat
  cpan> install PAR::Packer

L'installation du module CPAN peut prendre plusieurs minutes.

Dans le dossier parent contenant le répertoire "centreon-plugins", créer un fichier "build.bat" (remplacer <PERL_INSTALL_DIR_32BITS>)::

  chdir /d %~dp0
  set PAR_VERBATIM=1
  PATH = <PERL_INSTALL_DIR_32BITS>\c\bin;<PERL_INSTALL_DIR_32BITS>\perl\bin;C:\Windows\System32
  <PERL_INSTALL_DIR_32BITS>\perl\site\bin\pp --lib=centreon-plugins\ -o centreon_plugins.exe centreon-plugins\centreon_plugins.pl ^
  --link=<PERL_INSTALL_DIR>\c\bin\libxml2-2__.dll ^
  --link=<PERL_INSTALL_DIR>\c\bin\libiconv-2__.dll ^
  --link=<PERL_INSTALL_DIR>\c\bin\liblzma-5__.dll ^
  --link=<PERL_INSTALL_DIR>\c\bin\zlib1__.dll ^
  -M centreon::plugins::script ^
  -M apps::activedirectory::local::plugin ^
  -M apps::activedirectory::local::mode::dcdiag ^
  -M apps::activedirectory::local::mode::netdom ^
  -M apps::iis::local::plugin ^
  -M apps::iis::local::mode::listapplicationpools ^
  -M apps::iis::local::mode::applicationpoolstate ^
  -M apps::iis::local::mode::listsites ^
  -M apps::iis::local::mode::webservicestatistics ^
  -M apps::exchange::2010::local::plugin ^
  -M apps::exchange::2010::local::mode::activesyncmailbox ^
  -M apps::exchange::2010::local::mode::databases ^
  -M apps::exchange::2010::local::mode::listdatabases ^
  -M apps::exchange::2010::local::mode::imapmailbox ^
  -M apps::exchange::2010::local::mode::mapimailbox ^
  -M apps::exchange::2010::local::mode::outlookwebservices ^
  -M apps::exchange::2010::local::mode::owamailbox ^
  -M apps::exchange::2010::local::mode::queues ^
  -M apps::exchange::2010::local::mode::replicationhealth ^
  -M apps::exchange::2010::local::mode::services ^
  -M centreon::common::powershell::exchange::2010::powershell ^
  -M os::windows::local::plugin ^
  -M os::windows::local::mode::ntp ^
  --verbose
  
  pause

Ajouter les sondes et les modes dont vous avez besoin dans "centreon_plugins.exe" (dans l'exemple les sondes pour IIS et ActiveDirectory sont ajoutées).
Pour terminer, exécuter le fichier "buid.bat" pour créer l'exécutable "centreon_plugins.exe".

Génération de l'agent NRPE
==========================

Pré-requis
**********

Vous avez besoin d'un serveur Windows Server => 2008 (32 bits ou 64 bits).

Installation
************

Les pré-requis doivent être installées avant de continuer l'installation.
Une fois tous les pré-requis correctement installés, extrayer le paquet "centreon-nsclient-builder".
Voici la liste des répertoires et des fichiers :

  * bin\ : les binaires pour générer les paquets (ne pas modifier) ;
  * nsis\ : quelques archives (non utilisés et ne pas modifier) ;
  * build\ : utilisé pour le processus de génération (ne pas modifier) ;
  * Prerequisites\ : le paquet msi NSClient++ utilisé (ne pas modifier) ;
  * resources\nsclient-043.ini : le fichier de configuration NSClient++ (peut être modifié par l'utilisateur) ;
  * scripts\(win32|x64) : script externe ajouté dans le paquet (peut être modifié par l'utilisateur) ;
  * builddef-(Win32|x64)-043.nsi : configuration nsi (ne pas modifier) ;
  * favicon_centreon.ico : icône pour le paquet (peut être modifié par l'utilisateur) ;
  * logo.bmp : image utilisé pour l'installeur intéractif ;
  * generate_package.bat : script pour générer le paquet.

Configuration
*************

En terme de configuration, l'utilisateur peut réaliser les actions suivantes :

  * Modifier le paramètre "allowed hosts" dans le fichier "resources\\nsclient-043.ini" ;
  * Remplacer l'exécutable "centreon_plugins.exe" dans les répertoires "scripts\\win32\\centreon" et "scripts\\x64\\centreon" ;
  * Remplacer le fichier "logo.bmp" ;
  * Exécuter le fichier "generate_package.bat" pour générer les nouveaux paquets "centreon-nsclient-043-1.0-1-Win32.exe" et "centreon-nsclient-043-1.0-1-x64.exe".

Toute autre modification n'engage que vous.

Installation des paquets
========================

Vous pouvez maintenant installer NSClient++ en utilisant le paquet généré lors des étapes précédentes.
Si une version précédente de NSClient++ est installée sur votre serveur, vous devez d'abord la désinstaller avant d'installer la nouvelle version.

Pour installer le paquet, les options suivants sont disponibles :

  * /S : installation silencieuse ;
  * /nouninstall : ne pas désinstaller le paquet courant s'il est déjà installé.

Une fois installé, le paquet apparaît de cette manière :

.. image:: _static/nsclient-installed.png
   :align: center

Quand NSClient++ est installé sur le serveur cible Windows, vous pouvez vérifier que la sonde est capable de le joindre depuis le serveur Centreon avec::

  /usr/lib64/nagios/plugins/check_centreon_nrpe  -H <adresse IP windows> -p 5666 -m 8192
  I (0.4.3.143 2015-04-29) seem to be doing fine...

