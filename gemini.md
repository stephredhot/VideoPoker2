# 🤖 État du Projet VideoPoker2 (Gemini Log)

Ce document sert de point de référence pour le développement de l'application **VideoPoker2** (Jacks or Better 9/6 en SwiftUI pour macOS), afin de garder une trace de l'état actuel et des prochaines étapes potentielles.

## 🟢 État Actuel (Mai 2026)

L'application est **fonctionnelle, robuste et visuellement aboutie**. L'architecture est moderne (Swift 5.9+, `@Observable`, `async/await`).

### Fonctionnalités complètes :
- Moteur de poker complet (Jacks or Better).
- Détection des mains gagnantes et calcul des paiements avec une *Paytable* dynamique.
- Animations fluides pour la distribution, les défausses, les retours de cartes, et l'effet visuel spécial du "Royal Flush".
- Mode "Quitte ou Double" fonctionnel (choix Rouge/Noir), avec corrections d'animation.
- Système d'`autoHold` intelligent (incluant la détection des tirages de suites par le bas / Wheel Straights).
- Sauvegarde automatique en temps réel des crédits et de la mise via `UserDefaults` (intégrée de manière transparente dans le ViewModel).
- Système de sons complet.

### Dernières corrections apportées (Revue de Code) :
- **Mélange du Deck :** Logique encapsulée directement dans `deck.reset()`.
- **UI State (Quitte ou Double) :** L'animation de la carte fonctionne parfaitement au 2ème tour grâce à une gestion asynchrone du runloop (`Task.sleep` avant de lancer `withAnimation`). L'affichage a été réinitialisé proprement au lancement du mini-jeu.
- **Source de vérité :** Remplacement de `@AppStorage` redondant par une intégration directe de `UserDefaults` au sein du `VideoPokerViewModel`.

---

## 🚀 Prochaines Étapes / Idées d'Améliorations (À valider)

Voici quelques idées pour continuer à enrichir le projet :

### 1. Fonctionnalités "Joueur"
- **Historique & Statistiques :** Enregistrer le nombre de mains jouées, le plus gros gain, le nombre de Royal Flush obtenus, etc.
- **Paramètres :** Créer une vue pour activer/désactiver le son, ou ajuster la vitesse des animations.
- **Succès (Achievements) :** Un système de trophées locaux (ex: "Obtenir 5 Quitte ou Double d'affilée").

### 2. Visuels et Polish
- **Boutons :** Ajouter des états de "pression" plus marqués ou des effets de brillance sur les boutons "DEAL" / "DRAW".
- **Thèmes :** Permettre de changer le dos des cartes ou la couleur de la table de casino.

### 3. Architecture et Clean Code
- **Gestion des Tasks :** S'assurer que si l'utilisateur quitte l'application brutalement pendant une longue animation, les tâches asynchrones (`Task.sleep`) sont bien annulées pour éviter toute fuite ou mise à jour fantôme.
- **Modularité :** Si le code s'agrandit, séparer le moteur de règles (évaluation des mains) du `ViewModel` principal vers un `PokerEngine` dédié.

---

> **Note pour l'IA :** Lors de la prochaine interaction, utilise ce fichier pour te remettre dans le contexte de l'application et comprendre les dernières décisions architecturales prises avec le développeur.
