# 🎰 Video Poker 2 – Jacks or Better (9/6)

Un jeu de **Video Poker** complet développé en **SwiftUI** pour **macOS** avec **Xcode**.

Version moderne avec animations fluides, sons casino, doublage (Quitte ou Double) et une interface fidèle aux machines à sous de casino.

---

## ✨ Fonctionnalités

- **Jeu complet Jacks or Better 9/6**
- **Paytable dynamique** avec mise en évidence de la main gagnante
- **Animations soignées** :
  - Distribution progressive des cartes
  - Retournement 3D des cartes
  - Flip des cartes jetées
  - Effets de victoire
- **Système de HOLD** (maintien des cartes) avec boutons
- **Auto Hold** (garde automatique des paires Jacks ou mieux et mieux)
- **Doublage (Quitte ou Double)** jusqu’à 4 fois (Rouge / Noir)
- **Gestion des crédits** persistante (`@AppStorage`)
- **Sonorisation** complète (boutons, flip de cartes, gains)
- **Design casino premium** (or, noir, effets lumineux)

---

## 🎮 Comment jouer

1. Choisis ta **mise** (1 à 5 crédits) avec les boutons + / - ou **MAX**
2. Clique sur **DEAL** pour distribuer les 5 cartes
3. Sélectionne les cartes à garder en cliquant dessus ou sur les boutons **HOLD**
4. Clique sur **DRAW** pour tirer les nouvelles cartes
5. Si tu gagnes → tu peux **doubler** tes gains (jusqu’à 4 fois) ou **encaisser**
6. Amuse-toi !

---

## 📁 Structure du projet

---

## 🛠 Technologies utilisées

- **SwiftUI** (100% moderne)
- **`@Observable`** (nouveau macro Observation)
- **Async/Await** + `Task` pour les animations séquencées
- **AVFoundation** pour les sons
- **@AppStorage** pour la sauvegarde des crédits
- Design System cohérent (CasinoButtonStyle, couleurs gold, etc.)

---

## 🎨 Assets nécessaires

Ton projet utilise les images suivantes dans **Assets.xcassets** :

- Cartes : `Ah`, `As`, `Ad`, `Ac`, ..., `Th`, `Ts`, ... (format `rank + suit`)
- `back` → Dos de carte
- `fond` → Image de fond de table de casino

---

## 🚀 Installation & Lancement

1. Clone le projet ou ouvre le dossier dans **Xcode**
2. Assure-toi que tous les assets (cartes + sons) sont bien ajoutés
3. Build & Run (`Cmd + R`)
4. Profite !

Compatible **macOS** (testé sur Ventura/Sonoma/Sequoia).

---

## 🎯 Améliorations possibles (Roadmap)

- [ ] Stratégie optimale Auto Hold (perfect strategy)
- [ ] Mode plein écran + redimensionnement adaptatif
- [ ] Sauvegarde des statistiques (meilleurs gains, mains jouées…)
- [ ] Plusieurs variantes (Deuces Wild, Joker Poker…)
- [ ] Effets de particules sur les gros gains
- [ ] Support clavier (touches 1-5 pour HOLD)

---

## 👨‍💻 Auteur

**Stéphane Bertin**
Développé avec passion en avril 2026

---

⭐ N’hésite pas à mettre une étoile si ce projet t’a plu !

---

Tu peux bien sûr personnaliser certaines parties (ton nom, date, etc.).

Veux-tu que je te fasse aussi une version plus courte pour le **App Store** (description courte) ou une version en anglais ?

