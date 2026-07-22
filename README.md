# collie-ia-br

Site institucional da **Collie AI Engineering** — [www.collie.ia.br](https://www.collie.ia.br/).

## Stack

Site estático, sem build: HTML, CSS e JavaScript puro.

```text
index.html    estrutura e conteúdo
style.css     estilos
script.js     interações
img/          logos e ilustrações
404.html      página de erro do GitHub Pages
CNAME         domínio canônico (www)
robots.txt    regras para crawlers
sitemap.xml   sitemap da home
serve.sh      servidor local de desenvolvimento
```

## Rodar localmente

```bash
./serve.sh
# abre em http://localhost:8000
```

Precisa apenas de Python 3 (`python3 -m http.server`).

## Branches

- `dev-01` — desenvolvimento
- `main` — versão publicada (GitHub Pages)

## Hospedagem

GitHub Pages com domínio canônico **`www.collie.ia.br`**.

### Checklist pós-merge em `main`

1. **Pages** → Settings → Pages
   - Source: branch `main` / root (`/`)
   - Custom domain: `www.collie.ia.br`
   - Enforce HTTPS: ligado
2. **DNS**
   - `www` → CNAME para `collie-ia.github.io` (ou o host indicado pelo Pages)
   - Apex `collie.ia.br` → A/ALIAS do GitHub Pages **ou** redirect para `www`
3. **Smoke**
   - `https://www.collie.ia.br/` → 200
   - `/img/*`, `/robots.txt`, `/sitemap.xml` → 200
   - `https://collie.ia.br` → redirect para www

O site não depende da infraestrutura de demonstração na OCI.

## Origem

Conteúdo migrado de `collie-ai-engineering/assets/brand/website/`.

## Licença

Proprietária — All Rights Reserved. Ver [LICENSE](LICENSE).
