-- Retira o creme dental genérico do catálogo sem apagar o histórico.
UPDATE produtos p
JOIN categorias c ON c.id_categoria = p.id_categoria
SET p.ativo = 0
WHERE c.slug = 'farmacia'
  AND p.nome = 'Creme dental'
  AND p.ativo = 1;
