# Instalação do Farma&Farma em outra máquina

## Requisitos

- Node.js 20 ou superior
- XAMPP com MariaDB/MySQL ativo
- npm

## 1. Preparar o banco

1. Inicie o MySQL pelo painel do XAMPP.
2. Abra `http://localhost/phpmyadmin`.
3. Acesse a aba **Importar**.
4. Selecione `database/dump_teste_farma_market.sql`.
5. Confirme a importação.
6. Importe também `database/migrations/005_vendas_balcao.sql` para habilitar o cadastro de vendas pelo vendedor.

O dump cria o banco `farma_market`, suas tabelas, views e dados de teste.

## 2. Configurar o projeto

Na pasta do projeto, copie `.env.example` para `.env`:

```powershell
Copy-Item .env.example .env
```

Se o usuário ou a senha do MariaDB forem diferentes, edite o novo arquivo `.env`.

## 3. Instalar e executar

```powershell
npm install
npm run dev:all
```

## Integração com WhatsApp

O painel do vendedor usa o backend `manager-aichat`, configurado por padrão em `http://127.0.0.1:3003`.

Se os dois projetos estiverem nas pastas esperadas e nenhuma instância estiver aberta, execute:

```powershell
npm run dev:integrado
```

Se o `manager-aichat` já estiver rodando, mantenha-o aberto e use apenas:

```powershell
npm run dev:all
```

O endereço do serviço pode ser alterado pela variável `WHATSAPP_API_URL` no `.env`.

Acesse no computador:

```text
http://localhost:5173
```

Para acessar por outro dispositivo na mesma rede, use o endereço `Network` mostrado pelo Vite.

## Contas de teste

Todas utilizam a senha `123456`.

```text
Consumidores:
marina@farma.local
joao@farma.local

Vendedores:
vendedor@farma.local
ana@farma.local
```

## Gerar versão de produção

```powershell
npm run build
```

Os arquivos serão gerados na pasta `dist`.
