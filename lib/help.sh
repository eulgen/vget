#!/usr/bin/env bash
# ==============================================================================
# vget - Help & Documentation Module
# Role: Formatage et affichage de l'aide en ligne de commande
# ==============================================================================

[[ -n "${VGET_HELP_LOADED:-}" ]] && return 0
readonly VGET_HELP_LOADED=1

show_help() {
    print_banner
    cat << "EOF"
USAGE:
  vget [OPTIONS] <URL|RECHERCHE>
  vget                                 (Lance le mode interactif)

MODES DE BASE:
  -v, --video [QUALITÉ]   Télécharger la vidéo (1080p|720p|480p|360p|240p|144p|4k)
  -a, --audio [FORMAT]    Extraire l'audio seul (mp3 | flac | m4a | wav - zéro vidéo)
  -p, --play              Lire/streamer directement sans enregistrer
  -s, --search <MOTS>     Rechercher sur YouTube / le Web
  -c, --clipboard         Récupérer automatiquement l'URL du presse-papier
  --gif                   Créer un GIF animé (combinable avec --trim)
  -i, --interactive       Forcer le menu guidé interactif

VITESSE & ÉCONOMIE DE DONNÉES:
  --fast, --aria2         Accélérateur multi-connexions aria2c (16 flux parallèles)
  --efficient             Priorité codecs haute efficacité (AV1/VP9, -40% de données)
  --archive               Déduplication intelligente (ignore les médias déjà acquis)
  -l, --limit-rate <V>    Limiter la bande passante (ex: 5M, 500K)

OPTIONS AVANCÉES:
  --trim <DÉBUT> <FIN>    Télécharger uniquement un extrait (Range Request)
  --loudnorm              Normaliser le volume audio (norme EBU R128)
  --cookies-browser [NAV] Injecter les cookies du navigateur (firefox|chrome|brave)
  --sponsorblock          Supprimer automatiquement sponsors et intros
  --sub [LANGUES]         Télécharger et incruster les sous-titres (ex: fr,en)
  -b, --batch <FICHIER>   Télécharger une liste d'URLs depuis un fichier
  -o, --output <DOSSIER>  Dossier de destination personnalisé
  --organize              Classer dans un dossier par chaîne / artiste
  --no-notify             Désactiver les notifications de bureau
  -F, --formats           Lister tous les formats disponibles
  -n, --dry-run           Simuler sans télécharger de fichier

SYSTÈME & HISTORIQUE:
  --history               Consulter l'historique des téléchargements
  init, --init            Installer vget dans le PATH global (~/.local/bin)
  --check-deps            Diagnostiquer les outils système requis
  --update                Mettre à jour vget et yt-dlp
  -h, --help              Afficher cette aide
  -V, --version           Afficher la version
EOF
}
