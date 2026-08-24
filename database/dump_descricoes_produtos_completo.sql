-- Descrições demonstrativas completas para o catálogo Farma&Farma.
-- Script idempotente: pode ser executado novamente sem duplicar dados.
USE farma_market;

UPDATE produtos SET descricao='Suplemento alimentar de vitamina C em comprimidos de 1000 mg, desenvolvido para complementar a ingestão diária desse nutriente. A embalagem com 30 unidades é compacta, fácil de armazenar e adequada para organizar a rotina de suplementação. Utilize conforme as orientações presentes no rótulo ou de um profissional de saúde.' WHERE id=1;
UPDATE produtos SET descricao='Protetor solar FPS 70 para uso diário, desenvolvido para auxiliar na proteção da pele contra os efeitos da exposição aos raios UVA e UVB. Possui textura confortável, aplicação uniforme e embalagem compacta de 50 g, prática para levar na bolsa. Reaplique conforme as instruções do fabricante, especialmente após contato com água ou transpiração intensa.' WHERE id=2;
UPDATE produtos SET descricao='Fraldas descartáveis tamanho M com formato anatômico, camada de rápida absorção e barreiras laterais antivazamento. O toque suave e o ajuste confortável ajudam a proporcionar liberdade de movimento durante o dia e a noite. Pacote econômico com 48 unidades, indicado para bebês dentro da faixa de peso informada na embalagem.' WHERE id=3;
UPDATE produtos SET descricao='Shampoo nutritivo para a limpeza diária de cabelos ressecados ou com aparência opaca. Sua fórmula demonstrativa combina limpeza suave, textura agradável e fragrância delicada, ajudando a manter os fios limpos e bem cuidados sem pesar. O frasco de 350 ml possui válvula pump para facilitar a aplicação e evitar desperdícios.' WHERE id=4;
UPDATE produtos SET descricao='Suplemento alimentar à base de óleo de peixe, apresentado em cápsulas softgel de 1000 mg. A embalagem com 60 cápsulas é prática para organizar o consumo diário e preservar o produto. A suplementação deve respeitar as informações do rótulo e a orientação de nutricionista, médico ou outro profissional habilitado.' WHERE id=5;
UPDATE produtos SET descricao='Kit completo para a higiene bucal diária, composto por escova com cerdas macias, creme dental e fio dental em embalagem compacta. Reúne os itens essenciais para limpeza dos dentes e cuidado entre os espaços dentais. Ideal para manter em casa, levar ao trabalho ou utilizar durante viagens.' WHERE id=6;
UPDATE produtos SET descricao='Perfume feminino de perfil sofisticado e envolvente, criado para combinar frescor, elegância e presença. A abertura frutada de bergamota, pêra e frutas vermelhas evolui para um corpo floral de jasmim, rosa e flor de laranjeira. No fundo, baunilha, âmbar, patchouli e musk formam uma assinatura marcante, adequada para ocasiões diurnas e noturnas.' WHERE id=7;
UPDATE produtos SET descricao='Produto farmacêutico demonstrativo em comprimidos, apresentado em caixa com blister para facilitar o armazenamento e a organização. As informações exibidas servem exclusivamente para validação visual do catálogo. Antes do uso de qualquer medicamento, leia a bula, confira a embalagem e siga a orientação de médico ou farmacêutico.' WHERE id=8;

INSERT INTO detalhes_produtos
  (produto_id,volume,concentracao,genero_publico,notas_saida,notas_corpo,notas_fundo,destaque_1,destaque_2,destaque_3,destaque_4)
VALUES
  (1,'30 comprimidos','1000 mg por comprimido','Adultos',NULL,NULL,NULL,'Embalagem compacta com 30 unidades','Comprimidos de fácil armazenamento','Ideal para organizar a rotina diária','Uso conforme rótulo ou orientação profissional'),
  (2,'50 g','FPS 70','Todos os tipos de pele',NULL,NULL,NULL,'Auxilia na proteção UVA e UVB','Textura confortável para uso diário','Embalagem prática para levar na bolsa','Reaplicação conforme instruções do fabricante'),
  (3,'Pacote com 48 unidades','Tamanho M','Bebês',NULL,NULL,NULL,'Camada de rápida absorção','Barreiras laterais antivazamento','Formato anatômico e toque suave','Faixa de peso indicada na embalagem'),
  (4,'350 ml','Limpeza suave e nutritiva','Cabelos ressecados','Acorde fresco e herbal','Notas florais delicadas','Fundo cremoso e confortável','Limpeza diária sem sensação pesada','Válvula pump de fácil aplicação','Fragrância suave','Embalagem econômica de 350 ml'),
  (5,'60 cápsulas softgel','1000 mg por cápsula','Adultos',NULL,NULL,NULL,'Fonte demonstrativa de óleo de peixe','Cápsulas softgel','Frasco compacto com 60 unidades','Consumo conforme orientação profissional'),
  (6,'Kit com 3 itens','Uso diário','Adultos e adolescentes',NULL,NULL,NULL,'Escova com cerdas macias','Creme dental para limpeza diária','Fio dental em estojo compacto','Prático para casa, trabalho ou viagem'),
  (7,'100 ml','Eau de Parfum','Feminino','Bergamota, pêra e frutas vermelhas','Jasmim, rosa e flor de laranjeira','Baunilha, âmbar, patchouli e musk','Perfil olfativo marcante e sofisticado','Combinação frutada, floral e ambarada','Adequado para o dia e para a noite','Frasco decorativo de 100 ml'),
  (8,'Caixa com 10 comprimidos','Apresentação demonstrativa','Adultos',NULL,NULL,NULL,'Caixa compacta com blister','Informações organizadas para o catálogo','Conteúdo exclusivamente demonstrativo','Uso real somente com orientação profissional')
ON DUPLICATE KEY UPDATE
  volume=VALUES(volume),concentracao=VALUES(concentracao),genero_publico=VALUES(genero_publico),
  notas_saida=VALUES(notas_saida),notas_corpo=VALUES(notas_corpo),notas_fundo=VALUES(notas_fundo),
  destaque_1=VALUES(destaque_1),destaque_2=VALUES(destaque_2),destaque_3=VALUES(destaque_3),destaque_4=VALUES(destaque_4);
