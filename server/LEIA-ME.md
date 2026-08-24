# Backend Farma&Farma

1. Inicie Apache e MySQL no painel do XAMPP.
2. Abra `http://localhost/phpmyadmin` e importe `database/esquema_portugues.sql`.
3. Copie `.env.example` para `.env` e ajuste as credenciais se necessário.
4. Execute `npm run server`.
5. Verifique em `http://localhost:3001/api/health`.

As rotas protegidas usam `Authorization: Bearer <token>`. Os produtos são públicos; perfil, pedidos e gestão da loja exigem autenticação.
