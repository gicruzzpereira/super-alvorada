-- Cadastra os novos cortes e pescados no Açougue sem duplicar registros.
INSERT INTO produtos (id_categoria, nome, descricao, tipo_medida, preco_unitario, estoque_qtd, imagem_url, destaque)
SELECT c.id_categoria, p.nome, p.descricao, 'KG', p.preco, p.estoque,
       CONCAT('/assets/images/produto-acougue-', p.foto, '.jpg'), 0
FROM categorias c
CROSS JOIN (
    SELECT 'Contrafilé Bovino (Peça ou Bife)' AS nome, 'Corte bovino com capa de gordura, em peça ou bife.' AS descricao, 49.90 AS preco, 30 AS estoque, 'contrafile' AS foto UNION ALL
    SELECT 'Picanha Bovina Tradicional', 'Corte triangular com capa de gordura, ideal para churrasco.', 79.90, 23, 'picanha' UNION ALL
    SELECT 'Patinho Moído de Primeira', 'Patinho moído, de perfil magro, para molhos, almôndegas e refogados.', 42.90, 32, 'patinho-moido' UNION ALL
    SELECT 'Alcatra Bovina em Bife', 'Bifes de alcatra para grelhar ou preparar na frigideira.', 53.90, 25, 'alcatra-bife' UNION ALL
    SELECT 'Costela Bovina Ripada', 'Costela bovina com osso, cortada em tiras para assar.', 28.90, 30, 'costela-ripada' UNION ALL
    SELECT 'Cupim Bovino', 'Corte marmorizado para assados e preparos de cozimento lento.', 39.90, 18, 'cupim' UNION ALL
    SELECT 'Acém Bovino em Cubos', 'Cubos de acém para ensopados e carnes de panela.', 36.90, 25, 'acem-cubos' UNION ALL
    SELECT 'Peito de Frango sem Osso (Filé)', 'Filés de peito de frango sem osso para grelhar, assar ou empanar.', 22.90, 40, 'peito-frango-file' UNION ALL
    SELECT 'Coxa e Sobrecoxa de Frango', 'Cortes de coxa e sobrecoxa para assar ou cozinhar.', 15.90, 35, 'coxa-sobrecoxa' UNION ALL
    SELECT 'Asa de Frango (Tulipa / Meio da Asa)', 'Cortes de asa de frango para assar ou preparar na grelha.', 18.90, 30, 'asa-frango-tulipa' UNION ALL
    SELECT 'Linguiça Toscana para Churrasco', 'Linguiça suína toscana para grelha, forno ou frigideira.', 24.90, 30, 'linguica-toscana' UNION ALL
    SELECT 'Lombo Suíno Temperado', 'Lombo suíno temperado para assar inteiro ou fatiado.', 29.90, 22, 'lombo-suino-temperado' UNION ALL
    SELECT 'Costelinha Suína', 'Costelinha suína com osso para assar ou preparar na grelha.', 32.90, 24, 'costelinha-suina' UNION ALL
    SELECT 'Filé de Tilápia Fresco', 'Filé de tilápia fresco, de sabor suave, para grelhar ou assar.', 39.90, 20, 'file-tilapia' UNION ALL
    SELECT 'Posta de Salmão Fresco', 'Posta fresca de salmão com pele para grelhar ou assar.', 84.90, 15, 'posta-salmao'
) p
WHERE c.slug = 'acougue'
  AND NOT EXISTS (
      SELECT 1 FROM produtos existente
      WHERE existente.id_categoria = c.id_categoria AND existente.nome = p.nome
  );
