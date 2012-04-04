# Lottery App

[Source|http://www.web-tambouille.fr/2012/03/24/un-pass-3-jours-pour-devoxx-france-a-gagner-sur-web-tambouille-concours.html]

Devoxx France approche à grands pas, et tout le monde a déjà acheté sa place... quoi, pas vous ? 
Pas de panique si vous n'avez pas encore votre place car Web Tambouille va vous permettre de gagner un pass 3 jours pour Devoxx France ! Elle est pas belle la vie ? 

Comment faire ? C'est très simple : il vous suffit de créer une petite loterie en Node !
Le vainqueur de ce concours se verra remettre ce précieux sésame. Let's Node !

## Concours

Les fonctionnalités de base de cette loterie, vous pouvez imaginer la roue du Millionnaire :
- à la connexion, une page nous demande un pseudo, **2 utilisateurs connectés ne peuvent pas avoir le même**
- après validation, nous sommes redirigés vers la page de loterie qui contient :
  - **tous les noms des utilisateurs**
  - **un champ de saisie pour le numéro que l'on souhaite jouer (entre 1 et 100)**
  - **un pavé qui contient le numéro sorti**
  - **un pavé avec le nom des gagnants**
  - **un compteur avant le prochain tirage**
- **un tirage a lieu toutes les 15 secondes** (le serveur se charge d'envoyer le résultat à tous les utilisateurs)
- **le champ de saisie n'est plus accessible 2 secondes avant tirage et redevient disponible 2 secondes après**

Si vous voulez aller plus loin (cela pourra compter en cas d'égalité) :
- **2 utilisateurs ne peuvent pas jouer le même numéro**, vous pourriez **afficher une grille** où toutes les cases sont cochables et dès que l'on doit choisir son numéro ils se grisent selon le choix des autres utilisateurs (web sockets à la rescousse !)
- **pas plus de 100 utilisateurs par partie**
- **vous pouvez afficher une vraie roulette** (un peu comme celle citée en bas de l'article) attention car elle doit se comporter de la même manière chez tous les joueurs et bien sûr sortir le même numéro gagnant 
- Et bien sûr vous pouvez aller plus loin si vous le souhaitez, **le style de votre loterie rentrera aussi en compte** (couleur, image, effet...).

## Notation et résultats

Le choix se fera sur :
- application fonctionnelle respectant les règles (pseudo unique, décompte, délais des tirages...)
- qualité du code
- style de la page (effets, roulette...), lachez-vous avec CSS3 !
- fonctionnalités optionnelles (en cas d'égalité)

Date limite de dépôt : le mercredi 04 avril minuit (pour les plus courageux).

