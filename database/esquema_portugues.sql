DROP DATABASE IF EXISTS farma_market;
CREATE DATABASE farma_market CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE farma_market;

CREATE TABLE usuarios (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, nome VARCHAR(120) NOT NULL, email VARCHAR(190) NOT NULL UNIQUE,
 senha_hash VARCHAR(255) NOT NULL, perfil ENUM('consumidor','vendedor','administrador') NOT NULL,
 telefone VARCHAR(30), cpf VARCHAR(20) UNIQUE, ativo BOOLEAN NOT NULL DEFAULT TRUE,
 criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP, atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE farmacias (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, proprietario_id BIGINT UNSIGNED NOT NULL, nome VARCHAR(150) NOT NULL,
 descricao TEXT, cnpj VARCHAR(25) UNIQUE, telefone VARCHAR(30), email VARCHAR(190), endereco VARCHAR(255), cidade VARCHAR(100),
 estado CHAR(2), cep VARCHAR(12), horario_funcionamento VARCHAR(180), informacao_entrega VARCHAR(180),
 foto_perfil_url VARCHAR(500), imagem_capa_url VARCHAR(500), avaliacao DECIMAL(2,1) DEFAULT 5.0,
 verificada BOOLEAN DEFAULT FALSE, ativa BOOLEAN DEFAULT TRUE, criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 CONSTRAINT fk_farmacia_proprietario FOREIGN KEY(proprietario_id) REFERENCES usuarios(id)
) ENGINE=InnoDB;

CREATE TABLE categorias (id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,nome VARCHAR(80) NOT NULL,slug VARCHAR(90) NOT NULL UNIQUE) ENGINE=InnoDB;
CREATE TABLE tipos_medicamento (id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,nome VARCHAR(100) NOT NULL UNIQUE,descricao VARCHAR(500),ativo BOOLEAN DEFAULT TRUE) ENGINE=InnoDB;
CREATE TABLE marcas (id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,nome VARCHAR(120) NOT NULL UNIQUE,fabricante VARCHAR(150),ativa BOOLEAN DEFAULT TRUE) ENGINE=InnoDB;

CREATE TABLE produtos (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, farmacia_id BIGINT UNSIGNED NOT NULL, categoria_id INT UNSIGNED NOT NULL,
 tipo_medicamento_id INT UNSIGNED, marca_id INT UNSIGNED, nome VARCHAR(180) NOT NULL, descricao TEXT NOT NULL,
 dosagem VARCHAR(80), apresentacao VARCHAR(120), exige_receita BOOLEAN DEFAULT FALSE,
 restricao_venda ENUM('livre','vermelha_sem_retencao','vermelha_com_retencao','preta') DEFAULT 'livre',
 generico BOOLEAN DEFAULT FALSE, preco DECIMAL(10,2) NOT NULL, preco_anterior DECIMAL(10,2), estoque INT UNSIGNED DEFAULT 0,
 foto_url VARCHAR(500), avaliacao DECIMAL(2,1) DEFAULT 5.0, quantidade_avaliacoes INT UNSIGNED DEFAULT 0,
 ativo BOOLEAN DEFAULT TRUE, criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP, atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 INDEX idx_produto_farmacia(farmacia_id),INDEX idx_produto_categoria(categoria_id),INDEX idx_produto_tipo(tipo_medicamento_id),INDEX idx_produto_marca(marca_id),
 CONSTRAINT fk_produto_farmacia FOREIGN KEY(farmacia_id) REFERENCES farmacias(id),CONSTRAINT fk_produto_categoria FOREIGN KEY(categoria_id) REFERENCES categorias(id),
 CONSTRAINT fk_produto_tipo FOREIGN KEY(tipo_medicamento_id) REFERENCES tipos_medicamento(id),CONSTRAINT fk_produto_marca FOREIGN KEY(marca_id) REFERENCES marcas(id)
) ENGINE=InnoDB;

CREATE TABLE enderecos (id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,usuario_id BIGINT UNSIGNED NOT NULL,identificacao VARCHAR(50) DEFAULT 'Casa',destinatario VARCHAR(120),logradouro VARCHAR(180) NOT NULL,numero VARCHAR(20) NOT NULL,complemento VARCHAR(100),bairro VARCHAR(100) NOT NULL,cidade VARCHAR(100) NOT NULL,estado CHAR(2) NOT NULL,cep VARCHAR(12) NOT NULL,principal BOOLEAN DEFAULT FALSE,criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,CONSTRAINT fk_endereco_usuario FOREIGN KEY(usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE) ENGINE=InnoDB;
CREATE TABLE pedidos (id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,consumidor_id BIGINT UNSIGNED NOT NULL,farmacia_id BIGINT UNSIGNED NOT NULL,endereco_id BIGINT UNSIGNED,forma_pagamento ENUM('pix','cartao_credito','cartao_debito') NOT NULL,total DECIMAL(10,2) NOT NULL,situacao ENUM('novo','preparando','enviado','concluido','cancelado') DEFAULT 'novo',criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,CONSTRAINT fk_pedido_consumidor FOREIGN KEY(consumidor_id) REFERENCES usuarios(id),CONSTRAINT fk_pedido_farmacia FOREIGN KEY(farmacia_id) REFERENCES farmacias(id),CONSTRAINT fk_pedido_endereco FOREIGN KEY(endereco_id) REFERENCES enderecos(id) ON DELETE SET NULL) ENGINE=InnoDB;
CREATE TABLE itens_pedido (id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,pedido_id BIGINT UNSIGNED NOT NULL,produto_id BIGINT UNSIGNED,nome_produto VARCHAR(180) NOT NULL,preco_unitario DECIMAL(10,2) NOT NULL,quantidade INT UNSIGNED NOT NULL,CONSTRAINT fk_item_pedido FOREIGN KEY(pedido_id) REFERENCES pedidos(id) ON DELETE CASCADE,CONSTRAINT fk_item_produto FOREIGN KEY(produto_id) REFERENCES produtos(id) ON DELETE SET NULL) ENGINE=InnoDB;
CREATE TABLE favoritos (usuario_id BIGINT UNSIGNED NOT NULL,produto_id BIGINT UNSIGNED NOT NULL,criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,PRIMARY KEY(usuario_id,produto_id),CONSTRAINT fk_favorito_usuario FOREIGN KEY(usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,CONSTRAINT fk_favorito_produto FOREIGN KEY(produto_id) REFERENCES produtos(id) ON DELETE CASCADE) ENGINE=InnoDB;
CREATE TABLE vendas_balcao (id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,farmacia_id BIGINT UNSIGNED NOT NULL,produto_id BIGINT UNSIGNED NULL,nome_produto VARCHAR(180),dosagem VARCHAR(80),restricao_venda VARCHAR(40),categoria VARCHAR(80),nome_cliente VARCHAR(180),preco DECIMAL(10,2),quantidade INT UNSIGNED,receita_url VARCHAR(500),criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,CONSTRAINT fk_venda_balcao_farmacia FOREIGN KEY(farmacia_id) REFERENCES farmacias(id),CONSTRAINT fk_venda_balcao_produto FOREIGN KEY(produto_id) REFERENCES produtos(id) ON DELETE SET NULL,INDEX idx_venda_balcao_farmacia(farmacia_id),INDEX idx_venda_balcao_criado_em(criado_em)) ENGINE=InnoDB;
CREATE TABLE detalhes_produtos (produto_id BIGINT UNSIGNED PRIMARY KEY,volume VARCHAR(80),concentracao VARCHAR(120),genero_publico VARCHAR(100),notas_saida VARCHAR(500),notas_corpo VARCHAR(500),notas_fundo VARCHAR(500),destaque_1 VARCHAR(180),destaque_2 VARCHAR(180),destaque_3 VARCHAR(180),destaque_4 VARCHAR(180),CONSTRAINT fk_detalhes_produto FOREIGN KEY(produto_id) REFERENCES produtos(id) ON DELETE CASCADE) ENGINE=InnoDB;

INSERT INTO categorias(nome,slug) VALUES ('Medicamentos','medicamentos'),('Vitaminas','vitaminas'),('Beleza','beleza'),('Mamãe & Bebê','mamae-bebe'),('Higiene','higiene');
INSERT INTO tipos_medicamento(nome,descricao) VALUES ('Analgésico e antitérmico','Alívio de dores e febre.'),('Anti-inflamatório','Controle de inflamações.'),('Antialérgico','Controle de alergias.'),('Antibiótico','Tratamento de infecções bacterianas.'),('Suplemento vitamínico','Vitaminas e minerais.'),('Dermatológico','Uso na pele.');
INSERT INTO marcas(nome,fabricante) VALUES ('Medley','Sanofi Medley'),('Neo Química','Hypera Pharma'),('EMS','Grupo NC'),('Cimed','Grupo Cimed'),('Eurofarma','Eurofarma'),('Bayer','Bayer Brasil'),('Genérico','Diversos');
INSERT INTO usuarios(nome,email,senha_hash,perfil,telefone) VALUES ('Marina Costa','marina@farma.local','$2b$12$DdQoydPJebvzzTRmeRbgxOBdisB5geT8y9NWDQvm4rqs9f4OXQswi','consumidor','(11) 98765-4321'),('Vendedor Farma','vendedor@farma.local','$2b$12$DdQoydPJebvzzTRmeRbgxOBdisB5geT8y9NWDQvm4rqs9f4OXQswi','vendedor','(11) 99999-2020');
INSERT INTO farmacias(proprietario_id,nome,descricao,cnpj,telefone,email,endereco,cidade,estado,cep,horario_funcionamento,informacao_entrega,verificada) VALUES (2,'Vico And Farma','Cuidando da sua saúde com atendimento próximo e entrega rápida.','12.345.678/0001-90','(11) 99999-2020','contato@farmacia.local','Rua das Flores, 120','São Paulo','SP','01001-000','Segunda a sábado, das 8h às 21h','Entrega expressa em até 2 horas',TRUE);
INSERT INTO enderecos(usuario_id,identificacao,destinatario,logradouro,numero,complemento,bairro,cidade,estado,cep,principal) VALUES (1,'Casa','Marina Costa','Rua das Acácias','88','ap. 42','Vila Mariana','São Paulo','SP','04102-000',TRUE);
INSERT INTO produtos(farmacia_id,categoria_id,tipo_medicamento_id,marca_id,nome,descricao,dosagem,apresentacao,preco,preco_anterior,estoque,avaliacao,quantidade_avaliacoes) VALUES
(1,2,5,7,'Vitamina C 1000mg','Suplemento vitamínico com 30 comprimidos.','1000 mg','30 comprimidos',34.90,42.90,28,4.9,126),
(1,2,5,7,'Ômega 3 1000mg','Suplemento alimentar com 60 cápsulas.','1000 mg','60 cápsulas',45.90,NULL,8,4.9,103);

-- Remover estas visões após a conversão integral da API.
CREATE VIEW users AS SELECT id,nome name,email,senha_hash password_hash,CASE perfil WHEN 'consumidor' THEN 'consumer' WHEN 'vendedor' THEN 'seller' ELSE 'admin' END role,telefone phone,cpf,ativo active,criado_em created_at,atualizado_em updated_at FROM usuarios;
CREATE VIEW stores AS SELECT id,proprietario_id owner_id,nome name,descricao description,cnpj,telefone phone,email,endereco address,cidade city,estado state,cep zip_code,horario_funcionamento opening_hours,informacao_entrega delivery_info,foto_perfil_url logo_url,imagem_capa_url banner_url,avaliacao rating,verificada verified,ativa active,criado_em created_at,atualizado_em updated_at FROM farmacias;
CREATE VIEW categories AS SELECT id,nome name,slug FROM categorias;
CREATE VIEW medication_types AS SELECT id,nome name,descricao description,ativo active FROM tipos_medicamento;
CREATE VIEW brands AS SELECT id,nome name,fabricante manufacturer,ativa active FROM marcas;
CREATE VIEW products AS SELECT id,farmacia_id store_id,categoria_id category_id,tipo_medicamento_id medication_type_id,marca_id brand_id,nome name,descricao description,dosagem dosage,apresentacao presentation,exige_receita requires_prescription,CASE restricao_venda WHEN 'livre' THEN 'otc' WHEN 'vermelha_sem_retencao' THEN 'red_no_retention' WHEN 'vermelha_com_retencao' THEN 'red_retention' ELSE 'black' END sale_restriction,generico is_generic,preco price,preco_anterior old_price,estoque stock,foto_url image_url,avaliacao rating,quantidade_avaliacoes review_count,ativo active,criado_em created_at,atualizado_em updated_at FROM produtos;
CREATE VIEW addresses AS SELECT id,usuario_id user_id,identificacao label,destinatario recipient,logradouro street,numero number,complemento complement,bairro district,cidade city,estado state,cep zip_code,principal is_default,criado_em created_at FROM enderecos;
CREATE VIEW orders AS SELECT id,consumidor_id consumer_id,farmacia_id store_id,endereco_id address_id,CASE forma_pagamento WHEN 'cartao_credito' THEN 'credit_card' WHEN 'cartao_debito' THEN 'debit_card' ELSE 'pix' END payment_method,total,CASE situacao WHEN 'novo' THEN 'new' WHEN 'preparando' THEN 'preparing' WHEN 'enviado' THEN 'shipped' WHEN 'concluido' THEN 'completed' ELSE 'cancelled' END status,criado_em created_at,atualizado_em updated_at FROM pedidos;
CREATE VIEW order_items AS SELECT id,pedido_id order_id,produto_id product_id,nome_produto product_name,preco_unitario unit_price,quantidade quantity FROM itens_pedido;
CREATE VIEW favorites AS SELECT usuario_id user_id,produto_id product_id,criado_em created_at FROM favoritos;
