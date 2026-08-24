USE farma_market;

CREATE TABLE IF NOT EXISTS detalhes_produtos (
  produto_id BIGINT UNSIGNED PRIMARY KEY,
  volume VARCHAR(80) NULL,
  concentracao VARCHAR(120) NULL,
  genero_publico VARCHAR(100) NULL,
  notas_saida VARCHAR(500) NULL,
  notas_corpo VARCHAR(500) NULL,
  notas_fundo VARCHAR(500) NULL,
  destaque_1 VARCHAR(180) NULL,
  destaque_2 VARCHAR(180) NULL,
  destaque_3 VARCHAR(180) NULL,
  destaque_4 VARCHAR(180) NULL,
  CONSTRAINT fk_detalhes_produto FOREIGN KEY (produto_id) REFERENCES produtos(id) ON DELETE CASCADE
) ENGINE=InnoDB;
