USE farma_market;
SET NAMES utf8mb4;

INSERT INTO usuarios (nome,email,senha_hash,perfil,telefone,cpf) VALUES
('João Almeida','joao@farma.local','$2b$12$DdQoydPJebvzzTRmeRbgxOBdisB5geT8y9NWDQvm4rqs9f4OXQswi','consumidor','(11) 98888-1122','123.456.789-00'),
('Ana Farmacêutica','ana@farma.local','$2b$12$DdQoydPJebvzzTRmeRbgxOBdisB5geT8y9NWDQvm4rqs9f4OXQswi','vendedor','(11) 97777-3344',NULL);

INSERT INTO farmacias (proprietario_id,nome,descricao,cnpj,telefone,email,endereco,cidade,estado,cep,horario_funcionamento,informacao_entrega,avaliacao,verificada) VALUES
((SELECT id FROM usuarios WHERE email='ana@farma.local'),'Farmácia Saúde & Vida','Atendimento farmacêutico, medicamentos e cuidados para toda a família.','98.765.432/0001-10','(11) 97777-3344','contato@saudeevida.local','Avenida Paulista, 1500','São Paulo','SP','01310-200','Todos os dias, das 7h às 23h','Entrega no mesmo dia para a região central',4.8,TRUE);

INSERT INTO produtos (farmacia_id,categoria_id,tipo_medicamento_id,marca_id,nome,descricao,dosagem,apresentacao,preco,preco_anterior,estoque,avaliacao,quantidade_avaliacoes) VALUES
(1,1,1,1,'Dipirona Sódica','Analgésico e antitérmico para alívio de dores e febre.','500 mg','Caixa com 20 comprimidos',12.90,15.90,45,4.8,87),
(1,1,3,2,'Loratadina','Antialérgico indicado para sintomas de rinite e alergias.','10 mg','Caixa com 12 comprimidos',18.50,NULL,16,4.7,62),
(1,3,6,3,'Protetor Solar FPS 70','Proteção facial contra raios UVA e UVB.','50 g','Frasco com 50 gramas',59.90,69.90,12,4.9,143),
(1,5,6,4,'Kit Higiene Bucal','Escova macia, creme dental e fio dental.','Kit','Embalagem com 3 itens',19.90,NULL,38,4.6,41),
(2,1,2,5,'Ibuprofeno','Anti-inflamatório para alívio temporário de dores.','400 mg','Caixa com 10 cápsulas',22.90,26.50,31,4.7,74),
(2,2,5,6,'Vitamina D3','Suplemento alimentar de vitamina D.','2000 UI','Frasco com 60 cápsulas',39.90,44.90,24,4.8,96),
(2,4,6,7,'Fraldas Premium M','Fraldas infantis com proteção prolongada.','Tamanho M','Pacote com 48 unidades',74.50,89.90,20,4.7,54),
(2,3,6,7,'Shampoo Nutritivo','Limpeza suave para cabelos ressecados.','350 ml','Frasco com 350 ml',26.90,NULL,27,4.6,71);

INSERT INTO enderecos (usuario_id,identificacao,destinatario,logradouro,numero,complemento,bairro,cidade,estado,cep,principal) VALUES
((SELECT id FROM usuarios WHERE email='joao@farma.local'),'Trabalho','João Almeida','Avenida Brigadeiro Faria Lima','3200','8º andar','Itaim Bibi','São Paulo','SP','04538-132',TRUE);

INSERT INTO pedidos (consumidor_id,farmacia_id,endereco_id,forma_pagamento,total,situacao,criado_em) VALUES
(1,1,1,'pix',47.80,'novo',NOW() - INTERVAL 20 MINUTE),
(1,1,1,'cartao_credito',59.90,'preparando',NOW() - INTERVAL 2 HOUR),
((SELECT id FROM usuarios WHERE email='joao@farma.local'),2,(SELECT id FROM enderecos WHERE usuario_id=(SELECT id FROM usuarios WHERE email='joao@farma.local') LIMIT 1),'pix',62.80,'enviado',NOW() - INTERVAL 1 DAY),
((SELECT id FROM usuarios WHERE email='joao@farma.local'),2,(SELECT id FROM enderecos WHERE usuario_id=(SELECT id FROM usuarios WHERE email='joao@farma.local') LIMIT 1),'cartao_debito',74.50,'concluido',NOW() - INTERVAL 4 DAY);

INSERT INTO itens_pedido (pedido_id,produto_id,nome_produto,preco_unitario,quantidade) VALUES
(1,1,'Vitamina C 1000mg',34.90,1),(1,3,'Dipirona Sódica',12.90,1),
(2,5,'Protetor Solar FPS 70',59.90,1),
(3,7,'Ibuprofeno',22.90,1),(3,8,'Vitamina D3',39.90,1),
(4,9,'Fraldas Premium M',74.50,1);

INSERT IGNORE INTO favoritos (usuario_id,produto_id) VALUES
(1,3),(1,5),
((SELECT id FROM usuarios WHERE email='joao@farma.local'),7),
((SELECT id FROM usuarios WHERE email='joao@farma.local'),8);
