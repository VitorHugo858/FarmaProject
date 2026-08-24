-- Dados descritivos para a view vw_produto_contexto_ia.
-- Compatível com MariaDB/phpMyAdmin e seguro para executar novamente.
USE farma_market;
SET NAMES utf8mb4;
START TRANSACTION;

-- Descrições oficiais ampliadas.
UPDATE produtos SET descricao='Suplemento alimentar de vitamina C em comprimidos de 1000 mg, desenvolvido para complementar a ingestão diária desse nutriente. A embalagem com 30 comprimidos é compacta e prática para organizar a rotina. O produto não substitui uma alimentação equilibrada e deve ser utilizado conforme o rótulo ou a orientação de profissional habilitado.' WHERE nome='Vitamina C 1000mg';
UPDATE produtos SET descricao='Protetor solar de alta proteção FPS 70 para uso diário. Auxilia na proteção da pele contra os efeitos da radiação UVA e UVB, possui aplicação uniforme e embalagem de fácil transporte. Deve ser aplicado antes da exposição ao sol e reaplicado conforme as instruções do fabricante, especialmente após contato com água ou transpiração.' WHERE nome='Protetor Solar FPS 70';
UPDATE produtos SET descricao='Fraldas descartáveis tamanho M desenvolvidas para oferecer conforto ao bebê durante o dia e a noite. Contam com formato anatômico, camada de rápida absorção, toque suave e barreiras laterais que auxiliam na prevenção de vazamentos. Confira na embalagem a faixa de peso recomendada e as instruções de uso.' WHERE nome='Fraldas Premium M';
UPDATE produtos SET descricao='Shampoo nutritivo indicado para a limpeza cotidiana de cabelos ressecados ou com aparência opaca. Sua fórmula demonstrativa combina limpeza suave, textura agradável e fragrância delicada, ajudando a manter os fios limpos e bem cuidados sem sensação pesada. A embalagem de 350 ml é adequada para uso frequente.' WHERE nome='Shampoo Nutritivo';
UPDATE produtos SET descricao='Suplemento alimentar à base de óleo de peixe em cápsulas softgel de 1000 mg. O frasco com 60 cápsulas facilita o armazenamento e a organização do consumo diário. A suplementação deve respeitar as informações do rótulo e a orientação de nutricionista, médico ou outro profissional habilitado.' WHERE nome='Ômega 3 1000mg';
UPDATE produtos SET descricao='Kit para higiene bucal composto por escova de cerdas macias, creme dental e fio dental. Reúne itens essenciais para a limpeza dos dentes e dos espaços interdentais, sendo uma opção prática para manter em casa, no trabalho ou durante viagens. Utilize cada item de acordo com as instruções da embalagem.' WHERE nome='Kit Higiene Bucal';
UPDATE produtos SET descricao='Perfume feminino de perfil sofisticado e envolvente, com construção olfativa frutada, floral e ambarada. A abertura combina bergamota, pêra e frutas vermelhas; o corpo apresenta jasmim, rosa e flor de laranjeira; e o fundo reúne baunilha, âmbar, patchouli e musk. Uma fragrância demonstrativa versátil para ocasiões diurnas e noturnas.' WHERE nome='Perfume';
UPDATE produtos SET descricao='Produto farmacêutico demonstrativo em comprimidos, apresentado em embalagem compacta com blister para facilitar a organização e o armazenamento. As informações deste item destinam-se à validação do catálogo. Antes de utilizar qualquer medicamento, confira a embalagem e a bula e procure orientação de médico ou farmacêutico.' WHERE nome='Relaxym';

-- Aliases melhoram buscas por abreviações, grafias alternativas e termos populares.
INSERT IGNORE INTO produto_aliases (produto_id,alias,alias_normalizado,ativo)
SELECT id,alias,alias_normalizado,TRUE FROM produtos JOIN (
 SELECT 'Vitamina C 1000mg' produto,'Vitamina C' alias,'vitamina c' alias_normalizado UNION ALL
 SELECT 'Vitamina C 1000mg','Ácido ascórbico','acido ascorbico' UNION ALL
 SELECT 'Protetor Solar FPS 70','Protetor FPS 70','protetor fps 70' UNION ALL
 SELECT 'Protetor Solar FPS 70','Filtro solar','filtro solar' UNION ALL
 SELECT 'Fraldas Premium M','Fralda tamanho M','fralda tamanho m' UNION ALL
 SELECT 'Fraldas Premium M','Fralda infantil M','fralda infantil m' UNION ALL
 SELECT 'Shampoo Nutritivo','Shampoo para cabelo ressecado','shampoo para cabelo ressecado' UNION ALL
 SELECT 'Ômega 3 1000mg','Omega 3','omega 3' UNION ALL
 SELECT 'Ômega 3 1000mg','Óleo de peixe','oleo de peixe' UNION ALL
 SELECT 'Kit Higiene Bucal','Kit dental','kit dental' UNION ALL
 SELECT 'Kit Higiene Bucal','Escova creme e fio dental','escova creme e fio dental' UNION ALL
 SELECT 'Perfume','Perfume feminino','perfume feminino' UNION ALL
 SELECT 'Relaxym','Relaxim','relaxim'
) dados ON dados.produto=produtos.nome;

