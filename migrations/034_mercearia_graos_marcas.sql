-- Adiciona produtos de marca à Mercearia e Grãos sem duplicar registros.
INSERT INTO produtos (id_categoria, nome, descricao, tipo_medida, preco_unitario, estoque_qtd, imagem_url, destaque)
SELECT c.id_categoria, p.nome, p.descricao, 'UN', p.preco, 24,
       CONCAT('/assets/images/produto-mercearia-', p.foto, '.jpg'), 0
FROM categorias c
CROSS JOIN (
    SELECT 'Arroz Agulhinha Tipo 1 Camil (5 kg)' AS nome, 'Arroz branco de grão longo fino, tipo 1. Pacote de 5 kg.' AS descricao, 25.90 AS preco, 'arroz-camil' AS foto UNION ALL
    SELECT 'Arroz Integral Parboilizado Tio João (1 kg)', 'Arroz integral parboilizado, tipo 1. Pacote de 1 kg.', 8.90, 'arroz-integral-tio-joao' UNION ALL
    SELECT 'Feijão Carioca Tipo 1 Camil (1 kg)', 'Feijão carioca tipo 1. Pacote de 1 kg.', 8.49, 'feijao-carioca-camil' UNION ALL
    SELECT 'Feijão Preto Tipo 1 Kicaldo (1 kg)', 'Feijão preto tipo 1. Pacote de 1 kg.', 7.99, 'feijao-preto-kicaldo' UNION ALL
    SELECT 'Lentilha Yoki (500 g)', 'Lentilha seca. Pacote de 500 g.', 11.49, 'lentilha-yoki' UNION ALL
    SELECT 'Grão-de-Bico Yoki (500 g)', 'Grão-de-bico seco. Pacote de 500 g.', 12.99, 'grao-bico-yoki' UNION ALL
    SELECT 'Farofa de Mandioca Temperada Tradicional Yoki (500 g)', 'Farofa de mandioca temperada pronta. Pacote de 500 g.', 8.49, 'farinha-mandioca-yoki' UNION ALL
    SELECT 'Farinha de Trigo Tradicional Dona Benta (1 kg)', 'Farinha de trigo tradicional. Pacote de 1 kg.', 6.49, 'farinha-trigo-dona-benta' UNION ALL
    SELECT 'Fubá Mimoso Yoki (500 g)', 'Fubá mimoso de milho. Pacote de 500 g.', 4.29, 'fuba-yoki' UNION ALL
    SELECT 'Aveia em Flocos Finos Quaker (165 g)', 'Aveia integral em flocos finos. Caixa de 165 g.', 5.49, 'aveia-quaker' UNION ALL
    SELECT 'Macarrão Espaguete Nº 8 Barilla (500 g)', 'Espaguete Barilla nº 8. Pacote de 500 g.', 9.99, 'espaguete-barilla' UNION ALL
    SELECT 'Macarrão Parafuso Renata com Ovos (500 g)', 'Macarrão parafuso com ovos. Pacote de 500 g.', 6.29, 'parafuso-renata' UNION ALL
    SELECT 'Macarrão Instantâneo Nissin Miojo Galinha Caipira (85 g)', 'Macarrão instantâneo sabor galinha caipira. Pacote de 85 g.', 2.49, 'miojo-nissin' UNION ALL
    SELECT 'Molho de Tomate Tradicional Heinz (300 g)', 'Molho de tomate tradicional. Sachê de 300 g.', 4.79, 'molho-heinz' UNION ALL
    SELECT 'Extrato de Tomate Elefante (340 g)', 'Extrato de tomate Elefante. Lata de 340 g.', 8.49, 'extrato-elefante' UNION ALL
    SELECT 'Maionese Tradicional Hellmann''s (500 g)', 'Maionese tradicional. Pote de 500 g.', 12.90, 'maionese-hellmanns' UNION ALL
    SELECT 'Ketchup Tradicional Heinz (397 g)', 'Ketchup Heinz tradicional. Frasco de 397 g.', 13.90, 'ketchup-heinz' UNION ALL
    SELECT 'Óleo de Soja Liza (900 ml)', 'Óleo de soja Liza. Garrafa de 900 ml.', 7.49, 'oleo-liza' UNION ALL
    SELECT 'Azeite de Oliva Extra Virgem Gallo (500 ml)', 'Azeite de oliva extravirgem Gallo. Garrafa de 500 ml.', 37.90, 'azeite-gallo' UNION ALL
    SELECT 'Sal Refinado Cisne (1 kg)', 'Sal refinado Cisne. Pacote de 1 kg.', 3.49, 'sal-cisne' UNION ALL
    SELECT 'Açúcar Refinado União (1 kg)', 'Açúcar refinado União. Pacote de 1 kg.', 5.19, 'acucar-uniao' UNION ALL
    SELECT 'Café Torrado e Moído Pilão Tradicional (500 g)', 'Café tradicional torrado e moído. Pacote de 500 g.', 29.90, 'cafe-pilao' UNION ALL
    SELECT 'Café Solúvel Nescafé Tradição (100 g)', 'Café solúvel granulado Nescafé Tradição. Vidro de 100 g.', 18.90, 'nescafe-tradicao' UNION ALL
    SELECT 'Milho Verde em Conserva Quero (170 g)', 'Milho verde em conserva. Lata de 170 g.', 4.39, 'milho-quero' UNION ALL
    SELECT 'Ervilha em Conserva Bonduelle (170 g)', 'Ervilhas em conserva. Lata de 170 g.', 5.49, 'ervilha-bonduelle' UNION ALL
    SELECT 'Achocolatado em Pó Nescau 2.0 (370 g)', 'Achocolatado em pó Nescau 2.0. Lata de 370 g.', 9.99, 'nescau-2' UNION ALL
    SELECT 'Cereal Matinal Sucrilhos Kellogg''s Original (240 g)', 'Cereal matinal de milho Sucrilhos Original. Caixa de 240 g.', 12.90, 'sucrilhos-original' UNION ALL
    SELECT 'Biscoito Recheado Oreo Original (90 g)', 'Biscoito de chocolate com recheio sabor baunilha. Pacote de 90 g.', 4.99, 'oreo-original' UNION ALL
    SELECT 'Biscoito Cream Cracker Tradicional Bauducco (200 g)', 'Biscoito salgado Cream Cracker tradicional. Pacote de 200 g.', 5.49, 'cream-cracker-bauducco' UNION ALL
    SELECT 'Goiabada Cascão Predilecta (350 g)', 'Goiabada cascão Predilecta. Embalagem de 350 g.', 8.90, 'goiabada-predilecta'
) p
WHERE c.slug = 'mercearia-graos'
  AND NOT EXISTS (
      SELECT 1 FROM produtos existente
      WHERE existente.id_categoria = c.id_categoria AND existente.nome = p.nome
  );
