#!/usr/bin/env bash
# Smoke validation for Collie institutional site (GitHub Pages).
# Usage:
#   ./validate-site.sh
#   BASE_URL=https://www.collie.ia.br ./validate-site.sh
#   SITE_ROOT=/Users/mvasconcelos/code/mvs-eng/collie-code/collie-ia-br ./validate-site.sh --local-only
#   SITE_ROOT= ./validate-site.sh   # pular check local
#
# Default SITE_ROOT = clone Pages oficial (pode mudar; manter alinhado com SKILL.md).
set -euo pipefail

BASE_URL="${BASE_URL:-https://www.collie.ia.br}"
APEX_URL="${APEX_URL:-https://collie.ia.br}"
# Path oficial documentado na skill; sobrescreva ou use SITE_ROOT= para desligar.
DEFAULT_SITE_ROOT="/Users/mvasconcelos/code/mvs-eng/collie-code/collie-ia-br"
SITE_ROOT="${SITE_ROOT-$DEFAULT_SITE_ROOT}"
LOCAL_ONLY=0
UA="${UA:-Mozilla/5.0 (compatible; CollieSiteValidate/1.0)}"

for arg in "$@"; do
  case "$arg" in
    --local-only) LOCAL_ONLY=1 ;;
    -h|--help)
      sed -n '2,8p' "$0"
      exit 0
      ;;
  esac
done

critical=0
medium=0
pass=0

ok()   { pass=$((pass + 1)); printf '  OK   %s\n' "$*"; }
warn() { medium=$((medium + 1)); printf '  WARN %s\n' "$*"; }
fail() { critical=$((critical + 1)); printf '  FAIL %s\n' "$*"; }

http_code() {
  local url="$1"
  curl -sS -o /dev/null -w '%{http_code}' -L --max-time 20 -A "$UA" "$url" || echo "000"
}

http_code_noredir() {
  local url="$1"
  curl -sS -o /dev/null -w '%{http_code}' --max-time 20 -A "$UA" "$url" || echo "000"
}

final_url() {
  local url="$1"
  curl -sS -o /dev/null -w '%{url_effective}' -L --max-time 20 -A "$UA" "$url" || true
}

check_url() {
  local path="$1"
  local expect="${2:-200}"
  local url="${BASE_URL%/}${path}"
  local code
  code="$(http_code "$url")"
  if [[ "$code" == "$expect" ]]; then
    ok "$path → $code"
  else
    fail "$path → $code (esperado $expect)"
  fi
}

