#!/bin/bash

# ========================================
# SCRIPT DE RENOVAÇÃO DE CERTIFICADO SSL
# Salesforce Commerce Cloud (SFCC)
# ========================================

echo "🔐 SCRIPT DE RENOVAÇÃO DE CERTIFICADO SSL - SFCC"
echo "=================================================="
echo ""

# Verificar se os arquivos necessários existem
echo "📁 Verificando arquivos necessários..."

if [ ! -f "certificado.key" ]; then
    echo "❌ ERRO: Arquivo 'certificado.key' não encontrado!"
    echo "   Certifique-se de ter a chave privada do ano passado."
    exit 1
fi

if [ ! -f "certificado.conf" ]; then
    echo "❌ ERRO: Arquivo 'certificado.conf' não encontrado!"
    echo "   Certifique-se de ter o arquivo de configuração."
    exit 1
fi

echo "✅ Arquivos necessários encontrados!"
echo ""

# PASSO 1: Verificar arquivos existentes
echo "🔍 PASSO 1: Verificando arquivos existentes..."
echo "----------------------------------------------"

echo "Verificando chave privada..."
if openssl rsa -in certificado.key -check -noout; then
    echo "✅ Chave privada válida!"
else
    echo "❌ ERRO: Chave privada inválida!"
    exit 1
fi

echo ""
echo "Verificando data de expiração do certificado atual..."
if [ -f "certificado.crt" ]; then
    echo "Data de expiração:"
    openssl x509 -in certificado.crt -text -noout | grep "Not After"
else
    echo "⚠️  Arquivo 'certificado.crt' não encontrado (normal se for renovação)"
fi

echo ""
echo "🔧 PASSO 2: Gerando novo CSR..."
echo "-------------------------------"

# Gerar CSR
echo "Gerando CSR com a chave privada existente..."
if openssl req -new -key certificado.key -out certificado_renovacao.csr -config certificado.conf; then
    echo "✅ CSR gerado com sucesso: certificado_renovacao.csr"
else
    echo "❌ ERRO: Falha ao gerar CSR!"
    exit 1
fi

echo ""
echo "Verificando CSR gerado..."
openssl req -in certificado_renovacao.csr -text -noout | head -20

echo ""
echo "📋 PASSO 3: Próximos passos manuais..."
echo "======================================"
echo ""
echo "1. 📤 Envie o arquivo 'certificado_renovacao.csr' para a CA do cliente"
echo "2. 📥 Aguarde o novo certificado (.crt ou .pem)"
echo "3. 🔍 Verifique o certificado com os comandos abaixo:"
echo ""
echo "   # Verificar data de validade:"
echo "   openssl x509 -in certificado_novo.crt -text -noout | grep \"Not After\""
echo ""
echo "   # Verificar se a chave privada corresponde:"
echo "   openssl x509 -noout -modulus -in certificado_novo.crt | openssl md5"
echo "   openssl rsa -noout -modulus -in certificado.key | openssl md5"
echo ""
echo "4. 📤 Faça upload no Business Manager (BM) do SFCC"
echo "5. 🧪 Teste o certificado no site"
echo ""

# Mostrar conteúdo do CSR para copiar
echo "📋 CONTEÚDO DO CSR (copie e cole na CA):"
echo "========================================"
echo ""
cat certificado_renovacao.csr
echo ""
echo "========================================"

echo ""
echo "✅ Script concluído!"
echo "📄 Consulte a documentação completa: Renovacao_Certificado_SSL_SFCC.docx"
echo ""
