-- Cadastra a categoria Farmácia com imagens das embalagens.
-- Medicamentos ficam em exibição no catálogo, sem preço ou estoque de venda.
INSERT INTO produtos (id_categoria, nome, descricao, tipo_medida, preco_unitario, estoque_qtd, imagem_url, destaque)
SELECT c.id_categoria, p.nome, p.descricao, 'UN', p.preco, p.estoque,
       CONCAT('/assets/images/produto-farmacia-', p.foto, '.jpg'), 0
FROM categorias c
CROSS JOIN (
    SELECT 'Dorflex 36 comprimidos' AS nome, 'Caixa com 36 comprimidos.' AS descricao, 0.00 AS preco, 0 AS estoque, 'dorflex-36' AS foto UNION ALL
    SELECT 'Dorflex UNO 1g 10 comprimidos', 'Caixa com 10 comprimidos de 1 g.', 0.00, 0, 'dorflex-uno-10' UNION ALL
    SELECT 'Tylenol 750mg 20 comprimidos', 'Caixa com 20 comprimidos de 750 mg.', 0.00, 0, 'tylenol-750-20' UNION ALL
    SELECT 'Advil 400mg 8 cápsulas líquidas', 'Caixa com 8 cápsulas líquidas de 400 mg.', 0.00, 0, 'advil-400-8' UNION ALL
    SELECT 'Benegrip Multi Dia (Caixa com 20 comprimidos)', 'Caixa com 20 comprimidos.', 0.00, 0, 'benegrip-multi-20' UNION ALL
    SELECT 'Vick VapoRub pote 30g', 'Pote de 30 g.', 0.00, 0, 'vick-30g' UNION ALL
    SELECT 'Eno Sal de Fruta Tradicional 2 envelopes 5g', 'Embalagem com 2 envelopes.', 0.00, 0, 'eno-tradicional-2' UNION ALL
    SELECT 'Estomazil Abacaxi envelope 5g', 'Envelope de 5 g.', 0.00, 0, 'estomazil-abacaxi-5g' UNION ALL
    SELECT 'Listerine Cool Mint 500ml', 'Enxaguante bucal Cool Mint. Frasco de 500 ml.', 21.90, 24, 'listerine-500ml' UNION ALL
    SELECT 'Strepsils Mel e Limão 16 pastilhas', 'Caixa com 16 pastilhas sabor mel e limão.', 0.00, 0, 'strepsils-16' UNION ALL
    SELECT 'Band-Aid Transparente 40 unidades', 'Caixa com 40 curativos adesivos transparentes.', 14.90, 24, 'bandaid-40' UNION ALL
    SELECT 'Merthiolate Incolor spray 30ml', 'Antisséptico incolor. Frasco spray de 30 ml.', 0.00, 0, 'merthiolate-30ml' UNION ALL
    SELECT 'Algodão Hidrófilo Cremer 50g', 'Pacote de algodão hidrófilo de 50 g.', 6.49, 24, 'algodao-cremer-50g' UNION ALL
    SELECT 'Gaze Estéril Cremer 10 unidades', 'Pacote com 10 compressas estéreis.', 5.49, 24, 'gaze-cremer-10' UNION ALL
    SELECT 'Fita Flexível Impermeável Nexcare (Rolo 2,5 cm × 4,5 m)', 'Rolo de 2,5 cm × 4,5 m.', 13.90, 24, 'nexcare-25-45' UNION ALL
    SELECT 'Redoxon Vitamina C laranja 10 comprimidos efervescentes', 'Embalagem com 10 comprimidos efervescentes sabor laranja.', 0.00, 0, 'redoxon-10' UNION ALL
    SELECT 'Centrum Essencial 30 comprimidos', 'Suplemento alimentar. Embalagem com 30 comprimidos.', 35.90, 24, 'centrum-30' UNION ALL
    SELECT 'Neutrogena Sun Fresh Facial FPS 70 40g', 'Protetor solar facial FPS 70. Embalagem de 40 g.', 43.90, 24, 'neutrogena-fps70-40g' UNION ALL
    SELECT 'Nivea Milk Pele Seca 200ml', 'Hidratante corporal para pele seca a extrasseca. Frasco de 200 ml.', 17.90, 24, 'nivea-milk-200ml' UNION ALL
    SELECT 'OFF! Family Spray 200ml', 'Repelente em spray. Frasco de 200 ml.', 22.90, 24, 'off-family-200ml'
) p
WHERE c.slug = 'farmacia'
  AND NOT EXISTS (
      SELECT 1 FROM produtos existente
      WHERE existente.id_categoria = c.id_categoria AND existente.nome = p.nome
  );
