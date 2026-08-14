#!/usr/bin/env bash
# Servidor local do site Collie (python3 -m http.server).
# Uso: ./serve.sh [start|stop|restart|status]
# Porta: PORT=8000 (padrão)

set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
PORT="${PORT:-8000}"
PID_FILE="${ROOT}/.serve.pid"
LOG_FILE="${ROOT}/.serve.log"
URL="http://localhost:${PORT}"

cd "$ROOT"

pids_on_port() {
  if command -v lsof >/dev/null 2>&1; then
    lsof -nP -iTCP:"$PORT" -sTCP:LISTEN -t 2>/dev/null | sort -u || true
  else
    true
  fi
}

is_running() {
  local pid="$1"
  [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null
}

cmd_status() {
  local pids
  pids="$(pids_on_port)"
  if [[ -n "$pids" ]]; then
    echo "Servidor ativo em ${URL}"
    echo "PID(s): ${pids//$'\n'/ }"
    return 0
  fi
  if [[ -f "$PID_FILE" ]]; then
    local stale
    stale="$(cat "$PID_FILE" 2>/dev/null || true)"
    echo "Servidor parado (PID antigo em .serve.pid: ${stale:-vazio})."
    rm -f "$PID_FILE"
  else
    echo "Servidor parado."
  fi
  return 1
}

cmd_stop() {
  local pids killed=()
  pids="$(pids_on_port)"

  if [[ -z "$pids" && -f "$PID_FILE" ]]; then
    pids="$(cat "$PID_FILE" 2>/dev/null || true)"
  fi

  if [[ -z "${pids//[[:space:]]/}" ]]; then
    echo "Nada escutando na porta ${PORT}."
    rm -f "$PID_FILE"
    return 0
  fi

  for pid in $pids; do
    if is_running "$pid"; then
      kill "$pid" 2>/dev/null || true
      killed+=("$pid")
    fi
  done

  # Aguarda liberar a porta; se não sair, força.
  local i
  for i in 1 2 3 4 5; do
    pids="$(pids_on_port)"
    [[ -z "$pids" ]] && break
    sleep 0.2
  done

  pids="$(pids_on_port)"
  if [[ -n "$pids" ]]; then
    for pid in $pids; do
      kill -9 "$pid" 2>/dev/null || true
      killed+=("$pid")
    done
    sleep 0.2
  fi

  rm -f "$PID_FILE"

  if [[ -z "$(pids_on_port)" ]]; then
    if ((${#killed[@]})); then
      echo "Servidor parado. Encerrado PID(s): ${killed[*]}"
    else
      echo "Servidor parado."
    fi
  else
    echo "Falha ao liberar a porta ${PORT}. Ainda em uso por: $(pids_on_port | tr '\n' ' ')" >&2
    return 1
  fi
}

cmd_start() {
  local existing
  existing="$(pids_on_port)"
  if [[ -n "$existing" ]]; then
    echo "Já está rodando em ${URL} (PID: ${existing//$'\n'/ })."
    echo "Use: ./serve.sh stop   ou   ./serve.sh restart"
    return 0
  fi

  if ! command -v python3 >/dev/null 2>&1; then
    echo "python3 não encontrado." >&2
    return 1
  fi

  echo "=========================================================="
  echo "Iniciando servidor local da Collie AI Engineering"
  echo "Acesse: ${URL}"
  echo "Parar:  ./serve.sh stop"
  echo "=========================================================="

  # Foreground por padrão (Ctrl+C encerra). Com SERVE_BG=1 sobe em background.
  if [[ "${SERVE_BG:-0}" == "1" ]]; then
    nohup python3 -m http.server "$PORT" >"$LOG_FILE" 2>&1 &
    echo $! >"$PID_FILE"
    sleep 0.3
    if cmd_status >/dev/null; then
      echo "Rodando em background. Log: ${LOG_FILE}"
    else
      echo "Falha ao iniciar. Veja ${LOG_FILE}" >&2
      return 1
    fi
  else
    # Grava PID do processo atual do server após o exec não seria possível;
    # roda em subshell rastreável e limpa no exit.
    python3 -m http.server "$PORT" &
    local pid=$!
    echo "$pid" >"$PID_FILE"
    trap 'kill "$pid" 2>/dev/null || true; rm -f "$PID_FILE"; exit 0' INT TERM
    wait "$pid"
    rm -f "$PID_FILE"
  fi
}

cmd_restart() {
  cmd_stop || true
  SERVE_BG="${SERVE_BG:-1}" cmd_start
}

usage() {
  cat <<EOF
Uso: ./serve.sh [comando]

Comandos:
  start     Inicia o servidor (padrão)
  stop      Encerra o processo na porta ${PORT}
  restart   Para e sobe de novo (background)
  status    Mostra se está ativo

Variáveis:
  PORT=8000       Porta HTTP
  SERVE_BG=1      start em background (log em .serve.log)

Exemplos:
  ./serve.sh
  ./serve.sh stop
  ./serve.sh restart
  PORT=8080 ./serve.sh start
EOF
}

main() {
  local cmd="${1:-start}"
  case "$cmd" in
    start) cmd_start ;;
    stop) cmd_stop ;;
    restart) cmd_restart ;;
    status) cmd_status || true ;;
    -h|--help|help) usage ;;
    *)
      echo "Comando desconhecido: $cmd" >&2
      usage >&2
      return 1
      ;;
  esac
}

main "$@"
