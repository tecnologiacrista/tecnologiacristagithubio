# tecnologiacristagithubio

Publica o redirect `https://tecnologiacrista.github.io/` → `https://www.tecnologiacrista.com/` em GitHub Pages.

## Estrutura

```
tecnologiacristagithubio/
├── site/
│   ├── index.html      <- redireciona para https://www.tecnologiacrista.com/
│   ├── 404.html        <- idem, para qualquer URL inexistente
├── deploy.sh           <- script de publicação
├── LICENSE             <- MPL-2.0
├── .gitignore          <- ignora .deploy/
└── README.md
```

## Como usar

```bash
cd tecnologiacristagithubio
./deploy.sh
```

Destino: `https://tecnologiacrista.github.io/`.

## O que o script faz

1. Cria um repositório git **novo e vazio** (sem histórico) usando `site/` como work-tree.
2. Faz **um único commit** com todo o conteúdo.
3. `git push --force` → o histórico do remoto passa a ser **esse único commit**.

> Não copia arquivos (usa `site/` direto), então funciona mesmo com gigabytes.
> Um `.gitignore` dentro de `site/`, se existir, é respeitado.

## Token

Lido de `$KEYS/tecnologiacrista_githubio.txt` — pasta dos tokens, padrão
`${EXT42020ENV:-$HOME/EXT42020ENV}/KEYS` (defina `KEYS` para outro lugar).
Formato da URL: `https://x-access-token:<TOKEN>@github.com/...`

## Variáveis opcionais

```bash
CONTENT=/outra/pasta      ./deploy.sh   # conteúdo de outra pasta
KEYS=/outra/keys          ./deploy.sh   # outra pasta de tokens
MESSAGE="texto"           ./deploy.sh   # mensagem do commit
GITHUB_REMOTE=/tmp/x.git  ./deploy.sh   # remoto alternativo (teste)
```

## Observações

- **Isso apaga o histórico remoto de forma irreversível.**
- O redirect usa `<link rel="canonical">`, `<meta http-equiv="refresh">` e
  `location.replace()` — três caminhos, para funcionar mesmo com JS desligado.
- GitHub Pages (branch `main`, raiz) serve os arquivos direto.

## Licença

Todo o conteúdo deste repositório — `deploy.sh`, `site/` e esta documentação —
é **MPL-2.0** ([`LICENSE`](LICENSE)).

Nenhum arquivo de terceiros é redistribuído aqui. O token não está neste
repositório: é lido de `$KEYS` em tempo de execução.
