# Checklist — Collie Site

Complemento de [SKILL.md](SKILL.md). Use item a item; não pule Critical.

## A. Live (www)

- [ ] `GET https://www.collie.ia.br/` → 200, `text/html`
- [ ] `GET https://collie.ia.br/` → 301/302 para `https://www.collie.ia.br/` (não 403)
- [ ] HTTP → HTTPS redirect
- [ ] `/style.css`, `/script.js` → 200
- [ ] Assets do HTML → 200 (não 404/500):
  - `/img/collie-mark.png`
  - `/img/collie-lockup.png`
  - `/img/favicon.png`
  - `/img/hero-topology.svg`
  - `/img/hero-architecture.svg`
  - `/img/opsmesh-flow.svg`
  - `/img/dashboard-mockup.svg`
  - `/docs/` → 200
  - `/docs.css` → 200
  - `/docs/cenarios.html` → 200
  - `/img/docs/saas-overview.svg` → 200
- [ ] `/robots.txt` → 200, aponta Sitemap
- [ ] `/sitemap.xml` → 200, inclui home canônica
- [ ] `/llms.txt` → 200, mapa Markdown para agentes (H1 Collie)
- [ ] `/404.html` ou rota inexistente com página de erro útil

## B. SEO / compartilhamento

- [ ] `<link rel="canonical" href="https://www.collie.ia.br/">`
- [ ] `og:url` = `https://www.collie.ia.br/`
- [ ] `og:image` absoluto (`https://www.collie.ia.br/img/...`)
- [ ] `og:title` / `og:description` / `og:locale=pt_BR`
- [ ] Twitter card (`summary_large_image`) com image absoluta
- [ ] Title + meta description presentes e coerentes
- [ ] JSON-LD `Organization` + `WebSite` no `<head>`
- [ ] Snippet Plausible (`data-domain="www.collie.ia.br"` + `plausible.io/js/script.js`)
- [ ] Goal Plausible no painel: clique CTA `#demo` / discovery (ativar domínio no painel se ainda não existir)

## C. GitHub Pages (repo `collie-ia-br`)

Clone local oficial (pode mudar — ver SKILL.md): `/Users/mvasconcelos/code/mvs-eng/collie-code/collie-ia-br`

- [ ] `CNAME` = `www.collie.ia.br`
- [ ] Source Pages = branch `main` / root
- [ ] Conteúdo de produção está em `main` (não só em `dev-01`)
- [ ] Push via **git**; PR via compare URL se necessário

## D. Navegação e CTAs

- [ ] Header: Contato / discovery → `#demo` (ou destino real)
- [ ] Documentação → `/docs/` (páginas reais; sem `#docs` vazio)
- [ ] Footer: links de seção válidos; Recursos honestos
- [ ] `mailto:contato@collie.ia.br`
- [ ] WhatsApp `https://wa.me/5561982505951`
- [ ] Mobile: menu abre/fecha; Escape fecha; CTA alcançável

## E. Acessibilidade mínima

- [ ] `html lang="pt-BR"`
- [ ] Skip-link `#main`
- [ ] Botão de menu com `aria-expanded` / `aria-controls`
- [ ] Imagens de conteúdo com `alt` útil; decorativas com `alt=""`
- [ ] Focus visible nos controles
- [ ] Respeito a `prefers-reduced-motion`

## F. Copy (PT-BR)

- [ ] Vocabulário BR (não PT-PT: ecrã, ficheiro, telemóvel…)
- [ ] Sem blacklist do portal-copywriting
- [ ] Claims alinhados: IA pede → OpsMesh governa → MeshAgents executam
- [ ] Docs públicas em `/docs/` alinhadas a uso/instalação (não arquitetura interna)

## G. Paridade fonte ↔ publicado

Quando ambos existirem:

| Artefato | `assets/brand/website` | `/Users/mvasconcelos/code/mvs-eng/collie-code/collie-ia-br` |
|----------|------------------------|--------------------------------------------------|
| `index.html` | ? | ? |
| `style.css` | ? | ? |
| `script.js` | ? | ? |
| `img/*` referenciados | ? | ? |
| `llms.txt` | ? | ? |
| `robots.txt` | ? | ? |
| Pages-only (`CNAME`, sitemap, 404) | n/a ou espelho | obrigatório |

Drift = Medium (ou Critical se live servir versão errada).
