-- Associa as imagens geradas aos produtos do catálogo de demonstração.
USE farma_market;

UPDATE produtos SET foto_url='/uploads/produtos/catalogo-vitamina-c.png' WHERE id=1;
UPDATE produtos SET foto_url='/uploads/produtos/catalogo-protetor-solar.png' WHERE id=2;
UPDATE produtos SET foto_url='/uploads/produtos/catalogo-fraldas-premium.png' WHERE id=3;
UPDATE produtos SET foto_url='/uploads/produtos/catalogo-shampoo-nutritivo.png' WHERE id=4;
UPDATE produtos SET foto_url='/uploads/produtos/catalogo-omega-3.png' WHERE id=5;
UPDATE produtos SET foto_url='/uploads/produtos/catalogo-kit-higiene-bucal.png' WHERE id=6;
UPDATE produtos SET foto_url='/uploads/produtos/catalogo-perfume.png' WHERE id=7;
UPDATE produtos SET foto_url='/uploads/produtos/catalogo-relaxym.png' WHERE id=8;

UPDATE produtos SET descricao='Um perfume feminino sofisticado e envolvente, que combina elegância e sensualidade em cada borrifada. Sua fragrância marcante traduz confiança, feminilidade e presença, perfeita para todas as ocasiões.' WHERE id=7;
INSERT INTO detalhes_produtos (produto_id,volume,concentracao,genero_publico,notas_saida,notas_corpo,notas_fundo,destaque_1,destaque_2,destaque_3,destaque_4)
VALUES (7,'100 ml','Eau de Parfum','Feminino','Bergamota, pêra e frutas vermelhas','Jasmim, rosa e flor de laranjeira','Baunilha, âmbar, patchouli e musk','Fragrância marcante e duradoura','Fixação prolongada na pele','Ideal para o dia e para a noite','Frasco elegante e sofisticado')
ON DUPLICATE KEY UPDATE volume=VALUES(volume),concentracao=VALUES(concentracao),genero_publico=VALUES(genero_publico),notas_saida=VALUES(notas_saida),notas_corpo=VALUES(notas_corpo),notas_fundo=VALUES(notas_fundo),destaque_1=VALUES(destaque_1),destaque_2=VALUES(destaque_2),destaque_3=VALUES(destaque_3),destaque_4=VALUES(destaque_4);