check_local_tree() {
  local root="$1"
  printf '\n== Local: %s ==\n' "$root"
  if [[ ! -d "$root" ]]; then
    fail "SITE_ROOT inexistente: $root"
    return
  fi

  local required=(
    index.html style.css script.js
    CNAME robots.txt sitemap.xml 404.html llms.txt
    img/collie-mark.png img/collie-lockup.png img/favicon.png
    img/hero-topology.svg img/hero-architecture.svg
    img/opsmesh-flow.svg img/dashboard-mockup.svg
  )
  local f
  for f in "${required[@]}"; do
    if [[ -f "$root/$f" ]]; then
      ok "arquivo $f"
    else
      fail "faltando $f"
    fi
  done

  if [[ -f "$root/CNAME" ]]; then
    local cname
    cname="$(tr -d '[:space:]' < "$root/CNAME")"
    if [[ "$cname" == "www.collie.ia.br" ]]; then
      ok "CNAME=$cname"
    else
      fail "CNAME=$cname (esperado www.collie.ia.br)"
    fi
  fi

  if [[ -f "$root/index.html" ]]; then
    local html
    html="$(cat "$root/index.html")"
    if grep -q 'rel="canonical" href="https://www.collie.ia.br/"' <<<"$html"; then
      ok "canonical absoluto"
    else
      fail "canonical ausente ou não absoluto"
    fi
    if grep -q 'property="og:image" content="https://www.collie.ia.br/' <<<"$html"; then
      ok "og:image absoluto"
    else
      fail "og:image relativo ou ausente"
    fi
    if grep -q 'Documentação' <<<"$html" && grep -q 'href="#docs"' <<<"$html"; then
      fail "CTA Documentação → #docs (engano)"
    else
      ok "sem CTA Documentação enganoso"
    fi
    if [[ -f "$root/docs/index.html" && -f "$root/docs.css" ]]; then
      ok "docs/ hub + docs.css"
    else
      fail "docs/ ausente (esperado hub público)"
    fi
    for doc_page in como-funciona.html instalar.html cenarios.html topologias.html; do
      if [[ -f "$root/docs/$doc_page" ]]; then
        ok "docs/$doc_page"
      else
        fail "docs/$doc_page ausente"
      fi
    done
    if grep -q 'href="docs/"' <<<"$html" || grep -q 'href="/docs/"' <<<"$html"; then
      ok "home linka /docs/"
    else
      warn "home sem link para docs/"
    fi
    if grep -q 'application/ld+json' <<<"$html" && grep -q '"@type": "Organization"' <<<"$html"; then
      ok "JSON-LD Organization"
    else
      warn "JSON-LD Organization ausente"
    fi
    if grep -q 'data-domain="www.collie.ia.br"' <<<"$html" && grep -q 'plausible.io/js/script.js' <<<"$html"; then
      ok "snippet Plausible"
    else
      warn "snippet Plausible ausente"
    fi
    # referenced local assets
    local ref
    while IFS= read -r ref; do
      ref="${ref#\"}"
      ref="${ref%\"}"
      [[ "$ref" == http* ]] && continue
      [[ "$ref" == mailto:* || "$ref" == tel:* || "$ref" == \#* ]] && continue
      if [[ -f "$root/$ref" ]]; then
        ok "ref $ref"
      elif [[ "$ref" == */ || "$ref" == */. ]] && [[ -f "$root/${ref%/}/index.html" ]]; then
        ok "ref $ref → index.html"
      elif [[ -d "$root/$ref" && -f "$root/$ref/index.html" ]]; then
        ok "ref $ref/ → index.html"
      else
        fail "ref quebrada $ref"
      fi
    done < <(grep -oE '(src|href)="[^"]+"' "$root/index.html" | sed -E 's/^(src|href)=//' | tr -d '"' | grep -E '^(img/|style\.css|script\.js|docs\.css|docs/)')
  fi
}

printf 'Collie site validate\n'
printf 'BASE_URL=%s\n' "$BASE_URL"

if [[ -n "$SITE_ROOT" ]]; then
  if [[ -d "$SITE_ROOT" ]]; then
    check_local_tree "$SITE_ROOT"
  elif [[ "$LOCAL_ONLY" -eq 1 ]]; then
    fail "SITE_ROOT inexistente: $SITE_ROOT"
  else
    warn "SITE_ROOT ausente (pulando local): $SITE_ROOT"
  fi
fi

if [[ "$LOCAL_ONLY" -eq 1 ]]; then
  if [[ -z "$SITE_ROOT" ]]; then
    fail "--local-only exige SITE_ROOT"
  fi
else
  printf '\n== Live smoke ==\n'
  home_code="$(http_code "${BASE_URL}/")"
  if [[ "$home_code" == "200" ]]; then
    ok "/ → 200"
  else
    fail "/ → $home_code"
  fi

  apex_code="$(http_code_noredir "${APEX_URL}/")"
  apex_final="$(final_url "${APEX_URL}/")"
  case "$apex_code" in
    301|302|303|307|308)
      if [[ "$apex_final" == https://www.collie.ia.br* ]]; then
        ok "apex $apex_code → $apex_final"
      else
        warn "apex $apex_code → $apex_final (esperado www)"
      fi
      ;;
    200)
      if [[ "$apex_final" == https://www.collie.ia.br* ]]; then
        ok "apex resolve para www ($apex_final)"
      else
        warn "apex 200 sem redirect claro ($apex_final)"
      fi
      ;;
    *)
      fail "apex → $apex_code (esperado redirect para www)"
      ;;
  esac

  check_url "/style.css"
  check_url "/script.js"
  check_url "/robots.txt"
  check_url "/sitemap.xml"
  check_url "/llms.txt"
  check_url "/img/collie-mark.png"
  check_url "/img/collie-lockup.png"
  check_url "/img/favicon.png"
  check_url "/img/hero-topology.svg"
  check_url "/img/hero-architecture.svg"
  check_url "/img/opsmesh-flow.svg"
  check_url "/img/dashboard-mockup.svg"
fi

printf '\n== Summary ==\n'
printf 'pass=%s warn=%s fail=%s\n' "$pass" "$medium" "$critical"

if [[ "$critical" -gt 0 ]]; then
  printf 'VERDICT=BLOQUEADO\n'
  exit 1
fi
if [[ "$medium" -gt 0 ]]; then
  printf 'VERDICT=OK_COM_RESSALVAS\n'
  exit 0
fi
printf 'VERDICT=OK\n'
exit 0
