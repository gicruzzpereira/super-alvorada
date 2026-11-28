-- Adiciona frios e laticínios com fotos das embalagens verificadas.
INSERT INTO produtos (id_categoria, nome, descricao, tipo_medida, preco_unitario, estoque_qtd, imagem_url, destaque)
SELECT c.id_categoria, p.nome, p.descricao, p.unidade, p.preco, 24,
       CONCAT('/assets/images/produto-frios-', p.foto, '.jpg'), 0
FROM categorias c
CROSS JOIN (
    SELECT 'Queijo Mussarela Fatiado Sadia (200 g)' AS nome, 'Queijo mussarela fatiado da linha Soltíssimo. Pacote de 200 g.' AS descricao, 'UN' AS unidade, 12.99 AS preco, 'mussarela-sadia' AS foto UNION ALL
    SELECT 'Presunto Cozido sem Capa de Gordura Seara (kg)', 'Presunto cozido sem capa de gordura, vendido por quilo.', 'KG', 44.90, 'presunto-seara' UNION ALL
    SELECT 'Peito de Peru Defumado Fatiado Sadia (200 g)', 'Peito de peru cozido e defumado, fatiado. Pacote de 200 g.', 'UN', 16.99, 'peru-sadia' UNION ALL
    SELECT 'Mortadela Defumada Ouro Perdigão (200 g)', 'Mortadela Ouro defumada e fatiada. Embalagem de 200 g.', 'UN', 8.99, 'mortadela-perdigao' UNION ALL
    SELECT 'Salame Tipo Italiano Fatiado Ceratti (100 g)', 'Salame tipo italiano defumado, fatiado. Pacote de 100 g.', 'UN', 15.99, 'salame-ceratti' UNION ALL
    SELECT 'Queijo Minas Frescal Tirolez (500 g)', 'Queijo Minas frescal. Peça de aproximadamente 500 g.', 'UN', 25.99, 'minas-tirolez' UNION ALL
    SELECT 'Queijo Parmesão Ralado Vigor (50 g)', 'Queijo Parmesão Ralado Vigor. Embalagem de 50 g.', 'UN', 5.49, 'parmesao-vigor' UNION ALL
    SELECT 'Queijo Cheddar Fatiado Polenghi (144 g)', 'Queijo Cheddar Fatiado Polenghi. Embalagem de 144 g.', 'UN', 12.49, 'cheddar-polenghi' UNION ALL
    SELECT 'Cream Cheese Tradicional Philadelphia (150 g)', 'Cream cheese tradicional. Pote de 150 g.', 'UN', 10.99, 'philadelphia' UNION ALL
    SELECT 'Leite Longa Vida Integral Italac (1 L)', 'Leite Longa Vida Integral Italac. Embalagem de 1 L.', 'UN', 5.49, 'italac-integral' UNION ALL
    SELECT 'Leite Longa Vida Desnatado Piracanjuba (1 L)', 'Leite Longa Vida Desnatado Piracanjuba. Embalagem de 1 L.', 'UN', 5.69, 'piracanjuba-desnatado' UNION ALL
    SELECT 'Leite Integral Zero Lactose Piracanjuba (1 L)', 'Leite Integral Zero Lactose Piracanjuba. Embalagem de 1 L.', 'UN', 6.99, 'piracanjuba-zero' UNION ALL
    SELECT 'Requeijão Cremoso Tradicional Vigor (200 g)', 'Requeijão Cremoso Tradicional Vigor. Embalagem de 200 g.', 'UN', 9.49, 'requeijao-vigor' UNION ALL
    SELECT 'Requeijão Cremoso Light Catupiry (200 g)', 'Requeijão Cremoso Light Catupiry. Embalagem de 200 g.', 'UN', 12.99, 'catupiry-light' UNION ALL
    SELECT 'Manteiga com Sal Aviação (200 g)', 'Manteiga com sal. Pote de 200 g.', 'UN', 14.99, 'aviacao-sal' UNION ALL
    SELECT 'Margarina Cremosa com Sal Qualy (500 g)', 'Margarina Cremosa com Sal Qualy. Embalagem de 500 g.', 'UN', 8.99, 'qualy-sal' UNION ALL
    SELECT 'Creme de Leite Tradicional Nestlé (200 g)', 'Creme de leite original. Caixinha de 200 g.', 'UN', 4.69, 'creme-nestle' UNION ALL
    SELECT 'Leite Condensado Integral Moça Nestlé (Lata 395 g)', 'Leite condensado integral. Lata de 395 g.', 'UN', 8.49, 'moca-integral' UNION ALL
    SELECT 'Iogurte Grego Tradicional Batavo (100 g)', 'Iogurte Grego Tradicional Batavo. Embalagem de 100 g.', 'UN', 3.99, 'grego-batavo' UNION ALL
    SELECT 'Iogurte Natural Integral Nestlé (170 g)', 'Iogurte Natural Integral Nestlé. Embalagem de 170 g.', 'UN', 4.49, 'natural-nestle' UNION ALL
    SELECT 'Iogurte Líquido Morango Danone (900 g)', 'Iogurte Líquido Morango Danone. Embalagem de 900 g.', 'UN', 10.99, 'danone-morango' UNION ALL
    SELECT 'Bebida Láctea Fermentada Yakult (6 frascos 80 g)', 'Leite fermentado Yakult. Pacote com seis frascos de 80 g.', 'UN', 12.99, 'yakult-6' UNION ALL
    SELECT 'Petit Suisse Morango Danoninho (8 unidades 320 g)', 'Petit suisse de morango. Bandeja com oito unidades, 320 g no total.', 'UN', 9.99, 'danoninho-8' UNION ALL
    SELECT 'Sobremesa Láctea Chocolate Chandelle Nestlé (2 unidades)', 'Sobremesa láctea sabor chocolate. Bandeja com duas unidades, 180 g no total.', 'UN', 5.99, 'chandelle-chocolate'
) p
WHERE c.slug = 'frios-laticinios'
  AND NOT EXISTS (
      SELECT 1 FROM produtos existente
      WHERE existente.id_categoria = c.id_categoria AND existente.nome = p.nome
  );
