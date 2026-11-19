#!/usr/bin/env bash
# =============================================================================
# deploy.sh - publica o conteudo de ./site em GitHub Pages (tecnologiacrista.github.io)
#             APAGANDO TODO O HISTORICO de commits do remoto (force push).
#
# Uso:
#   ./deploy.sh
#
# Variaveis opcionais (para testar/sobrescrever):
#   CONTENT=<pasta>     conteudo a publicar        (default: ./site)
#   KEYS=<pasta>        pasta dos tokens           (default: $EXT42020ENV/KEYS)
#   MESSAGE=<texto>     mensagem do commit
#   GITHUB_REMOTE=<url>       remoto alternativo (teste local)
#
# O que ele faz:
#   1) cria um repositorio git LIMPO (sem historico) apontando para ./site
#   2) faz 1 unico commit com todo o conteudo
#   3) git push --force  => o historico remoto vira esse unico commit
#
# NAO copia arquivos: usa ./site como work-tree, entao funciona mesmo com
# gigabytes. Um .gitignore dentro de site/, se existir, e respeitado.
# =============================================================================
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTENT="${CONTENT:-$HERE/site}"
KEYS="${KEYS:-${EXT42020ENV:-$HOME/EXT42020ENV}/KEYS}"
DEPLOY_DIR="$HERE/.deploy"
MESSAGE="${MESSAGE:-Deploy $(date -u +%Y-%m-%dT%H:%M:%SZ)}"
TOKEN_FILE="$KEYS/tecnologiacrista_githubio.txt"
REMOTE="https://x-access-token:@@TOKEN@@@github.com/tecnologiacrista/tecnologiacrista.github.io.git"

mask() { sed -E 's#(x-access-token|oauth2|x-token-auth):[^@]+@#\1:<TOKEN>@#g; s#(gh[opsu]_[A-Za-z0-9_]+)#<TOKEN>#g; s#github_pat_[A-Za-z0-9_]+#<TOKEN>#g; s#glpat-[A-Za-z0-9_-]+#<TOKEN>#g; s#ATCT[A-Za-z0-9_=/+-]+#<TOKEN>#g'; }

die() { echo "ERRO: $*" >&2; exit 1; }

GD="$DEPLOY_DIR/tecnologiacristagithubio.git"

[ -d "$CONTENT" ] || die "pasta de conteudo nao encontrada: $CONTENT"
[ -n "$(ls -A "$CONTENT" 2>/dev/null | grep -v '^\.git$' || true)" ] \
    || die "pasta de conteudo vazia: $CONTENT"
[ -f "$TOKEN_FILE" ] || die "token nao encontrado: $TOKEN_FILE"

TOKEN="$(tr -d ' \t\r\n' < "$TOKEN_FILE")"
URL="${GITHUB_REMOTE:-$REMOTE}"
URL="${URL/tecnologiacrista_githubio.txt/$TOKEN}"

rm -rf "$GD"; mkdir -p "$GD"
git init -q --bare "$GD"
git --git-dir="$GD" config user.email "contact@brunodamato.com"
git --git-dir="$GD" config user.name  "Bruno D'Amato"
git --git-dir="$GD" config core.worktree "$CONTENT"

echo ">> preparando 1 commit com o conteudo de $CONTENT"
git --git-dir="$GD" --work-tree="$CONTENT" add -A
git --git-dir="$GD" --work-tree="$CONTENT" commit -q --allow-empty -m "$MESSAGE"

echo ">> force push para tecnologiacrista.github.io (apagando historico remoto)"
GIT_TERMINAL_PROMPT=0 git --git-dir="$GD" --work-tree="$CONTENT" \
    push --force "$URL" HEAD:main 2>&1 | mask

rm -rf "$GD"
echo ">> OK: https://tecnologiacrista.github.io/"
