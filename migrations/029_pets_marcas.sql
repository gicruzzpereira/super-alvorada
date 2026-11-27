-- Adiciona produtos de Pets com fotos das apresentações verificadas.
INSERT INTO produtos (id_categoria, nome, descricao, tipo_medida, preco_unitario, estoque_qtd, imagem_url, destaque)
SELECT c.id_categoria, p.nome, p.descricao, 'UN', p.preco, 24,
       CONCAT('/assets/images/produto-pets-', p.foto, '.jpg'), 0
FROM categorias c
CROSS JOIN (
    SELECT 'Ração Seca Pedigree Adulto Carne, Frango e Cereais (10,1 kg)' AS nome, 'Ração seca para cães adultos. Pacote de 10,1 kg.' AS descricao, 119.90 AS preco, 'pedigree-adulto-101kg' AS foto UNION ALL
    SELECT 'Ração Seca GoldeN Formula Adulto Frango e Arroz (15 kg)', 'Ração seca para cães adultos, sabor frango e arroz. Pacote de 15 kg.', 169.90, 'golden-adulto-15kg' UNION ALL
    SELECT 'Ração Úmida Pedigree Carne ao Molho (Sachê 100 g)', 'Alimento úmido para cães adultos. Sachê de 100 g.', 3.99, 'pedigree-sache-carne-100g' UNION ALL
    SELECT 'Petisco Bifinho Keldog Carne e Cereais (55 g)', 'Bifinhos sabor carne e cereais para cães de porte pequeno. Pacote de 55 g.', 5.90, 'keldog-bifinho-55g' UNION ALL
    SELECT 'Tapete Higiênico Super Secão (30 unidades)', 'Pacote com 30 tapetes higiênicos.', 64.90, 'super-secao-30' UNION ALL
    SELECT 'Shampoo Neutro Sanol Dog (500 ml)', 'Shampoo neutro Sanol Dog. Frasco de 500 ml.', 16.90, 'sanol-dog-neutro-500ml' UNION ALL
    SELECT 'Ração Seca Whiskas Adulto Carne (10,1 kg)', 'Ração seca sabor carne para gatos adultos. Pacote de 10,1 kg.', 119.90, 'whiskas-carne-101kg' UNION ALL
    SELECT 'Ração Seca GoldeN Gatos Castrados Salmão (3 kg)', 'Ração seca sabor salmão para gatos adultos castrados. Pacote de 3 kg.', 57.90, 'golden-gatos-castrados-3kg' UNION ALL
    SELECT 'Ração Úmida Whiskas Atum ao Molho (Sachê 85 g)', 'Alimento úmido sabor atum para gatos adultos. Sachê de 85 g.', 3.69, 'whiskas-sache-atum-85g' UNION ALL
    SELECT 'Petisco Cremoso Churu Atum (4 tubos de 14 g)', 'Petisco cremoso sabor atum. Pacote com quatro tubos de 14 g.', 22.90, 'churu-atum-4' UNION ALL
    SELECT 'Areia Sanitária Pipicat Classic (4 kg)', 'Areia sanitária para gatos. Pacote de 4 kg.', 15.90, 'pipicat-classic-4kg' UNION ALL
    SELECT 'Areia Sanitária Sílica Chalesco (1,8 kg)', 'Cristais de sílica para a caixa sanitária. Pacote de 1,8 kg.', 32.90, 'chalesco-silica-18kg' UNION ALL
    SELECT 'Mistura de Sementes Megazoo Mix Canários (350 g)', 'Mix de sementes com grãos extrusados para canários. Pacote de 350 g.', 18.90, 'megazoo-mix-canarios-350g' UNION ALL
    SELECT 'Alpiste Selecionado Zootekna (500 g)', 'Alpiste selecionado para pássaros. Pacote de 500 g.', 10.90, 'zootekna-alpiste-500g' UNION ALL
    SELECT 'Painço Comum Zootekna (500 g)', 'Painço para pássaros. Pacote de 500 g.', 9.90, 'zootekna-painco-500g' UNION ALL
    SELECT 'Bebedouro Plástico Caçula Jel Plast (60 ml)', 'Bebedouro plástico modelo Caçula para gaiolas. Capacidade de 60 ml.', 6.90, 'jel-plast-bebedouro' UNION ALL
    SELECT 'Ração Extrusada Nutrópica para Hamster e Roedores (300 g)', 'Alimento extrusado Nutrópica para hamsters. Pacote de 300 g.', 19.90, 'nutropica-hamster-300g' UNION ALL
    SELECT 'Mistura de Sementes para Hamster Reino das Aves (500 g)', 'Mix para hamsters da linha Reino das Aves. Pacote de 500 g.', 12.90, 'reino-aves-hamster-500g' UNION ALL
    SELECT 'Roda de Exercícios com Rolamento para Hamster Jel Plast (Unidade)', 'Rodinha de exercícios com rolamento, de 11 cm de diâmetro. Uma unidade.', 21.90, 'jel-plast-roda-hamster' UNION ALL
    SELECT 'Ração Extrusada Nutrópica para Coelho Adulto (1,2 kg)', 'Ração extrusada natural para coelhos adultos. Pacote de 1,2 kg.', 43.90, 'nutropica-coelho-12kg'
) p
WHERE c.slug = 'pets'
  AND NOT EXISTS (
      SELECT 1 FROM produtos existente
      WHERE existente.id_categoria = c.id_categoria AND existente.nome = p.nome
  );
