# collie-ia-br

Site institucional da **Collie AI Engineering** — [www.collie.ia.br](https://www.collie.ia.br/).

## Stack

Site estático, sem build: HTML, CSS e JavaScript puro.

```text
index.html    estrutura e conteúdo
style.css     estilos
script.js     interações
docs/         documentação pública em HTML
docs.css      estilos das páginas de docs
img/          logos e ilustrações
img/docs/     SVGs das docs (espelho do tier público do repo do produto)
404.html      página de erro do GitHub Pages
CNAME         domínio canônico (www)
robots.txt    regras para crawlers
sitemap.xml   sitemap (home + páginas de docs)
llms.txt      mapa Markdown para agentes de IA
AGENTS.md     regras para agentes de IA neste repo
serve.sh      servidor local de desenvolvimento
```

## Rodar localmente

```bash
./serve.sh          # start (foreground)
./serve.sh stop     # encerra o processo na porta 8000
./serve.sh restart  # para e sobe em background
./serve.sh status   # mostra se está ativo
# abre em http://localhost:8000
```

Precisa apenas de Python 3 (`python3 -m http.server`).
Para liberar a porta quando o terminal antigo morreu: `./serve.sh stop`.

## Branches

Locais e em `origin` hoje:

- `main` — versão publicada (GitHub Pages)
- `dev-01` — desenvolvimento (histórico; sem atividade recente)
- `fix/site-pages-seo` — ajustes de SEO/Pages
- `marcos/doc-publication` — publicação das docs em HTML

Trabalho novo sai de `main` em branch própria e volta por PR.

## Hospedagem

GitHub Pages com domínio canônico **`www.collie.ia.br`**.

### Checklist pós-merge em `main`

1. **Pages** → Settings → Pages
   - Source: branch `main` / root (`/`)
   - Custom domain: `www.collie.ia.br`
   - Enforce HTTPS: ligado
2. **DNS**
   - `www` → CNAME para o host do Pages **confirmado no painel** (Settings → Pages).
     O repo hoje é `collie-ai-engineering/collie-ia-br`; o host mudou junto com a
     organização, então não reaproveite valor antigo — copie o que o Pages indicar.
   - Apex `collie.ia.br` → A/ALIAS do GitHub Pages **ou** redirect para `www`
3. **Smoke**
   - `https://www.collie.ia.br/` → 200
   - `/img/*`, `/robots.txt`, `/sitemap.xml`, `/llms.txt` → 200
   - `https://collie.ia.br` → redirect para www
4. **Search Console** — propriedade `https://www.collie.ia.br/`; enviar `sitemap.xml`
5. **Plausible** — domínio `www.collie.ia.br` no painel; goal no CTA `#demo`

### Campanhas (UTM)

Use na URL ao compartilhar:

`https://www.collie.ia.br/?utm_source=linkedin&utm_medium=organic&utm_campaign=nome`

Troque `utm_source` / `utm_medium` (`organic` | `paid` | `cpc`) e `utm_campaign` por campanha.

O site não depende da infraestrutura de demonstração na OCI.

## Origem

Conteúdo migrado de `collie-ai-engineering/assets/brand/website/`.

## Licença

Proprietária — All Rights Reserved. Ver [LICENSE](LICENSE).

## Validação e copy

- Validação: [`.cursor/skills/validate-collie-site/`](.cursor/skills/validate-collie-site/)
- Copy executiva / GEO: [`.cursor/skills/copywriting-clevel-geo/`](.cursor/skills/copywriting-clevel-geo/)
- Regra de copy PT-BR: [`.cursor/rules/portal-copywriting.mdc`](.cursor/rules/portal-copywriting.mdc)

## Documentação pública

As docs de uso do OpsMesh estão publicadas em HTML em [`docs/`](docs/).

Fonte canônica no repo do produto (**collie-opsmesh**):

- conteúdo: `docs/install/` (Markdown)
- diagramas: `docs/img/public/` (SVG), espelhados aqui em `img/docs/` byte a byte

O tier público é a versão sanitizada dos diagramas — sem nomes de tecnologia de
terceiros. Os diagramas de `docs/img/install/` servem a quem instala e **não** são
publicados aqui.

Os SVGs espelhados devem permanecer idênticos à fonte — não edite as cópias aqui.
Mudança de conteúdo começa no repo do produto e só depois vira HTML neste repo.
