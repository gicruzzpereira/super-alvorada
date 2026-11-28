-- Amplia Mercearia e Grãos com apresentações verificadas e fotos das embalagens.
INSERT INTO produtos (id_categoria, nome, descricao, tipo_medida, preco_unitario, estoque_qtd, imagem_url, destaque)
SELECT c.id_categoria, p.nome, p.descricao, 'UN', p.preco, 24,
       CONCAT('/assets/images/produto-mercearia-', p.foto, '.jpg'), 0
FROM categorias c
CROSS JOIN (
    SELECT 'Arroz Parboilizado Tipo 1 Urbano (5 kg)' AS nome, 'Arroz parboilizado tipo 1, de grão longo fino. Pacote de 5 kg.' AS descricao, 25.90 AS preco, 'arroz-parboilizado-urbano' AS foto UNION ALL
    SELECT 'Feijão Branco Kicaldo (500 g)', 'Feijão branco seco. Pacote de 500 g.', 8.99, 'feijao-branco-kicaldo' UNION ALL
    SELECT 'Milho para Pipoca Premium Yoki (500 g)', 'Milho para pipoca da linha Premium. Pacote de 500 g.', 6.49, 'pipoca-yoki-premium' UNION ALL
    SELECT 'Farinha de Rosca Yoki (500 g)', 'Farinha de rosca Yoki. Pacote de 500 g.', 6.99, 'farinha-rosca-yoki' UNION ALL
    SELECT 'Amido de Milho Maizena (200 g)', 'Amido de milho Maizena. Caixa de 200 g.', 6.49, 'maizena-200g' UNION ALL
    SELECT 'Macarrão Penne Renata Grano Duro (500 g)', 'Penne de sêmola de trigo grano duro. Pacote de 500 g.', 8.99, 'penne-renata-grano-duro' UNION ALL
    SELECT 'Massa para Lasanha Pré-Cozida com Ovos Renata (200 g)', 'Massa pré-cozida com ovos para lasanha. Embalagem de 200 g.', 7.49, 'lasanha-renata' UNION ALL
    SELECT 'Molho Shoyu Tradicional Sakura (500 ml)', 'Molho de soja tradicional. Frasco de 500 ml.', 10.90, 'shoyu-sakura-500ml' UNION ALL
    SELECT 'Vinagre de Álcool Colorido Castelo (750 ml)', 'Vinagre de álcool colorido. Frasco de 750 ml.', 4.49, 'vinagre-castelo-colorido' UNION ALL
    SELECT 'Mostarda Amarela Tradicional Heinz (255 g)', 'Mostarda amarela Heinz. Frasco de 255 g.', 12.90, 'mostarda-heinz-255g' UNION ALL
    SELECT 'Molho Inglês Tradicional Lea & Perrins (150 ml)', 'Molho inglês tipo Worcestershire. Frasco de 150 ml.', 19.90, 'lea-perrins-150ml' UNION ALL
    SELECT 'Caldo de Galinha Knorr (6 cubos)', 'Caldo de galinha em tabletes. Caixa com seis cubos.', 3.49, 'caldo-knorr-galinha' UNION ALL
    SELECT 'Tempero Sazón Carnes (12 sachês)', 'Tempero para carnes. Pacote com 12 sachês de 5 g.', 5.49, 'sazon-carnes' UNION ALL
    SELECT 'Pimenta-do-Reino Moída Kitano (50 g)', 'Pimenta-do-reino preta moída. Pacote de 50 g.', 9.90, 'pimenta-reino-kitano' UNION ALL
    SELECT 'Orégano Desidratado Kitano (15 g)', 'Orégano desidratado. Pacote de 15 g.', 4.99, 'oregano-kitano' UNION ALL
    SELECT 'Azeitona Verde com Caroço Vale Fértil (200 g)', 'Azeitonas verdes inteiras com caroço. Vidro de 200 g.', 12.90, 'azeitona-vale-fertil' UNION ALL
    SELECT 'Palmito Pupunha Picado Natupalm (300 g)', 'Palmito de pupunha picado em conserva. Vidro de 300 g.', 18.90, 'palmito-natupalm' UNION ALL
    SELECT 'Seleta de Legumes em Conserva Quero (170 g)', 'Seleta de legumes em conserva. Lata de 170 g.', 4.39, 'seleta-quero' UNION ALL
    SELECT 'Café Torrado e Moído Melitta Tradicional (500 g)', 'Café tradicional torrado e moído. Pacote de 500 g.', 28.90, 'cafe-melitta' UNION ALL
    SELECT 'Filtro de Papel Melitta Nº 103 (30 unidades)', 'Filtros de papel nº 103. Caixa com 30 unidades.', 5.90, 'filtro-melitta-103' UNION ALL
    SELECT 'Açúcar Cristal União (5 kg)', 'Açúcar cristal União. Pacote de 5 kg.', 19.90, 'acucar-cristal-uniao' UNION ALL
    SELECT 'Adoçante Líquido Zero-Cal Sucralose (100 ml)', 'Adoçante líquido à base de sucralose. Frasco de 100 ml.', 14.90, 'zero-cal-sucralose' UNION ALL
    SELECT 'Geleia de Morango Queensberry Clássica (320 g)', 'Geleia de morango da linha Classic. Vidro de 320 g.', 17.90, 'geleia-queensberry' UNION ALL
    SELECT 'Creme de Avelã Nutella (140 g)', 'Creme de avelã com cacau. Pote de 140 g.', 13.90, 'nutella-140g'
) p
WHERE c.slug = 'mercearia-graos'
  AND NOT EXISTS (
      SELECT 1 FROM produtos existente
      WHERE existente.id_categoria = c.id_categoria AND existente.nome = p.nome
  );
