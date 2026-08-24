USE farma_market;

CREATE TABLE IF NOT EXISTS medication_types (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  description VARCHAR(500),
  active BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS brands (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(120) NOT NULL UNIQUE,
  manufacturer VARCHAR(150),
  active BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

INSERT IGNORE INTO medication_types (name,description) VALUES
('Analgésico e antitérmico','Indicado para alívio de dores e controle da febre.'),
('Anti-inflamatório','Medicamentos utilizados no controle de processos inflamatórios.'),
('Antialérgico','Medicamentos para controle de sintomas alérgicos.'),
('Antibiótico','Medicamentos sujeitos a prescrição para infecções bacterianas.'),
('Suplemento vitamínico','Vitaminas, minerais e suplementos alimentares.'),
('Dermatológico','Produtos medicamentosos para uso na pele.');

INSERT IGNORE INTO brands (name,manufacturer) VALUES
('Medley','Sanofi Medley'),('Neo Química','Hypera Pharma'),('EMS','Grupo NC'),
('Cimed','Grupo Cimed'),('Eurofarma','Eurofarma Laboratórios'),('Bayer','Bayer Brasil'),
('Genérico','Diversos laboratórios');

ALTER TABLE products
  ADD COLUMN medication_type_id INT UNSIGNED NULL AFTER category_id,
  ADD COLUMN brand_id INT UNSIGNED NULL AFTER medication_type_id,
  ADD COLUMN dosage VARCHAR(80) NULL AFTER description,
  ADD COLUMN presentation VARCHAR(120) NULL AFTER dosage,
  ADD COLUMN requires_prescription BOOLEAN NOT NULL DEFAULT FALSE AFTER presentation,
  ADD INDEX idx_product_medication_type (medication_type_id),
  ADD INDEX idx_product_brand (brand_id),
  ADD CONSTRAINT fk_product_medication_type FOREIGN KEY (medication_type_id) REFERENCES medication_types(id),
  ADD CONSTRAINT fk_product_brand FOREIGN KEY (brand_id) REFERENCES brands(id);

UPDATE products SET medication_type_id=5,brand_id=7,dosage='1000 mg',presentation='30 comprimidos'
WHERE name='Vitamina C 1000mg' AND medication_type_id IS NULL;
UPDATE products SET medication_type_id=5,brand_id=7,dosage='1000 mg',presentation='60 cápsulas'
WHERE name='Ômega 3 1000mg' AND medication_type_id IS NULL;
