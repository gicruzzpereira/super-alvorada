-- Adiciona produtos de marca ao catálogo de Limpeza sem duplicar registros.
INSERT INTO produtos (id_categoria, nome, descricao, tipo_medida, preco_unitario, estoque_qtd, imagem_url, destaque)
SELECT c.id_categoria, p.nome, p.descricao, 'UN', p.preco, 24,
       CONCAT('/assets/images/produto-limpeza-', p.foto, '.jpg'), 0
FROM categorias c
CROSS JOIN (
    SELECT 'Sabão em Pó OMO Lavagem Perfeita (Caixa 1,6kg)' AS nome, 'Sabão em pó para lavanderia. Caixa de 1,6 kg.' AS descricao, 22.90 AS preco, 'omo-16kg' AS foto UNION ALL
    SELECT 'Sabão Líquido Ariel Concentrado (Galão 3L)', 'Sabão líquido concentrado para roupas. Galão de 3 L.', 38.90, 'ariel-3l' UNION ALL
    SELECT 'Amaciante Concentrado Downy Brisa de Verão (Frasco 1L)', 'Amaciante concentrado Brisa de Verão. Frasco de 1 L.', 23.90, 'downy-verao-1l' UNION ALL
    SELECT 'Amaciante Comfort Puro Cuidado (Frasco 1,8L)', 'Amaciante Puro Cuidado. Frasco de 1,8 L.', 33.90, 'comfort-18l' UNION ALL
    SELECT 'Tira-Manchas em Pó Vanish Oxi Action (Pote 450g)', 'Tira-manchas em pó para roupas. Pote de 450 g.', 24.90, 'vanish-450g' UNION ALL
    SELECT 'Sabão em Barra Ypê Neutro (Pacote com 5 unidades)', 'Sabão em barra neutro. Pacote com 5 unidades.', 12.90, 'ype-barra-5un' UNION ALL
    SELECT 'Detergente Líquido Ypê Neutro (Frasco 500ml)', 'Detergente líquido neutro para louças. Frasco de 500 ml.', 2.79, 'ype-detergente-500ml' UNION ALL
    SELECT 'Detergente Líquido Limpol Cristal (Frasco 500ml)', 'Detergente líquido Cristal para louças. Frasco de 500 ml.', 2.99, 'limpol-cristal-500ml' UNION ALL
    SELECT 'Esponja Multiuso Scotch-Brite (Pacote com 4 unidades)', 'Esponjas multiuso. Pacote com 4 unidades.', 8.99, 'scotch-brite-4un' UNION ALL
    SELECT 'Desengordurante Veja Cozinha Limão (Frasco 500ml)', 'Desengordurante de cozinha com fragrância de limão. Frasco de 500 ml.', 12.90, 'veja-cozinha-limao-500ml' UNION ALL
    SELECT 'Papel Toalha Snob Folha Dupla (Pacote com 2 rolos)', 'Papel toalha de folha dupla. Pacote com 2 rolos.', 6.99, 'snob-2rolos' UNION ALL
    SELECT 'Água Sanitária Qboa (Galão 2L)', 'Água sanitária Qboa. Galão de 2 L.', 7.99, 'qboa-2l' UNION ALL
    SELECT 'Desinfetante Pinho Sol Original (Frasco 1L)', 'Desinfetante Pinho Sol Original. Frasco de 1 L.', 12.90, 'pinho-sol-1l' UNION ALL
    SELECT 'Desinfetante Veja Perfume e Limpeza Lavanda (Frasco 2L)', 'Veja Perfume e Limpeza, fragrância lavanda. Frasco de 2 L.', 15.90, 'veja-lavanda-2l' UNION ALL
    SELECT 'Limpador Multiuso Veja Original (Frasco 500ml)', 'Limpador multiuso Veja Original. Frasco de 500 ml.', 5.49, 'veja-multiuso-500ml' UNION ALL
    SELECT 'Limpa Vidros Veja Vidrex (Frasco 500ml)', 'Limpador Veja Vidrex para vidros. Frasco de 500 ml.', 12.49, 'vidrex-500ml' UNION ALL
    SELECT 'Lustra-Móveis Poliflor Lavanda (Frasco 200ml)', 'Lustra-móveis com fragrância lavanda. Frasco de 200 ml.', 8.49, 'poliflor-lavanda-200ml' UNION ALL
    SELECT 'Inseticida Aerossol SBP Multi-Inseticida (Frasco 380ml)', 'SBP Multi-Inseticida em aerossol. Frasco de 380 ml.', 17.90, 'sbp-380ml' UNION ALL
    SELECT 'Saco para Lixo Dover Roll 50 Litros (Rolo com 30 unidades)', 'Sacos para lixo de 50 L. Rolo com 30 unidades.', 19.90, 'dover-roll-50l-30un' UNION ALL
    SELECT 'Pano Multiuso Perfex (Pacote com 5 panos)', 'Panos multiuso Perfex. Pacote com 5 panos.', 8.90, 'perfex-5un'
) p
WHERE c.slug = 'limpeza'
  AND NOT EXISTS (
      SELECT 1 FROM produtos existente
      WHERE existente.id_categoria = c.id_categoria AND existente.nome = p.nome
  );
