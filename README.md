# vget - Universal Media Hub CLI

> Hub multimédia universel, modulaire et ultra-performant pour votre terminal (Linux, macOS et Windows).

```text
vget v1.0.0 · universal media cli
```

[![Bash](https://img.shields.io/badge/Language-Bash%204%2B-green.svg)](https://www.gnu.org/software/bash/)
[![ShellCheck](https://img.shields.io/badge/ShellCheck-Passing%20(0%20warnings)-brightgreen.svg)](https://www.shellcheck.net/)
[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20macOS%20%7C%20Windows-blue.svg)](https://kernel.org)

---

## Fonctionnalités Principales

1. **Téléchargement Multi-Résolutions** :
   * Vidéos en `1080p` (défaut), `720p`, `480p`, `360p`, `240p`, `144p`, `4k` ou `best` avec fusion audio/vidéo propre.
2. **Extraction Audio Haute Définition** :
   * Extraction directe en `mp3` (320kbps), `flac`, `m4a` ou `wav` avec injection des tags ID3 et de la miniature/jaquette.
3. **Streaming Direct sans Enregistrement** :
   * Lecture immédiate des flux via `mpv` sans monopoliser d'espace disque (`vget <url> -p`).
4. **Moteur de Recherche Intégré** :
   * Cherchez des vidéos directement dans votre shell (`vget -s "recherche"`) et choisissez l'action souhaitée.
5. **Mode Interactif Telescope (Fzf / Neovim)** :
   * Lancez simplement `vget` sans argument pour une navigation dynamique fléchée avec prévisualisation technique en direct.
6. **Découpage à la Volée (`--trim`)** :
   * Récupérez uniquement un extrait d'une vidéo (`--trim 01:20 03:45`) sans télécharger tout le fichier.
7. **SponsorBlock Automatique (`--sponsorblock`)** :
   * Supprimez les sponsors, intros et coupures publicitaires automatiquement.
8. **Incrustation de Sous-Titres (`--sub`)** :
   * Téléchargez et intégrez les sous-titres (`--sub fr,en`).
9. **Téléchargement par Lots (`-b, --batch`)** :
   * Traitez une liste d'URLs contenue dans un fichier texte.
10. **Détection Presse-Papier Universelle (`-c, --clipboard`)** :
    * Détecte automatiquement l'URL présente dans votre presse-papier (Wayland, X11, macOS, Windows `/dev/clipboard` et WSL).
11. **Générateur de GIFs Animés (`--gif`)** :
    * Créez un GIF optimisé à partir d'un extrait (`--trim 01:10 01:15 --gif`).
12. **Normalisation Sonore (`--loudnorm`)** :
    * Normalisation du volume audio selon le standard EBU R128.
13. **Historique des Téléchargements (`--history`)** :
    * Consultez vos téléchargements passés dans un tableau stylisé.
14. **Notifications Bureau Natives Multi-OS** :
    * Notifications via `notify-send` (Linux), `osascript` (macOS), ou PowerShell (Windows).
15. **Accélération Multi-Connexions (`--fast, --aria2`)** :
    * Découpe le flux en 16 connexions TCP parallèles via `aria2c` (3x à 10x plus rapide).
16. **Économie de Données Intelligente (`--efficient`)** :
    * Priorise les codecs ultra-efficaces (AV1 / VP9) pour économiser 40% de données à qualité visuelle identique.
17. **Déduplication Automatique (`--archive`)** :
    * Évite de re-télécharger des fichiers déjà acquis dans vos playlists.
18. **Mode Audio Strict Zéro-Gaspillage** :
    * En mode audio (`-a`), télécharge exclusivement la piste sonore sans jamais consommer un seul octet de vidéo.

---

## Installation Multi-Plateforme

### 🐧 Linux & 🍏 macOS (Terminal / Zsh / Bash)

Initialisez `vget` dans votre `PATH` global :

```bash
./bin/vget init
```
*(ou `./install.sh`)*

Sous **macOS**, assurez-vous d'avoir Homebrew installé (`brew install bash yt-dlp ffmpeg fzf`).
L'installateur configure automatiquement :
- L'exécutable dans `~/.local/bin/vget`.
- Les bibliothèques dans `~/.local/share/vget/lib/`.
- L'autocomplétion multi-shells : **Bash**, **Zsh** (`_vget`), et **Fish** (`vget.fish`).
- Les variables d'environnement dans `~/.bashrc`, `~/.zshrc` et `~/.bash_profile`.

---

### 🪟 Windows (PowerShell / Windows Terminal / CMD)

`vget` fournit des wrappers natifs pour être exécuté directement depuis **PowerShell** ou **CMD** :

1. **Prérequis** : Avoir installé **Git for Windows** (qui fournit Git Bash 5+) et les outils multimédias :
   ```powershell
   winget install Git.Git yt-dlp Gyan.FFmpeg junegunn.fzf mpv.mpv aria2.aria2
   ```

2. **Utilisation directe** :
   Ajoutez simplement le dossier `vget` à votre `PATH` Windows, ou utilisez :
   ```powershell
   .\vget.ps1 "https://..."
   # ou en invite de commande CMD:
   vget.cmd "https://..."
   ```

3. **Via Scoop** :
   ```powershell
   scoop install packaging/scoop/vget.json
   ```

---

## Dépendances

`vget` s'appuie sur les outils standards de l'écosystème open-source :
* **`yt-dlp`** : Moteur d'extraction et de téléchargement (requis)
* **`ffmpeg`** : Encodage et conversion des flux (requis pour audio et 1080p+)
* **`mpv`** : Lecteur multimédia (requis pour le streaming `-p`)
* **`fzf`** : Sélecteur fléché Telescope (optionnel, fallback natif pur Bash inclus)
* **`aria2c`** : Accélérateur multi-connexions (optionnel)

Vérifiez l'état de vos dépendances à tout moment :
```bash
vget --check-deps
```

---

## Exemples d'Utilisation

### Mode Interactif (Navigation Telescope)
```bash
vget
```

### Téléchargement Vidéo
```bash
# 1080p par défaut
vget "https://www.youtube.com/watch?v=..."

# En 720p ou 4K avec accélérateur aria2c
vget "https://www.youtube.com/watch?v=..." -v 720p --fast

# Avec suppression des sponsors et sous-titres français
vget "https://www.youtube.com/watch?v=..." --sponsorblock --sub fr
```

### Extraction Audio (MP3 / FLAC)
```bash
# Extraction MP3 320kbps avec jaquette intégrée
vget "https://www.youtube.com/watch?v=..." -a

# Extraction FLAC sans perte
vget "https://www.youtube.com/watch?v=..." -a flac
```

### Découpage d'un Extrait
```bash
# Télécharger uniquement le segment de 01:15 à 02:40
vget "https://www.youtube.com/watch?v=..." --trim 01:15 02:40
```

### Streaming Direct
```bash
# Regarder sans enregistrer
vget "https://www.youtube.com/watch?v=..." -p
```

### Recherche en Ligne
```bash
vget -s "musique lofi"
```

---

## Architecture du Projet

```text
vget/
├── bin/
│   └── vget              # Point d'entrée principal Bash
├── lib/
│   ├── config.sh         # Détection de l'OS & répertoires de sortie
│   ├── ui.sh             # Couleurs TrueColor, bannières et cartes
│   ├── deps.sh           # Détection cross-platform des paquets
│   ├── downloader.sh     # Moteur de téléchargement & options de flux
│   ├── player.sh         # Streaming direct mpv
│   ├── search.sh         # Recherche en ligne multi-plateformes
│   ├── preview.sh        # Volet de prévisualisation Telescope
│   ├── picker.sh         # Sélecteur pur Bash avec flèches
│   ├── interactive_menu.sh # Sélecteurs Telescope fzf
│   ├── interactive.sh    # Orchestration du mode interactif
│   ├── clipboard.sh      # Presse-papier multi-OS
│   ├── notify.sh         # Notifications bureau natives
│   ├── gif.sh            # Convertisseur GIF animé deux passes
│   ├── history.sh        # Registre des téléchargements
│   └── updater.sh        # Mises à jour vget & yt-dlp
├── completions/
│   ├── vget.bash         # Autocomplétion Bash
│   ├── _vget             # Autocomplétion Zsh
│   └── vget.fish         # Autocomplétion Fish
├── packaging/
│   ├── homebrew/vget.rb  # Formule Homebrew (macOS / Linux)
│   └── scoop/vget.json   # Manifeste Scoop (Windows)
├── vget.cmd              # Wrapper natif Windows CMD
├── vget.ps1              # Wrapper natif Windows PowerShell
├── install.sh            # Installateur autonome
└── tests/
    └── run_tests.sh      # Suite de tests & validation ShellCheck
```
