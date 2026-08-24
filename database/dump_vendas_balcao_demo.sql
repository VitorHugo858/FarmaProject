-- Dados demonstrativos para o BI de vendas de balcão.
-- Pode ser importado novamente: os registros DEMO anteriores são substituídos.
USE farma_market;

DELETE FROM vendas_balcao WHERE nome_cliente LIKE 'DEMO - %';

INSERT INTO vendas_balcao
  (farmacia_id,produto_id,nome_produto,dosagem,restricao_venda,categoria,nome_cliente,preco,quantidade,receita_url,criado_em)
SELECT p.farmacia_id,p.id,p.nome,p.dosagem,p.restricao_venda,c.nome,'DEMO - Ana Souza',p.preco,2,NULL,NOW()-INTERVAL 6 DAY FROM produtos p JOIN categorias c ON c.id=p.categoria_id WHERE p.id=1
UNION ALL SELECT p.farmacia_id,p.id,p.nome,p.dosagem,p.restricao_venda,c.nome,'DEMO - Carlos Lima',p.preco,1,NULL,NOW()-INTERVAL 6 DAY FROM produtos p JOIN categorias c ON c.id=p.categoria_id WHERE p.id=6
UNION ALL SELECT p.farmacia_id,p.id,p.nome,p.dosagem,p.restricao_venda,c.nome,'DEMO - Beatriz Alves',p.preco,1,NULL,NOW()-INTERVAL 5 DAY FROM produtos p JOIN categorias c ON c.id=p.categoria_id WHERE p.id=2
UNION ALL SELECT p.farmacia_id,p.id,p.nome,p.dosagem,p.restricao_venda,c.nome,'DEMO - Marcos Silva',p.preco,3,NULL,NOW()-INTERVAL 4 DAY FROM produtos p JOIN categorias c ON c.id=p.categoria_id WHERE p.id=5
UNION ALL SELECT p.farmacia_id,p.id,p.nome,p.dosagem,p.restricao_venda,c.nome,'DEMO - Júlia Costa',p.preco,1,NULL,NOW()-INTERVAL 4 DAY FROM produtos p JOIN categorias c ON c.id=p.categoria_id WHERE p.id=8
UNION ALL SELECT p.farmacia_id,p.id,p.nome,p.dosagem,p.restricao_venda,c.nome,'DEMO - Paulo Rocha',p.preco,2,NULL,NOW()-INTERVAL 3 DAY FROM produtos p JOIN categorias c ON c.id=p.categoria_id WHERE p.id=4
UNION ALL SELECT p.farmacia_id,p.id,p.nome,p.dosagem,p.restricao_venda,c.nome,'DEMO - Renata Melo',p.preco,1,NULL,NOW()-INTERVAL 3 DAY FROM produtos p JOIN categorias c ON c.id=p.categoria_id WHERE p.id=3
UNION ALL SELECT p.farmacia_id,p.id,p.nome,p.dosagem,p.restricao_venda,c.nome,'DEMO - Ricardo Nunes',p.preco,1,NULL,NOW()-INTERVAL 2 DAY FROM produtos p JOIN categorias c ON c.id=p.categoria_id WHERE p.id=7
UNION ALL SELECT p.farmacia_id,p.id,p.nome,p.dosagem,p.restricao_venda,c.nome,'DEMO - Camila Reis',p.preco,2,NULL,NOW()-INTERVAL 2 DAY FROM produtos p JOIN categorias c ON c.id=p.categoria_id WHERE p.id=1
UNION ALL SELECT p.farmacia_id,p.id,p.nome,p.dosagem,p.restricao_venda,c.nome,'DEMO - Diego Luz',p.preco,1,NULL,NOW()-INTERVAL 1 DAY FROM produtos p JOIN categorias c ON c.id=p.categoria_id WHERE p.id=6
UNION ALL SELECT p.farmacia_id,p.id,p.nome,p.dosagem,p.restricao_venda,c.nome,'DEMO - Larissa Dias',p.preco,2,NULL,NOW()-INTERVAL 1 DAY FROM produtos p JOIN categorias c ON c.id=p.categoria_id WHERE p.id=8
UNION ALL SELECT p.farmacia_id,p.id,p.nome,p.dosagem,p.restricao_venda,c.nome,'DEMO - Felipe Moraes',p.preco,1,NULL,NOW() FROM produtos p JOIN categorias c ON c.id=p.categoria_id WHERE p.id=2
UNION ALL SELECT p.farmacia_id,p.id,p.nome,p.dosagem,p.restricao_venda,c.nome,'DEMO - Sofia Martins',p.preco,2,NULL,NOW() FROM produtos p JOIN categorias c ON c.id=p.categoria_id WHERE p.id=5
UNION ALL SELECT p.farmacia_id,p.id,p.nome,p.dosagem,p.restricao_venda,c.nome,'DEMO - Bruno Teles',p.preco,1,NULL,NOW() FROM produtos p JOIN categorias c ON c.id=p.categoria_id WHERE p.id=7;
