# collie-ia-br

Site institucional da **Collie AI Engineering** — [collie.ia.br](https://collie.ia.br).

## Stack

Site estático, sem build: HTML, CSS e JavaScript puro.

```text
index.html    estrutura e conteúdo
style.css     estilos
script.js     interações
img/          logos e ilustrações (SVG)
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
- `main` — versão publicada (destino do GitHub Pages)

## Hospedagem

GitHub Pages com domínio `collie.ia.br` (configuração na fase seguinte). O site
não depende da infraestrutura de demonstração na OCI.

## Origem

Conteúdo migrado de `collie-ai-engineering/assets/brand/website/`.

## Licença

Proprietária — All Rights Reserved. Ver [LICENSE](LICENSE).
