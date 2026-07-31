---
name: validate-collie-site
description: >-
  Valida o site institucional Collie (landing PT-BR) após qualquer alteração:
  smoke HTTP do domínio canônico, assets, SEO/Pages, CTAs, a11y básica e
  copy. Use when editing este repositório (raiz), o repo collie-ia-br, www.collie.ia.br,
  GitHub Pages, CNAME/robots/sitemap, ou quando o usuário pedir validar/checar/auditar o site.
---

# Validate Collie Site

Rode esta skill **sempre que o site mudar** — antes de considerar a alteração pronta.

## Repositórios e URLs

| Papel | Path / URL |
|-------|------------|
| Fonte (este repo) | `./` (raiz de collie-ia-br) |
| Publicado (GitHub Pages) — path local oficial | `/Users/mvasconcelos/code/mvs-eng/collie-code/collie-ia-br` |
| Publicado — remoto | `git@github.com:collie-ai-engineering/collie-ia-br.git` |
| Canônico | `https://www.collie.ia.br/` |
| Apex | `https://collie.ia.br/` → deve redirecionar para www |

**Path local do Pages:** use sempre o path oficial acima ao validar fonte↔publicado e em `SITE_ROOT=...`. Esse path (e o remoto) **podem mudar com o tempo** — ao mover o clone, atualize esta tabela, o exemplo de `SITE_ROOT` abaixo e o default em `scripts/validate-site.sh`.

Branch publicada: **`main`**. Desenvolvimento: `dev-01`. Preferir **git** (push/compare); não usar `gh` salvo pedido explícito.

## Quando validar

- Editou HTML/CSS/JS/imagens do site
- Merge ou push para o repo Pages
- Mudança de domínio, CNAME, robots, sitemap, meta OG
- Usuário pediu validar / checar / auditar o site

## Workflow

Copie e marque:

```text
Validação Collie Site
- [ ] 1. Escopo (fonte local vs live vs ambos)
- [ ] 2. Smoke HTTP (script)
- [ ] 3. Fonte estática (refs, SEO, CTAs)
- [ ] 4. Copy PT-BR
- [ ] 5. Relatório (Critical / Medium / Polish)
```

### 1. Escopo

- **Só fonte** → validar o path editado (`este repositório (raiz)` e/ou o clone Pages)
- **Pós-deploy** → fonte + live
- Se os dois divergirem, reportar drift (arquivo e lado desatualizado)

### 2. Smoke HTTP

```bash
bash .cursor/skills/validate-collie-site/scripts/validate-site.sh
# opcional:
BASE_URL=https://www.collie.ia.br bash .cursor/skills/validate-collie-site/scripts/validate-site.sh
# path oficial do clone Pages (atualizar na skill se mudar):
SITE_ROOT=/Users/mvasconcelos/code/mvs-eng/collie-code/collie-ia-br bash .cursor/skills/validate-collie-site/scripts/validate-site.sh --local-only
```

O script falha (exit ≠ 0) se houver Critical. Interprete a saída; não invente status HTTP.

### 3. Fonte estática

No `index.html` (e CSS/JS tocados):

1. Todo `src`/`href` local existe no disco
2. Head: `canonical`, `og:url`, `og:image` **absolutos** em `https://www.collie.ia.br/...`
3. `CNAME` = `www.collie.ia.br`; existem `robots.txt`, `sitemap.xml`, `404.html`, `llms.txt` no repo Pages
4. Head: JSON-LD Organization/WebSite; snippet Plausible (`data-domain="www.collie.ia.br"`)
5. CTAs honestos: Documentação → `/docs/` (páginas reais); Contato/Discovery → `#demo` ou destino real. Bloquear `Documentação` → `#docs` vazio.
6. Contatos: `mailto:contato@collie.ia.br`, WhatsApp `wa.me/5561982505951`
7. A11y: `lang="pt-BR"`, skip-link, `aria-*` no menu, alts em imagens de conteúdo
8. `script.js`: menu mobile, Escape, `prefers-reduced-motion`

Detalhe: [checklist.md](checklist.md).

### 4. Copy PT-BR

Aplicar `.cursor/rules/portal-copywriting.mdc`:

- PT-BR (não PT-PT)
- Sem blacklist / fluff / clichês de IA
- CTAs e claims alinhados ao produto (OpsMesh, MeshAgents, outbound-only)

### 5. Relatório

Formato obrigatório:

```markdown
## Veredito
**OK** | **OK com ressalvas** | **Bloqueado**

## Critical
- …

## Medium
- …

## Polish
- …

## Próximo passo
- …
```

| Severidade | Critério |
|------------|----------|
| **Critical** | 4xx/5xx em página/asset essencial; apex sem redirect; SEO canônico quebrado; CTA mentiroso; copy PT-PT grave |
| **Medium** | Meta relativa; robots/sitemap ausentes; drift fonte↔publicado; a11y parcial |
| **Polish** | Ritmo de copy; alinhamento de alt vs narrativa; mobile CTA no menu |

**Bloqueado** se existir qualquer Critical. Não declarar “site validado” com Critical aberto.

## Fora de escopo

- Redesign visual completo
- Cockpit UI / runtime OpsMesh
- DNS no registrador (apenas listar no “Próximo passo” se bloquear apex/HTTPS)

## Recursos

- Checklist detalhado: [checklist.md](checklist.md)
- Smoke: [scripts/validate-site.sh](scripts/validate-site.sh)
