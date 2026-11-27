-- Inclui destilados para exibição no catálogo, com compra indisponível.
INSERT INTO produtos (id_categoria, nome, descricao, tipo_medida, preco_unitario, estoque_qtd, imagem_url, destaque)
SELECT c.id_categoria, p.nome, p.descricao, 'UN', 0, 0,
       CONCAT('/assets/images/produto-bebidas-', p.foto, '.jpg'), 0
FROM categorias c
CROSS JOIN (
    SELECT 'Whisky Johnnie Walker Red Label (Garrafa 1L)' AS nome, 'Whisky Johnnie Walker Red Label. Garrafa de 1 L.' AS descricao, 'red-label-1l' AS foto UNION ALL
    SELECT 'Whisky Johnnie Walker Black Label 12 Anos (Garrafa 750ml)', 'Whisky Johnnie Walker Black Label 12 Anos. Garrafa de 750 ml.', 'black-label-750ml' UNION ALL
    SELECT 'Whisky Jack Daniel''s Old No. 7 Tennessee (Garrafa 1L)', 'Whisky Jack Daniel''s Old No. 7 Tennessee. Garrafa de 1 L.', 'jack-daniels-1l' UNION ALL
    SELECT 'Whisky Ballantine''s Finest (Garrafa 1L)', 'Whisky Ballantine''s Finest. Garrafa de 1 L.', 'ballantines-1l' UNION ALL
    SELECT 'Whisky Chivas Regal 12 Anos (Garrafa 750ml)', 'Whisky Chivas Regal 12 Anos. Garrafa de 750 ml.', 'chivas-750ml' UNION ALL
    SELECT 'Whisky White Horse (Garrafa 1L)', 'Whisky White Horse. Garrafa de 1 L.', 'white-horse-1l' UNION ALL
    SELECT 'Gin Tanqueray London Dry (Garrafa 750ml)', 'Gin Tanqueray London Dry. Garrafa de 750 ml.', 'tanqueray-750ml' UNION ALL
    SELECT 'Gin Beefeater London Dry (Garrafa 750ml)', 'Gin Beefeater London Dry. Garrafa de 750 ml.', 'beefeater-750ml' UNION ALL
    SELECT 'Gin Gordon''s London Dry (Garrafa 750ml)', 'Gin Gordon''s London Dry. Garrafa de 750 ml.', 'gordons-750ml' UNION ALL
    SELECT 'Gin Bombay Sapphire (Garrafa 750ml)', 'Gin Bombay Sapphire. Garrafa de 750 ml.', 'bombay-750ml' UNION ALL
    SELECT 'Gin Rock''s Strawberry (Garrafa 1L)', 'Gin Rock''s Strawberry. Garrafa de 1 L.', 'rocks-strawberry-1l' UNION ALL
    SELECT 'Gin Seagers (Garrafa 980ml)', 'Gin Seagers. Garrafa de 980 ml.', 'seagers-980ml'
) p
WHERE c.slug = 'bebidas'
  AND NOT EXISTS (
      SELECT 1 FROM produtos existente
      WHERE existente.id_categoria = c.id_categoria AND existente.nome = p.nome
  );
