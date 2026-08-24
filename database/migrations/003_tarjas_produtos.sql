USE farma_market;

ALTER TABLE products
  ADD COLUMN sale_restriction ENUM('otc','red_no_retention','red_retention','black') NOT NULL DEFAULT 'otc' AFTER requires_prescription,
  ADD COLUMN is_generic BOOLEAN NOT NULL DEFAULT FALSE AFTER sale_restriction;

UPDATE products SET sale_restriction=IF(requires_prescription,'red_no_retention','otc');
