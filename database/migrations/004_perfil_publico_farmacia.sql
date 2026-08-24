USE farma_market;

ALTER TABLE stores
  ADD COLUMN description TEXT NULL AFTER name,
  ADD COLUMN opening_hours VARCHAR(180) NULL AFTER zip_code,
  ADD COLUMN delivery_info VARCHAR(180) NULL AFTER opening_hours,
  ADD COLUMN banner_url VARCHAR(500) NULL AFTER logo_url;

UPDATE stores SET
  description='Cuidando da sua saúde com atendimento próximo, produtos selecionados e entrega rápida.',
  opening_hours='Segunda a sábado, das 8h às 21h',
  delivery_info='Entrega expressa em até 2 horas'
WHERE description IS NULL;
