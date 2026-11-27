-- Retira a ração genérica do catálogo e preserva o histórico de pedidos.
UPDATE produtos p
JOIN categorias c ON c.id_categoria = p.id_categoria
SET p.ativo = 0
WHERE c.slug = 'pets'
  AND p.nome = 'Ração para cães 1kg'
  AND p.ativo = 1;