-- Atributos factuais utilizados pela IA. Todos têm fonte identificada.
INSERT INTO produto_atributos (produto_id,nome,valor,unidade,verificado,fonte)
SELECT p.id,d.nome,d.valor,d.unidade,TRUE,'catálogo demonstrativo Farma&Farma' FROM produtos p JOIN (
 SELECT 'Vitamina C 1000mg' produto,'conteudo_embalagem' nome,'30' valor,'comprimidos' unidade UNION ALL
 SELECT 'Protetor Solar FPS 70','fator_protecao','70','FPS' UNION ALL
 SELECT 'Protetor Solar FPS 70','uso','facial e corporal',NULL UNION ALL
 SELECT 'Fraldas Premium M','tamanho','M',NULL UNION ALL
 SELECT 'Fraldas Premium M','conteudo_embalagem','48','unidades' UNION ALL
 SELECT 'Shampoo Nutritivo','volume','350','ml' UNION ALL
 SELECT 'Shampoo Nutritivo','tipo_cabelo','ressecados ou opacos',NULL UNION ALL
 SELECT 'Ômega 3 1000mg','conteudo_embalagem','60','cápsulas' UNION ALL
 SELECT 'Kit Higiene Bucal','conteudo_embalagem','3','itens' UNION ALL
 SELECT 'Perfume','volume','100','ml' UNION ALL
 SELECT 'Perfume','publico','feminino',NULL UNION ALL
 SELECT 'Relaxym','apresentacao','caixa com blister',NULL
) d ON d.produto=p.nome
ON DUPLICATE KEY UPDATE unidade=VALUES(unidade),verificado=TRUE,fonte=VALUES(fonte);

-- Textos aprovados exibidos em claims_aprovados. Remoção por fonte evita duplicação.
DELETE pc FROM produto_claims pc INNER JOIN produtos p ON p.id=pc.produto_id WHERE pc.fonte='dump descritivo contexto IA v1';
INSERT INTO produto_claims (produto_id,texto,tipo,aprovado,aprovado_em,fonte)
SELECT p.id,d.texto,d.tipo,TRUE,NOW(3),'dump descritivo contexto IA v1' FROM produtos p JOIN (
 SELECT 'Vitamina C 1000mg' produto,'Embalagem prática com 30 comprimidos para complementar a rotina de suplementação.' texto,'comercial' tipo UNION ALL
 SELECT 'Vitamina C 1000mg','Utilizar conforme o rótulo ou orientação profissional.','seguranca' UNION ALL
 SELECT 'Protetor Solar FPS 70','Alta proteção FPS 70 e auxílio contra os efeitos dos raios UVA e UVB.','comercial' UNION ALL
 SELECT 'Protetor Solar FPS 70','Reaplicação necessária conforme as instruções do fabricante.','seguranca' UNION ALL
 SELECT 'Fraldas Premium M','Formato anatômico, toque suave e barreiras laterais antivazamento.','comercial' UNION ALL
 SELECT 'Shampoo Nutritivo','Limpeza suave para cabelos ressecados ou com aparência opaca.','comercial' UNION ALL
 SELECT 'Ômega 3 1000mg','Cápsulas softgel em frasco compacto com 60 unidades.','comercial' UNION ALL
 SELECT 'Ômega 3 1000mg','Suplementação conforme rótulo ou orientação profissional.','seguranca' UNION ALL
 SELECT 'Kit Higiene Bucal','Escova, creme dental e fio dental reunidos em um kit prático.','comercial' UNION ALL
 SELECT 'Perfume','Perfil olfativo frutado, floral e ambarado para ocasiões diurnas e noturnas.','comercial' UNION ALL
 SELECT 'Relaxym','Produto demonstrativo; o uso real de medicamentos exige leitura da bula e orientação profissional.','seguranca'
) d ON d.produto=p.nome;

COMMIT;

-- Recria a view para refletir o contexto enriquecido.
CREATE OR REPLACE VIEW vw_produto_contexto_ia AS
SELECT p.id produto_id,p.nome nome_oficial,p.descricao descricao_oficial,c.nome categoria,m.nome marca,m.fabricante fabricante,tm.nome tipo_medicamento,p.apresentacao,p.dosagem,
 (SELECT GROUP_CONCAT(pa.alias ORDER BY pa.alias SEPARATOR ' | ') FROM produto_aliases pa WHERE pa.produto_id=p.id AND pa.ativo=TRUE) aliases,
 (SELECT GROUP_CONCAT(CONCAT(pat.nome,': ',pat.valor,IF(pat.unidade IS NULL OR pat.unidade='','',CONCAT(' ',pat.unidade))) ORDER BY pat.nome,pat.valor SEPARATOR ' | ') FROM produto_atributos pat WHERE pat.produto_id=p.id AND pat.verificado=TRUE) atributos_verificados,
 (SELECT GROUP_CONCAT(pc.texto ORDER BY pc.id SEPARATOR ' | ') FROM produto_claims pc WHERE pc.produto_id=p.id AND pc.aprovado=TRUE) claims_aprovados,
 f.nome farmacia,p.preco,p.estoque,p.exige_receita,p.ativo,p.atualizado_em
FROM produtos p INNER JOIN categorias c ON c.id=p.categoria_id INNER JOIN farmacias f ON f.id=p.farmacia_id LEFT JOIN marcas m ON m.id=p.marca_id LEFT JOIN tipos_medicamento tm ON tm.id=p.tipo_medicamento_id;

-- Conferência após a importação:
SELECT produto_id,nome_oficial,descricao_oficial,aliases,atributos_verificados,claims_aprovados FROM vw_produto_contexto_ia ORDER BY produto_id;
