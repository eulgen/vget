# vget - Universal Media Hub CLI 🎬 🎵

> L'équivalent moderne, modulaire et ultra-performant de **VidMate** directement dans votre terminal Linux / macOS.

```text
  __   __ __ _   ___  _   
  \ \ / // _` | / _ \| |_ 
   \ V /| (_| ||  __/|  _|
    \_/  \__, | \___| \__|
         |___/            
  Universal Video & Audio CLI Hub (v1.0.0)
```

[![Bash](https://img.shields.io/badge/Language-Bash%204%2B-green.svg)](https://www.gnu.org/software/bash/)
[![ShellCheck](https://img.shields.io/badge/ShellCheck-Passing%20(0%20warnings)-brightgreen.svg)](https://www.shellcheck.net/)
[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20macOS-blue.svg)](https://kernel.org)

---

## ✨ Fonctionnalités Principales

1. **📥 Téléchargement Multi-Résolutions** :
   * Vidéos en `1080p` (défaut), `720p`, `480p`, `360p`, `240p`, `144p`, `4k` ou `best` avec fusion audio/vidéo propre.
2. **🎵 Extraction Audio Haute Définition** :
   * Extraction directe en `mp3` (320kbps), `flac`, `m4a` ou `wav` avec injection des tags ID3 et de la miniature/jaquette.
3. **📺 Streaming Direct sans Enregistrement** :
   * Lecture immédiate des flux via `mpv` sans monopoliser d'espace disque (`vget <url> -p`).
4. **🔍 Moteur de Recherche Intégré** :
   * Cherchez des vidéos directement dans votre shell (`vget -s "recherche"`) et choisissez l'action souhaitée.
5. **🎛️ Mode Interactif Guidé (TUI)** :
   * Lancez simplement `vget` sans argument pour un menu pas-à-pas ergonomique (support `fzf` avec repli automatique).
6. **✂️ Découpage à la Volée (`--trim`)** :
   * Récupérez uniquement un extrait d'une vidéo (`--trim 01:20 03:45`) sans télécharger tout le fichier.
7. **🛡️ SponsorBlock Automatique (`--sponsorblock`)** :
   * Supprimez les sponsors, intros et coupures publicitaires automatiquement.
8. **💬 Incrustation de Sous-Titres (`--sub`)** :
   * Téléchargez et intégrez les sous-titres (`--sub fr,en`).
9. **📦 Téléchargement par Lots (`-b, --batch`)** :
   * Traitez une liste d'URLs contenue dans un fichier texte.

---

## 🚀 Installation Rapide

Pour initialiser et ajouter `vget` à votre **PATH global** de manière permanente :

```bash
./bin/vget init
```
*(ou `./install.sh`)*

Cette commande effectue automatiquement :
1. Le déploiement du binaire dans `~/.local/bin/vget`.
2. La copie des bibliothèques dans `~/.local/share/vget/lib/`.
3. L'installation de l'autocomplétion Bash dans `~/.local/share/bash-completion/completions/vget`.
4. L'ajout automatique de `~/.local/bin` dans votre `~/.bashrc` (et `~/.zshrc`).

Après l'exécution, rechargez votre shell :
```bash
source ~/.bashrc
```
Vous pouvez désormais taper `vget` depuis **n'importe quel répertoire** !

---

## 🛠️ Dépendances

`vget` s'appuie sur les outils standards de l'écosystème open-source :
* **`yt-dlp`** : Moteur de téléchargement (requis)
* **`ffmpeg`** : Encodage et fusion des flux (requis pour audio et 1080p+)
* **`mpv`** : Lecteur multimédia (requis pour le streaming `-p`)
* **`fzf`** : Recherche fuzzy interactive (optionnel, recommandé)

Vérifiez l'état de vos dépendances à tout moment :
```bash
vget --check-deps
```

---

## 📖 Exemples d'Utilisation

### Mode Interactif
```bash
vget
```

### Téléchargement Vidéo
```bash
# 1080p par défaut
vget "https://www.youtube.com/watch?v=..."

# En 720p ou 4K
vget "https://www.youtube.com/watch?v=..." -v 720p
vget "https://www.youtube.com/watch?v=..." -v 4k

# Avec suppression des sponsors et sous-titres français
vget "https://www.youtube.com/watch?v=..." --sponsorblock --sub fr
```

### Extraction Audio (MP3)
```bash
# Extraction MP3 haute qualité avec jaquette
vget "https://www.youtube.com/watch?v=..." -a

# Extraction au format FLAC sans perte
vget "https://www.youtube.com/watch?v=..." -a flac
```

### Découpage d'un Extrait
```bash
# Télécharger uniquement le segment de 01:15 à 02:40
vget "https://www.youtube.com/watch?v=..." --trim 01:15 02:40
```

### Streaming Direct
```bash
# Regarder sans télécharger
vget "https://www.youtube.com/watch?v=..." -p

# Écouter le son uniquement en streaming
vget "https://www.youtube.com/watch?v=..." -p -a
```

### Recherche
```bash
vget -s "lofi hip hop live"
```

---

## 🏛️ Architecture du Projet

```text
vget/
├── bin/
│   └── vget              # Point d'entrée & parsing des drapeaux CLI
├── lib/
│   ├── config.sh         # Variables d'environnement & dossiers de sortie
│   ├── ui.sh             # Couleurs ANSI, spinner, bannières
│   ├── deps.sh           # Détection contextuelle des dépendances
│   ├── downloader.sh     # Orchestration yt-dlp, trim, audio, sous-titres
│   ├── player.sh         # Lecteur et streaming direct mpv
│   ├── search.sh         # Recherche en ligne multi-plateformes
│   ├── interactive.sh    # Menu TUI pas-à-pas (fzf / Bash)
│   └── updater.sh        # Gestionnaire de mises à jour
├── completions/
│   └── vget.bash         # Autocomplétion intelligente Bash
├── install.sh            # Installateur dans ~/.local/bin
└── tests/
    └── run_tests.sh      # Suite de tests et contrôle qualité ShellCheck
```
