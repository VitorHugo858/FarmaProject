USE farma_market;

CREATE TABLE IF NOT EXISTS vendas_balcao (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  farmacia_id BIGINT UNSIGNED NOT NULL,
  produto_id BIGINT UNSIGNED NULL,
  nome_produto VARCHAR(180) NULL,
  dosagem VARCHAR(80) NULL,
  restricao_venda VARCHAR(40) NULL,
  categoria VARCHAR(80) NULL,
  nome_cliente VARCHAR(180) NULL,
  preco DECIMAL(10,2) NULL,
  quantidade INT UNSIGNED NULL,
  receita_url VARCHAR(500) NULL,
  criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_venda_balcao_farmacia FOREIGN KEY (farmacia_id) REFERENCES farmacias(id),
  CONSTRAINT fk_venda_balcao_produto FOREIGN KEY (produto_id) REFERENCES produtos(id) ON DELETE SET NULL,
  INDEX idx_venda_balcao_farmacia (farmacia_id),
  INDEX idx_venda_balcao_criado_em (criado_em)
) ENGINE=InnoDB;
