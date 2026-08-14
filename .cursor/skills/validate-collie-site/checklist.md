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
  - `/docs.css` → 200
- [ ] Páginas de docs → 200:
  - `/docs/`
  - `/docs/como-funciona.html`
  - `/docs/instalar.html`
  - `/docs/cenarios.html`
  - `/docs/topologias.html`
- [ ] SVGs de `img/docs/` referenciados pelas páginas → 200:
  - de `/docs/`: `/img/docs/opsmesh-architecture.svg`, `/img/docs/saas-overview.svg`, `/img/docs/full-overview.svg`
  - de `/docs/cenarios.html`: `/img/docs/saas-overview.svg`, `/img/docs/saas-1.1.svg`, `/img/docs/saas-1.2.svg`, `/img/docs/saas-1.3.svg`, `/img/docs/saas-1.4.svg`, `/img/docs/full-overview.svg`, `/img/docs/full-2.svg`, `/img/docs/full-3.svg`, `/img/docs/full-4.svg`
  - de `/docs/topologias.html`: `/img/docs/topology-docker.svg`, `/img/docs/topology-k8s.svg`, `/img/docs/topology-vms.svg`
- [ ] `/robots.txt` → 200, aponta Sitemap
- [ ] `/sitemap.xml` → 200, inclui home canônica e as páginas de `/docs/`
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

Rode o validate a partir do próprio checkout — ele deriva a raiz do repo (ver SKILL.md). Caminho local de máquina não entra em arquivo versionado.

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

## G. Paridade docs: produto ↔ site

A fonte canônica das docs públicas é o repo do produto (**collie-opsmesh**):

| Artefato | Fonte (collie-opsmesh) | Publicado (collie-ia-br) |
|----------|------------------------|--------------------------|
| Conteúdo das docs | `docs/install/` (Markdown) | `docs/*.html` |
| Diagramas | `docs/img/public/*.svg` | `img/docs/*.svg` (espelho byte-idêntico) |

Dois tiers de diagrama no repo do produto:

- `docs/img/public/` — versão sanitizada, 13 SVGs (12 de cenário/topologia +
  `opsmesh-architecture.svg`). É o único tier publicado.
- `docs/img/install/` — versão detalhada para quem instala. **Nunca** vai para o site.

- [ ] Todo SVG de `docs/img/public/` existe em `img/docs/` e é **byte-idêntico** (13 arquivos):

```bash
for f in <collie-opsmesh>/docs/img/public/*.svg; do
  cmp "$f" "img/docs/$(basename "$f")" || echo "DRIFT: $(basename "$f")"
done
ls -1 <collie-opsmesh>/docs/img/public/*.svg | wc -l   # esperado: 13
ls -1 img/docs/*.svg | wc -l                           # esperado: 13
```

- [ ] Nenhum SVG publicado cita tecnologia de terceiros da nossa stack:

```bash
grep -liE "postgres|rabbitmq|amqp|django|fastapi|jwks|redis" img/docs/*.svg
# não deve retornar nada
```

  Ollama e vLLM são permitidos — são a escolha de LLM do cliente, não a nossa stack.

- [ ] Conteúdo das páginas HTML segue `docs/install/` (sem afirmação que não exista na fonte)
- [ ] Edição de docs começa no repo do produto; o site nunca é a origem

Drift = Medium (ou Critical se live servir versão errada).
Nome de tecnologia interna em SVG publicado = Critical.
