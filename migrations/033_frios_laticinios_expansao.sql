-- Amplia Frios e Laticínios com fotos e apresentações verificadas.
INSERT INTO produtos (id_categoria, nome, descricao, tipo_medida, preco_unitario, estoque_qtd, imagem_url, destaque)
SELECT c.id_categoria, p.nome, p.descricao, p.unidade, p.preco, 24,
       CONCAT('/assets/images/produto-frios-', p.foto, '.jpg'), 0
FROM categorias c
CROSS JOIN (
    SELECT 'Queijo Brie Fracionado Président (125 g)' AS nome, 'Queijo Petit Brie. Peça de 125 g.' AS descricao, 'UN' AS unidade, 22.90 AS preco, 'brie-president' AS foto UNION ALL
    SELECT 'Queijo Gorgonzola Fracionado Tirolez (por kg)', 'Queijo gorgonzola fracionado, vendido por quilo.', 'KG', 99.90, 'gorgonzola-tirolez' UNION ALL
    SELECT 'Queijo Provolone Fracionado Quatá (200 g)', 'Queijo provolone em pedaço. Embalagem de 200 g.', 'UN', 13.49, 'provolone-quata' UNION ALL
    SELECT 'Queijo Cottage Tradicional Verde Campo (200 g)', 'Queijo cottage tradicional. Pote de 200 g.', 'UN', 13.90, 'cottage-verde-campo' UNION ALL
    SELECT 'Ricota Fresca Tirolez (450 g)', 'Ricota fresca Tirolez. Peça de 450 g.', 'UN', 12.90, 'ricota-tirolez' UNION ALL
    SELECT 'Mortadela Bologna Fatiada Ceratti (150 g)', 'Mortadela Bologna tradicional em fatias. Embalagem de 150 g.', 'UN', 12.90, 'bologna-ceratti' UNION ALL
    SELECT 'Copa Lombo Fatiada Sadia (100 g)', 'Copa lombo suína fatiada. Pacote de 100 g.', 'UN', 15.90, 'copa-sadia' UNION ALL
    SELECT 'Salsicha Hot Dog Tradicional Perdigão (500 g)', 'Salsichas Hot Dog Perdigão. Pacote de 500 g.', 'UN', 9.90, 'salsicha-perdigao' UNION ALL
    SELECT 'Linguiça Calabresa Defumada Seara (400 g)', 'Linguiça tipo calabresa defumada. Pacote de 400 g.', 'UN', 14.90, 'calabresa-seara' UNION ALL
    SELECT 'Bacon Defumado em Cubos Sadia (140 g)', 'Bacon defumado cortado em cubos. Pacote de 140 g.', 'UN', 16.90, 'bacon-sadia' UNION ALL
    SELECT 'Bebida Láctea Chocolate Toddynho (200 ml)', 'Bebida láctea sabor chocolate. Caixinha de 200 ml.', 'UN', 3.49, 'toddynho' UNION ALL
    SELECT 'Bebida Láctea Chocolate Nescau Prontinho (200 ml)', 'Bebida láctea sabor chocolate pronta para beber. Caixinha de 200 ml.', 'UN', 3.79, 'nescau-prontinho' UNION ALL
    SELECT 'Leite em Pó Integral Ninho Forti+ (380 g)', 'Leite em pó integral Ninho Forti+. Lata de 380 g.', 'UN', 21.90, 'ninho-forti' UNION ALL
    SELECT 'Leite em Pó Instantâneo Itambé (400 g)', 'Leite em pó integral instantâneo. Pacote de 400 g.', 'UN', 19.90, 'leite-po-itambe' UNION ALL
    SELECT 'Bebida Láctea Fermentada Vigor Todo Dia Morango (6 unidades, 540 g)', 'Bebida láctea fermentada sabor morango. Bandeja com seis unidades, 540 g no total.', 'UN', 8.99, 'iogurte-vigor' UNION ALL
    SELECT 'Iogurte Grego Frutas Vermelhas Danone (90 g)', 'Iogurte grego com calda de frutas vermelhas. Pote de 90 g.', 'UN', 3.79, 'grego-danone' UNION ALL
    SELECT 'Coalhada Vigor Viv (150 g)', 'Coalhada Vigor Viv de consistência firme. Pote de 150 g.', 'UN', 3.49, 'coalhada-vigor' UNION ALL
    SELECT 'Chantilly Spray Président (250 g)', 'Chantilly Président em spray. Frasco de 250 g.', 'UN', 24.90, 'chantilly-president' UNION ALL
    SELECT 'Margarina Cremosa com Sal Claybom (500 g)', 'Margarina cremosa com sal. Pote de 500 g.', 'UN', 8.49, 'claybon'
) p
WHERE c.slug = 'frios-laticinios'
  AND NOT EXISTS (
      SELECT 1 FROM produtos existente
      WHERE existente.id_categoria = c.id_categoria AND existente.nome = p.nome
  );
