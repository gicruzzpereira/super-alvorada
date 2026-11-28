-- Amplia a categoria Higiene e Perfumaria com fotos das embalagens verificadas.
-- Os medicamentos ficam em exibição, com estoque zero e sem compra online.
INSERT INTO produtos (id_categoria, nome, descricao, tipo_medida, preco_unitario, estoque_qtd, imagem_url, destaque)
SELECT c.id_categoria, p.nome, p.descricao, 'UN', p.preco, p.estoque,
       CONCAT('/assets/images/produto-higiene-', p.foto, '.jpg'), 0
FROM categorias c
CROSS JOIN (
    SELECT 'Shampoo Anticaspa Head & Shoulders Remoção da Oleosidade (200 ml)' AS nome, 'Shampoo anticaspa da linha Remoção da Oleosidade. Frasco de 200 ml.' AS descricao, 17.90 AS preco, 24 AS estoque, 'head-shoulders-oleosidade' AS foto UNION ALL
    SELECT 'Shampoo Infantil Johnson''s Baby Regular (400 ml)', 'Shampoo infantil Johnson’s Baby Regular. Frasco de 400 ml.', 19.90, 24, 'johnsons-shampoo-regular' UNION ALL
    SELECT 'Condicionador Infantil Johnson''s Baby Regular (200 ml)', 'Condicionador infantil Johnson’s Baby Regular. Frasco de 200 ml.', 15.90, 24, 'johnsons-condicionador-regular' UNION ALL
    SELECT 'Tintura Koleston Louro Escuro 60', 'Tintura creme Wella Koleston na cor Louro Escuro, tonalidade 60. Uma caixa.', 22.90, 24, 'koleston-60' UNION ALL
    SELECT 'Gel Fixador Bozzano Fixação Forte (300 g)', 'Gel fixador Bozzano de fixação forte. Pote de 300 g.', 9.90, 24, 'bozzano-gel-forte' UNION ALL
    SELECT 'Gel de Limpeza Facial Neutrogena Deep Clean (150 g)', 'Gel facial de limpeza Neutrogena Deep Clean. Bisnaga de 150 g.', 29.90, 24, 'neutrogena-deep-clean' UNION ALL
    SELECT 'Água Micelar L''Oréal Paris Solução de Limpeza 5 em 1 (200 ml)', 'Solução micelar facial 5 em 1. Frasco de 200 ml.', 25.90, 24, 'loreal-agua-micelar' UNION ALL
    SELECT 'Hidratante Facial Nivea Soft (98 g)', 'Creme hidratante Nivea Soft. Pote de 98 g.', 24.90, 24, 'nivea-soft' UNION ALL
    SELECT 'Protetor Labial Nivea Original Care (4,8 g)', 'Protetor labial Original Care. Bastão de 4,8 g.', 13.90, 24, 'nivea-labial-original' UNION ALL
    SELECT 'Desodorante Antitranspirante Aerossol Nivea Pearl & Beauty (150 ml)', 'Antitranspirante Nivea Pearl & Beauty em aerossol. Frasco de 150 ml.', 15.90, 24, 'nivea-pearl-beauty' UNION ALL
    SELECT 'Desodorante Creme Herbíssimo Tradicional (55 g)', 'Desodorante antitranspirante em creme Herbíssimo Tradicional. Pote de 55 g.', 5.90, 24, 'herbissimo-tradicional' UNION ALL
    SELECT 'Polvilho Antisséptico Granado (100 g)', 'Polvilho Antisséptico Granado Tradicional. Frasco de 100 g.', 0.00, 0, 'granado-polvilho' UNION ALL
    SELECT 'Sabonete Líquido Granado Glicerina Tradicional (300 ml)', 'Sabonete líquido de glicerina Granado Tradicional. Frasco de 300 ml.', 23.90, 24, 'granado-glicerina' UNION ALL
    SELECT 'Enxaguante Bucal Colgate Plax Fresh Mint (500 ml)', 'Enxaguante bucal Colgate Plax Fresh Mint. Frasco de 500 ml.', 18.90, 24, 'colgate-plax-fresh-mint' UNION ALL
    SELECT 'Creme Dental Oral-B 1-2-3 Menta (70 g)', 'Creme dental Oral-B 1-2-3 sabor menta. Bisnaga de 70 g.', 4.99, 24, 'oral-b-123-menta' UNION ALL
    SELECT 'Carga para Aparelho de Barbear Gillette Mach3 (2 unidades)', 'Cartela com duas cargas para aparelho Gillette Mach3.', 29.90, 24, 'gillette-mach3-carga' UNION ALL
    SELECT 'Loção Pós-Barba Bozzano Night Blue (100 ml)', 'Loção pós-barba Bozzano Night Blue. Frasco de 100 ml.', 19.90, 24, 'bozzano-pos-barba-azul' UNION ALL
    SELECT 'Creme para Assaduras Bepantol Baby (30 g)', 'Creme preventivo de assaduras Bepantol Baby. Bisnaga de 30 g.', 24.90, 24, 'bepantol-baby' UNION ALL
    SELECT 'Pomada para Assaduras Hipoglós Original (45 g)', 'Hipoglós Original. Bisnaga de 45 g.', 0.00, 0, 'hipoglos-original' UNION ALL
    SELECT 'Papel Higiênico Sublime Folha Dupla (12 rolos)', 'Papel higiênico Sublime folha dupla. Pacote com 12 rolos.', 22.90, 24, 'sublime-tripla'
) p
WHERE c.slug = 'higiene-perfumaria'
  AND NOT EXISTS (
      SELECT 1 FROM produtos existente
      WHERE existente.id_categoria = c.id_categoria AND existente.nome = p.nome
  );
