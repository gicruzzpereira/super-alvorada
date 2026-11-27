-- Adiciona bebidas com fotos das embalagens. Bebidas alcoólicas ficam sem estoque para venda.
INSERT INTO produtos (id_categoria, nome, descricao, tipo_medida, preco_unitario, estoque_qtd, imagem_url, destaque)
SELECT c.id_categoria, p.nome, p.descricao, 'UN', p.preco, p.estoque,
       CONCAT('/assets/images/produto-bebidas-', p.foto, '.jpg'), 0
FROM categorias c
CROSS JOIN (
    SELECT 'Refrigerante Coca-Cola Original (Garrafa 2L)' AS nome, 'Refrigerante de cola, versão original. Garrafa de 2 L.' AS descricao, 10.99 AS preco, 36 AS estoque, 'coca-cola-original-2l' AS foto UNION ALL
    SELECT 'Refrigerante Coca-Cola Zero Açúcar (Garrafa 2L)', 'Refrigerante de cola sem açúcar. Garrafa de 2 L.', 10.99, 36, 'coca-cola-zero-2l' UNION ALL
    SELECT 'Refrigerante Guaraná Antarctica (Garrafa 2L)', 'Refrigerante de guaraná Antarctica. Garrafa de 2 L.', 8.99, 30, 'guarana-antarctica-2l' UNION ALL
    SELECT 'Refrigerante Pepsi Black (Lata 350ml)', 'Refrigerante de cola Pepsi Black sem açúcar. Lata de 350 ml.', 3.99, 36, 'pepsi-black-350ml' UNION ALL
    SELECT 'Refrigerante Fanta Laranja (Garrafa 2L)', 'Refrigerante sabor laranja. Garrafa de 2 L.', 8.99, 30, 'fanta-laranja-2l' UNION ALL
    SELECT 'Energético Monster Energy Original (Lata 473ml)', 'Bebida energética Monster Energy Original. Lata de 473 ml.', 9.99, 24, 'monster-original-473ml' UNION ALL
    SELECT 'Energético Red Bull Energy Drink (Lata 250ml)', 'Bebida energética Red Bull Energy Drink. Lata de 250 ml.', 9.49, 24, 'red-bull-250ml' UNION ALL
    SELECT 'Suco Integral de Uva Aurora (Garrafa 1,5L)', 'Suco integral de uva tinto Aurora. Garrafa de 1,5 L.', 22.90, 18, 'suco-uva-aurora-15l' UNION ALL
    SELECT 'Suco Del Valle Néctar Pêssego (Caixa 1L)', 'Néctar de pêssego Del Valle. Caixa de 1 L.', 7.49, 25, 'del-valle-pessego-1l' UNION ALL
    SELECT 'Água de Coco Kero Coco (Caixa 1L)', 'Água de coco Kero Coco. Caixa de 1 L.', 11.90, 22, 'kero-coco-1l' UNION ALL
    SELECT 'Água Mineral Crystal sem Gás (Garrafa 500ml)', 'Água mineral natural sem gás. Garrafa de 500 ml.', 2.49, 40, 'crystal-sem-gas-500ml' UNION ALL
    SELECT 'Água Mineral Minalba com Gás (Garrafa 510ml)', 'Água mineral com gás. Garrafa de 510 ml.', 2.99, 35, 'minalba-com-gas-510ml' UNION ALL
    SELECT 'Chá Gelado Leão Fuze Limão (Garrafa 1,5L)', 'Chá gelado Leão Fuze sabor limão. Garrafa de 1,5 L.', 8.99, 24, 'leao-fuze-limao-15l' UNION ALL
    SELECT 'Cerveja Heineken Lager (Long Neck 330ml)', 'Cerveja lager Heineken. Garrafa long neck de 330 ml.', 0.00, 0, 'heineken-lager-330ml' UNION ALL
    SELECT 'Cerveja Brahma Chopp Pilsen (Lata 350ml)', 'Cerveja pilsen Brahma Chopp. Lata de 350 ml.', 0.00, 0, 'brahma-chopp-350ml' UNION ALL
    SELECT 'Cerveja Skol Pilsen (Lata 350ml)', 'Cerveja pilsen Skol. Lata de 350 ml.', 0.00, 0, 'skol-pilsen-350ml' UNION ALL
    SELECT 'Cerveja Heineken 0.0 Zero Álcool (Long Neck 330ml)', 'Heineken 0.0 sem álcool. Garrafa long neck de 330 ml.', 6.99, 24, 'heineken-zero-330ml' UNION ALL
    SELECT 'Vinho Tinto Suave Pérgola (Garrafa 1L)', 'Vinho tinto suave Pérgola. Garrafa de 1 L.', 0.00, 0, 'vinho-pergola-1l' UNION ALL
    SELECT 'Vinho Tinto Reservado Concha y Toro Cabernet Sauvignon (Garrafa 750ml)', 'Vinho tinto Cabernet Sauvignon da linha Reservado. Garrafa de 750 ml.', 0.00, 0, 'vinho-concha-y-toro-750ml' UNION ALL
    SELECT 'Espumante Salton Brut (Garrafa 750ml)', 'Espumante Salton Brut. Garrafa de 750 ml.', 0.00, 0, 'espumante-salton-brut-750ml'
) p
WHERE c.slug = 'bebidas'
  AND NOT EXISTS (
      SELECT 1 FROM produtos existente
      WHERE existente.id_categoria = c.id_categoria AND existente.nome = p.nome
  );
