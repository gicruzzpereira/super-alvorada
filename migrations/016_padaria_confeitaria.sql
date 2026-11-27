-- Atualiza os itens equivalentes, preservando IDs, preços e estoque.
UPDATE produtos p
JOIN categorias c ON c.id_categoria = p.id_categoria
JOIN (
    SELECT 'Pão francês' AS antigo, 'Pão Francês Fresquinho' AS nome, 'Casquinha crocante e miolo macio, vendido por quilo.' AS descricao, 'pao-frances' AS foto UNION ALL
    SELECT 'Pão de forma', 'Pão de Forma Tradicional (Pacote 500g)', 'Pão fatiado de miolo macio para sanduíches e torradas. Pacote de 500 g.', 'pao-de-forma-tradicional'
) dados ON p.nome = dados.antigo
LEFT JOIN produtos existente ON existente.id_categoria = p.id_categoria AND existente.nome = dados.nome
SET p.nome = dados.nome,
    p.descricao = dados.descricao,
    p.imagem_url = CONCAT('/assets/images/produto-padaria-', dados.foto, '.jpg')
WHERE c.slug = 'padaria' AND existente.id_produto IS NULL;

-- Cadastra os demais itens da Padaria & Confeitaria.
INSERT INTO produtos (id_categoria, nome, descricao, tipo_medida, preco_unitario, estoque_qtd, imagem_url, destaque)
SELECT c.id_categoria, p.nome, p.descricao, p.unidade, p.preco, p.estoque,
       CONCAT('/assets/images/produto-padaria-', p.foto, '.jpg'), 0
FROM categorias c
CROSS JOIN (
    SELECT 'Pão Francês Fresquinho' AS nome, 'Casquinha crocante e miolo macio, vendido por quilo.' AS descricao, 'KG' AS unidade, 16.90 AS preco, 50 AS estoque, 'pao-frances' AS foto UNION ALL
    SELECT 'Pão de Queijo Tradicional (Assado na Hora)', 'Pão de queijo dourado, com casquinha fina e miolo macio.', 'UN', 3.99, 40, 'pao-de-queijo' UNION ALL
    SELECT 'Pão de Forma Tradicional (Pacote 500g)', 'Pão fatiado de miolo macio para sanduíches e torradas. Pacote de 500 g.', 'UN', 8.90, 35, 'pao-de-forma-tradicional' UNION ALL
    SELECT 'Pão de Forma Integral (Pacote 500g)', 'Pão integral fatiado para sanduíches e torradas. Pacote de 500 g.', 'UN', 11.90, 30, 'pao-de-forma-integral' UNION ALL
    SELECT 'Bisnaguinha Tradicional (Pacote 300g)', 'Pãezinhos macios de sabor suave. Pacote de 300 g.', 'UN', 8.49, 24, 'bisnaguinha' UNION ALL
    SELECT 'Croissant de Manteiga', 'Massa folhada com manteiga, crocante por fora e leve por dentro.', 'UN', 7.49, 22, 'croissant' UNION ALL
    SELECT 'Pão Doce de Creme com Coco', 'Pão doce macio coberto com creme e coco ralado.', 'UN', 5.99, 20, 'pao-doce-creme-coco' UNION ALL
    SELECT 'Sonho de Creme de Baunilha', 'Sonho dourado com creme de baunilha e açúcar polvilhado.', 'UN', 6.49, 20, 'sonho-baunilha' UNION ALL
    SELECT 'Bolo Caseiro de Cenoura com Cobertura de Chocolate', 'Bolo inteiro de cenoura com massa fofinha e cobertura de chocolate.', 'UN', 26.90, 12, 'bolo-cenoura-chocolate' UNION ALL
    SELECT 'Bolo Caseiro de Fubá com Goiabada', 'Bolo inteiro de fubá, com pedaços de goiabada na massa.', 'UN', 23.90, 12, 'bolo-fuba-goiabada' UNION ALL
    SELECT 'Bolo de Chocolate Recheado (Fatia)', 'Uma fatia de bolo de chocolate com camadas de recheio cremoso.', 'UN', 10.90, 16, 'bolo-chocolate-fatia' UNION ALL
    SELECT 'Torta Holandesa (Fatia)', 'Uma fatia de torta cremosa com base de biscoito e ganache de chocolate.', 'UN', 12.90, 16, 'torta-holandesa-fatia' UNION ALL
    SELECT 'Carolina Recheada com Doce de Leite', 'Massa choux leve recheada com doce de leite.', 'UN', 4.99, 20, 'carolina-doce-de-leite' UNION ALL
    SELECT 'Rosquinha de Coco Caseira (Bandeja 300g)', 'Rosquinhas assadas com coco ralado. Bandeja de 300 g.', 'UN', 13.90, 18, 'rosquinha-coco' UNION ALL
    SELECT 'Torrada Tradicional da Casa (Pacote 250g)', 'Fatias douradas e crocantes. Pacote de 250 g.', 'UN', 8.90, 20, 'torrada-tradicional'
) p
WHERE c.slug = 'padaria'
  AND NOT EXISTS (
      SELECT 1 FROM produtos existente
      WHERE existente.id_categoria = c.id_categoria AND existente.nome = p.nome
  );
