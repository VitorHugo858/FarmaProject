CREATE DATABASE IF NOT EXISTS farma_market CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE farma_market;

CREATE TABLE users (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  email VARCHAR(190) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('consumer','seller','admin') NOT NULL DEFAULT 'consumer',
  phone VARCHAR(30), cpf VARCHAR(20) UNIQUE, active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE stores (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, owner_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(150) NOT NULL, description TEXT, cnpj VARCHAR(25) UNIQUE, phone VARCHAR(30), email VARCHAR(190),
  address VARCHAR(255), city VARCHAR(100), state CHAR(2), zip_code VARCHAR(12), opening_hours VARCHAR(180), delivery_info VARCHAR(180), logo_url VARCHAR(500), banner_url VARCHAR(500),
  rating DECIMAL(2,1) NOT NULL DEFAULT 5.0, verified BOOLEAN NOT NULL DEFAULT FALSE, active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_store_owner FOREIGN KEY (owner_id) REFERENCES users(id)
) ENGINE=InnoDB;

CREATE TABLE categories (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, name VARCHAR(80) NOT NULL, slug VARCHAR(90) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE medication_types (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, name VARCHAR(100) NOT NULL UNIQUE,
  description VARCHAR(500), active BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

CREATE TABLE brands (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, name VARCHAR(120) NOT NULL UNIQUE,
  manufacturer VARCHAR(150), active BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

CREATE TABLE products (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, store_id BIGINT UNSIGNED NOT NULL, category_id INT UNSIGNED NOT NULL,
  medication_type_id INT UNSIGNED, brand_id INT UNSIGNED,
  name VARCHAR(180) NOT NULL, description TEXT, dosage VARCHAR(80), presentation VARCHAR(120), requires_prescription BOOLEAN NOT NULL DEFAULT FALSE,
  sale_restriction ENUM('otc','red_no_retention','red_retention','black') NOT NULL DEFAULT 'otc', is_generic BOOLEAN NOT NULL DEFAULT FALSE,
  price DECIMAL(10,2) NOT NULL, old_price DECIMAL(10,2),
  stock INT UNSIGNED NOT NULL DEFAULT 0, image_url VARCHAR(500), rating DECIMAL(2,1) NOT NULL DEFAULT 5.0,
  review_count INT UNSIGNED NOT NULL DEFAULT 0, active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_product_store (store_id), INDEX idx_product_category (category_id), INDEX idx_product_medication_type (medication_type_id), INDEX idx_product_brand (brand_id), INDEX idx_product_name (name),
  CONSTRAINT fk_product_store FOREIGN KEY (store_id) REFERENCES stores(id),
  CONSTRAINT fk_product_category FOREIGN KEY (category_id) REFERENCES categories(id),
  CONSTRAINT fk_product_medication_type FOREIGN KEY (medication_type_id) REFERENCES medication_types(id),
  CONSTRAINT fk_product_brand FOREIGN KEY (brand_id) REFERENCES brands(id)
) ENGINE=InnoDB;

CREATE TABLE addresses (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, user_id BIGINT UNSIGNED NOT NULL, label VARCHAR(50) DEFAULT 'Casa',
  recipient VARCHAR(120), street VARCHAR(180) NOT NULL, number VARCHAR(20) NOT NULL, complement VARCHAR(100),
  district VARCHAR(100) NOT NULL, city VARCHAR(100) NOT NULL, state CHAR(2) NOT NULL, zip_code VARCHAR(12) NOT NULL,
  is_default BOOLEAN DEFAULT FALSE, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_address_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE orders (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, consumer_id BIGINT UNSIGNED NOT NULL, store_id BIGINT UNSIGNED NOT NULL,
  address_id BIGINT UNSIGNED, payment_method ENUM('pix','credit_card','debit_card') NOT NULL,
  total DECIMAL(10,2) NOT NULL, status ENUM('new','preparing','shipped','completed','cancelled') NOT NULL DEFAULT 'new',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_order_consumer (consumer_id), INDEX idx_order_store (store_id), INDEX idx_order_status (status),
  CONSTRAINT fk_order_consumer FOREIGN KEY (consumer_id) REFERENCES users(id),
  CONSTRAINT fk_order_store FOREIGN KEY (store_id) REFERENCES stores(id),
  CONSTRAINT fk_order_address FOREIGN KEY (address_id) REFERENCES addresses(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE order_items (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, order_id BIGINT UNSIGNED NOT NULL, product_id BIGINT UNSIGNED,
  product_name VARCHAR(180) NOT NULL, unit_price DECIMAL(10,2) NOT NULL, quantity INT UNSIGNED NOT NULL,
  CONSTRAINT fk_item_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  CONSTRAINT fk_item_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE favorites (
  user_id BIGINT UNSIGNED NOT NULL, product_id BIGINT UNSIGNED NOT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY(user_id,product_id), CONSTRAINT fk_favorite_user FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_favorite_product FOREIGN KEY(product_id) REFERENCES products(id) ON DELETE CASCADE
) ENGINE=InnoDB;

INSERT INTO categories (name,slug) VALUES
('Medicamentos','medicamentos'),('Vitaminas','vitaminas'),('Beleza','beleza'),('Mamãe & Bebê','mamae-bebe'),('Higiene','higiene');
INSERT INTO medication_types (name,description) VALUES
('Analgésico e antitérmico','Alívio de dores e controle da febre.'),('Anti-inflamatório','Controle de processos inflamatórios.'),('Antialérgico','Controle de sintomas alérgicos.'),('Antibiótico','Medicamentos para infecções bacterianas.'),('Suplemento vitamínico','Vitaminas, minerais e suplementos.'),('Dermatológico','Medicamentos para uso na pele.');
INSERT INTO brands (name,manufacturer) VALUES
('Medley','Sanofi Medley'),('Neo Química','Hypera Pharma'),('EMS','Grupo NC'),('Cimed','Grupo Cimed'),('Eurofarma','Eurofarma Laboratórios'),('Bayer','Bayer Brasil'),('Genérico','Diversos laboratórios');

-- Senha das contas de demonstração: 123456
INSERT INTO users (name,email,password_hash,role,phone) VALUES
('Marina Costa','marina@farma.local','$2b$12$DdQoydPJebvzzTRmeRbgxOBdisB5geT8y9NWDQvm4rqs9f4OXQswi','consumer','(11) 98765-4321'),
('Vendedor Farma Vila','vendedor@farma.local','$2b$12$DdQoydPJebvzzTRmeRbgxOBdisB5geT8y9NWDQvm4rqs9f4OXQswi','seller','(11) 99999-2020');
INSERT INTO stores (owner_id,name,cnpj,phone,email,address,city,state,zip_code,verified) VALUES
(2,'Farma Vila','12.345.678/0001-90','(11) 99999-2020','contato@farmavila.com.br','Rua das Flores, 120 — Centro','São Paulo','SP','01001-000',TRUE);
INSERT INTO addresses (user_id,label,recipient,street,number,complement,district,city,state,zip_code,is_default) VALUES
(1,'Casa','Marina Costa','Rua das Acácias','88','ap. 42','Vila Mariana','São Paulo','SP','04102-000',TRUE);
INSERT INTO products (store_id,category_id,name,description,price,old_price,stock,rating,review_count) VALUES
(1,2,'Vitamina C 1000mg','Suplemento vitamínico com 30 comprimidos.',34.90,42.90,28,4.9,126),
(1,3,'Protetor Solar FPS 70','Alta proteção para todos os tipos de pele.',59.90,NULL,12,4.8,89),
(1,4,'Fraldas Premium M','Pacote econômico com alta absorção.',74.50,89.90,34,4.7,54),
(1,5,'Shampoo Nutritivo','Cuidado e nutrição diária para os cabelos.',26.90,NULL,19,4.6,71),
(1,2,'Ômega 3 1000mg','Suplemento alimentar com 60 cápsulas.',45.90,NULL,8,4.9,103),
(1,5,'Kit Higiene Bucal','Escova, creme dental e fio dental.',19.90,NULL,45,4.5,42);
