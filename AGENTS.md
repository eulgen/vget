# Directives Globales de Développement - vget

Bienvenue dans le dépôt de **vget** (Hub Multimédia CLI Universel en Bash 4+).
Ce document régit les comportements, contrôles et règles que tout agent IA doit appliquer à chaque prompt.

---

## 🎯 Architecture & Règles Fondamentales

1. **📏 Plafond Absolu de 200 Lignes par Fichier** ([`.agents/rules/max-lines.md`](file:///.agents/rules/max-lines.md))
   - Aucun fichier source dans `bin/` ou `lib/` ne doit dépasser 200 lignes.
   - **Découpage Préventif dès 180 Lignes** ([`.agents/rules/modular-auto-split.md`](file:///.agents/rules/modular-auto-split.md)) : dès qu'un fichier approche 180 lignes, extraire des sous-modules spécialisés.

2. **🔁 Quadruple Synchronisation des Évolutions** ([`.agents/rules/feature-lifecycle-sync.md`](file:///.agents/rules/feature-lifecycle-sync.md))
   - Tout changement d'option ou argument CLI doit impérativement synchroniser :
     1. Le code métier (`lib/*.sh` et `bin/vget`)
     2. L'aide terminal (`show_help()`)
     3. L'autocomplétion (`completions/vget.bash`)
     4. La suite de tests (`tests/run_tests.sh`)

3. **🛡️ Robustesse Bash & Sécurité Shell** ([`.agents/rules/shell-sanitization-guard.md`](file:///.agents/rules/shell-sanitization-guard.md))
   - `set -euo pipefail` et `IFS=$'\n\t'`.
   - Protection systématique des variables (`"$url"`, `"$@"`).
   - Traps de signal pour restaurer l'état du terminal (`tput cnorm`) et purger les résidus temporaires (`*.part`).

4. **🧪 Contrôle Qualité Systématique Post-Modification** ([`.agents/rules/workflow-execution.md`](file:///.agents/rules/workflow-execution.md))
   - À chaque prompt modifiant du code, exécuter :
     1. `wc -l bin/vget lib/*.sh install.sh tests/run_tests.sh`
     2. `bash -n bin/vget && for f in lib/*.sh install.sh; do bash -n "$f"; done`
     3. `shellcheck bin/vget lib/*.sh install.sh tests/run_tests.sh`
     4. `./tests/run_tests.sh`
