-- Adiciona os pescados e conservas com apresentações verificadas.
INSERT INTO produtos (id_categoria, nome, descricao, tipo_medida, preco_unitario, estoque_qtd, imagem_url, destaque)
SELECT c.id_categoria, p.nome, p.descricao, 'UN', p.preco, 24,
       CONCAT('/assets/images/produto-peixaria-', p.foto, '.jpg'), 0
FROM categorias c
CROSS JOIN (
    SELECT 'Filé de Tilápia Congelado Copacol (Pacote 800 g)' AS nome, 'Filés de tilápia congelados. Pacote de 800 g.' AS descricao, 34.90 AS preco, 'copacol-tilapia-800g' AS foto UNION ALL
    SELECT 'Medalhão de Salmão Frescatto (500 g)', 'Medalhões de salmão congelados. Embalagem de 500 g.', 46.90, 'frescatto-medalhao-salmao-500g' UNION ALL
    SELECT 'Pedaços de Filé de Salmão Swift (500 g)', 'Pedaços congelados de filé de salmão. Pacote de 500 g.', 49.90, 'swift-file-salmao-500g' UNION ALL
    SELECT 'Filé de Merluza Congelado Costa Sul (Pacote 800 g)', 'Filés de merluza congelados. Pacote de 800 g.', 29.90, 'costa-sul-merluza-800g' UNION ALL
    SELECT 'Filé de Panga Congelado Frescatto (Pacote 500 g)', 'Filés de panga congelados. Pacote de 500 g.', 25.90, 'frescatto-pangasius-500g' UNION ALL
    SELECT 'Lombo de Bacalhau Dessalgado Riberalves (Pacote 800 g)', 'Lombos de bacalhau dessalgados e congelados. Embalagem de 800 g.', 99.90, 'riberalves-bacalhau-800g' UNION ALL
    SELECT 'Posta de Cação Congelada Costa Sul (Pacote 800 g)', 'Postas de cação congeladas. Pacote de 800 g.', 32.90, 'costa-sul-cacao-800g' UNION ALL
    SELECT 'Camarão Cinza Descascado e Limpo Frescatto (Pacote 400 g)', 'Camarão cinza descascado e limpo. Embalagem de 400 g.', 35.90, 'frescatto-camarao-cinza-400g' UNION ALL
    SELECT 'Anéis de Lula Congelados Costa Sul (Pacote 400 g)', 'Lula em anéis congelada. Pacote de 400 g.', 28.90, 'costa-sul-lula-400g' UNION ALL
    SELECT 'Mix de Frutos do Mar para Paella Costa Sul (Pacote 400 g)', 'Mix congelado de frutos do mar para paella. Pacote de 400 g.', 25.90, 'costa-sul-paella-400g' UNION ALL
    SELECT 'Atum Sólido ao Natural Gomes da Costa (Lata 170 g)', 'Atum sólido ao natural. Lata de 170 g.', 11.49, 'gomes-costa-atum-natural-170g' UNION ALL
    SELECT 'Atum Ralado em Óleo Coqueiro (Lata 170 g)', 'Atum ralado em óleo. Lata de 170 g.', 8.49, 'coqueiro-atum-ralado-170g' UNION ALL
    SELECT 'Sardinha com Óleo Gomes da Costa (Lata 125 g)', 'Sardinhas com óleo. Lata de 125 g.', 6.49, 'gomes-costa-sardinha-oleo-125g' UNION ALL
    SELECT 'Sardinha ao Molho de Tomate Coqueiro (Lata 125 g)', 'Sardinhas em molho de tomate. Lata de 125 g.', 6.49, 'coqueiro-sardinha-tomate-125g' UNION ALL
    SELECT 'Tirinhas de Peixe Empanadas Seara (Pacote 300 g)', 'Tirinhas de peixe empanadas e congeladas. Pacote de 300 g.', 18.90, 'seara-empanado-peixe-300g'
) p
WHERE c.slug = 'peixaria'
  AND NOT EXISTS (
      SELECT 1 FROM produtos existente
      WHERE existente.id_categoria = c.id_categoria AND existente.nome = p.nome
  );
