#!/bin/bash

echo "🚀 Listfy - Executando aplicativo Flutter"
echo "==============================================="

# Verificar se estamos na pasta correta
if [ ! -d "app" ]; then
    echo "❌ Erro: Pasta 'app' não encontrada!"
    echo "   Execute este script na raiz do projeto listfy"
    exit 1
fi

echo "📱 Verificando dispositivos disponíveis..."
cd app
flutter devices

echo ""
echo "🔧 Executando flutter run..."
echo "   Ctrl+C para parar"
echo "   r para hot reload"
echo "   R para hot restart"
echo ""

flutter run