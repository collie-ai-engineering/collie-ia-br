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

# Só encerramos processo iniciado por este script: PID vindo do .serve.pid,
# vivo e reconhecido como python -m http.server. Nunca matamos por porta —
# a 8000 é disputada e derrubar o servidor de outra pessoa não é opção.
is_our_server() {
  local pid="$1" cmd
  is_running "$pid" || return 1
  cmd="$(ps -p "$pid" -o command= 2>/dev/null || true)"
  [[ "$cmd" == *"http.server"* ]]
}

owned_pid() {
  local pid
  [[ -f "$PID_FILE" ]] || return 1
  pid="$(cat "$PID_FILE" 2>/dev/null || true)"
  pid="${pid//[[:space:]]/}"
  is_our_server "$pid" || return 1
  printf '%s\n' "$pid"
}

# Imprime aviso e retorna 0 quando a porta está ocupada por processo alheio.
warn_foreign_port() {
  local pids
  pids="$(pids_on_port)"
  [[ -n "$pids" ]] || return 1
  echo "Porta ${PORT} em uso por processo que não é deste script (PID: ${pids//$'\n'/ })." >&2
  echo "Encerre esse processo você mesmo ou use outra porta: PORT=8080 ./serve.sh start" >&2
  return 0
}

cmd_status() {
  local pid
  if pid="$(owned_pid)"; then
    echo "Servidor ativo em ${URL} (PID: ${pid})"
    return 0
  fi
  if [[ -f "$PID_FILE" ]]; then
    echo "Servidor parado (PID antigo em .serve.pid removido)."
    rm -f "$PID_FILE"
  else
    echo "Servidor parado."
  fi
  warn_foreign_port || true
  return 1
}

cmd_stop() {
  local pid
  if ! pid="$(owned_pid)"; then
    rm -f "$PID_FILE"
    if warn_foreign_port; then
      return 1
    fi
    echo "Nenhum servidor deste script em execução."
    return 0
  fi

  kill "$pid" 2>/dev/null || true

  local i
  for i in 1 2 3 4 5; do
    is_running "$pid" || break
    sleep 0.2
  done

  if is_running "$pid"; then
    kill -9 "$pid" 2>/dev/null || true
    sleep 0.2
  fi

  rm -f "$PID_FILE"

  if is_running "$pid"; then
    echo "Falha ao encerrar o servidor (PID ${pid})." >&2
    return 1
  fi
  echo "Servidor parado. Encerrado PID: ${pid}"
}

cmd_start() {
  local pid
  if pid="$(owned_pid)"; then
    echo "Já está rodando em ${URL} (PID: ${pid})."
    echo "Use: ./serve.sh stop   ou   ./serve.sh restart"
    return 0
  fi
  rm -f "$PID_FILE"

  if warn_foreign_port; then
    return 1
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
    # Sobe como filho rastreável para registrar o PID e limpar no Ctrl+C.
    python3 -m http.server "$PORT" &
    pid=$!
    echo "$pid" >"$PID_FILE"
    trap 'kill "$pid" 2>/dev/null || true; rm -f "$PID_FILE"; exit 0' INT TERM
    wait "$pid" || true
    rm -f "$PID_FILE"
  fi
}

cmd_restart() {
  cmd_stop || return 1
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
