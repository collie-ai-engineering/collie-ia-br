#!/bin/bash

# Este script inicia um servidor local leve na porta 8000
# Você pode executá-arlo em seu terminal sempre que fizer alterações no site.

echo "=========================================================="
echo "🌐 Iniciando o servidor web local da Collie AI Engineering"
echo "👉 Acesse: http://localhost:8000"
echo "⏹  Para encerrar o servidor, pressione Ctrl+C"
echo "=========================================================="

# Executa o servidor Python embutido
python3 -m http.server 8000
