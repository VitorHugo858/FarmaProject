-- Conteúdo demonstrativo para validar o layout detalhado dos produtos.
-- Pode ser executado novamente sem duplicar registros.
USE farma_market;

UPDATE produtos SET descricao='Suplemento de vitamina C em comprimidos, desenvolvido para complementar a alimentação diária. Embalagem prática e adequada para integrar a rotina de cuidados e bem-estar.' WHERE id=1;
UPDATE produtos SET descricao='Protetor solar de alta proteção para uso diário, com textura confortável e aplicação uniforme. Auxilia na proteção da pele contra os efeitos da exposição aos raios UVA e UVB.' WHERE id=2;
UPDATE produtos SET descricao='Fraldas descartáveis com formato anatômico, barreiras antivazamento e camada de rápida absorção. Desenvolvidas para proporcionar conforto e liberdade de movimento ao bebê.' WHERE id=3;
UPDATE produtos SET descricao='Shampoo de limpeza suave para cabelos ressecados, com textura agradável e fragrância delicada. Desenvolvido para cuidar dos fios durante a rotina diária de higiene.' WHERE id=4;
UPDATE produtos SET descricao='Suplemento alimentar de óleo de peixe em cápsulas, fonte de ômega 3. Embalagem compacta para facilitar a organização e o consumo conforme orientação profissional.' WHERE id=5;
UPDATE produtos SET descricao='Kit essencial para a rotina de higiene bucal, composto por escova de cerdas macias, creme dental e fio dental. Uma solução prática para cuidados diários em casa ou em viagens.' WHERE id=6;
UPDATE produtos SET descricao='Um perfume feminino sofisticado e envolvente, que combina elegância e sensualidade em cada borrifada. Sua fragrância marcante traduz confiança, feminilidade e presença, perfeita para todas as ocasiões.' WHERE id=7;
UPDATE produtos SET descricao='Produto demonstrativo em comprimidos, apresentado em embalagem compacta e prática. Consulte sempre as informações da embalagem e siga a orientação de um profissional de saúde.' WHERE id=8;

INSERT INTO detalhes_produtos (produto_id,volume,concentracao,genero_publico,notas_saida,notas_corpo,notas_fundo,destaque_1,destaque_2,destaque_3,destaque_4) VALUES
(1,'30 comprimidos','1000 mg por comprimido','Adulto',NULL,NULL,NULL,'Embalagem prática para a rotina','Comprimidos fáceis de armazenar','Suplementação diária','Produto de demonstração para catálogo'),
(2,'50 g','FPS 70','Todos os tipos de pele',NULL,NULL,NULL,'Alta proteção solar','Textura confortável','Uso diário','Embalagem compacta'),
(3,'Pacote com 48 unidades','Tamanho M','Bebês',NULL,NULL,NULL,'Barreiras antivazamento','Camada de rápida absorção','Formato anatômico','Toque suave'),
(4,'350 ml','Limpeza nutritiva','Cabelos ressecados','Notas frescas e herbais','Acorde floral suave','Fundo cremoso', 'Limpeza suave','Cuidado diário dos fios','Fragrância delicada','Frasco com válvula pump'),
(5,'60 cápsulas','1000 mg por cápsula','Adulto',NULL,NULL,NULL,'Cápsulas softgel','Embalagem compacta','Fácil organização na rotina','Fonte de ômega 3'),
(6,'Kit com 3 itens','Uso diário','Adulto',NULL,NULL,NULL,'Escova de cerdas macias','Creme dental refrescante','Fio dental compacto','Ideal para casa ou viagem'),
(7,'100 ml','Eau de Parfum','Feminino','Bergamota, pêra e frutas vermelhas','Jasmim, rosa e flor de laranjeira','Baunilha, âmbar, patchouli e musk','Fragrância marcante e duradoura','Fixação prolongada na pele','Ideal para o dia e para a noite','Frasco elegante e sofisticado'),
(8,'Caixa com 10 comprimidos','Apresentação demonstrativa','Adulto',NULL,NULL,NULL,'Embalagem compacta','Comprimidos em blister','Informações organizadas no catálogo','Uso conforme orientação profissional')
ON DUPLICATE KEY UPDATE volume=VALUES(volume),concentracao=VALUES(concentracao),genero_publico=VALUES(genero_publico),notas_saida=VALUES(notas_saida),notas_corpo=VALUES(notas_corpo),notas_fundo=VALUES(notas_fundo),destaque_1=VALUES(destaque_1),destaque_2=VALUES(destaque_2),destaque_3=VALUES(destaque_3),destaque_4=VALUES(destaque_4);
