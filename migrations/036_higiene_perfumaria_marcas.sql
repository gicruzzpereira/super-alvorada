-- Adiciona produtos de Higiene e Perfumaria com fotos das embalagens.
INSERT INTO produtos (id_categoria, nome, descricao, tipo_medida, preco_unitario, estoque_qtd, imagem_url, destaque)
SELECT c.id_categoria, p.nome, p.descricao, 'UN', p.preco, 24,
       CONCAT('/assets/images/produto-higiene-', p.foto, '.jpg'), 0
FROM categorias c
CROSS JOIN (
    SELECT 'Shampoo Hidratação Intensa Pantene (400 ml)' AS nome, 'Shampoo Pantene Pro-V para hidratação. Frasco de 400 ml.' AS descricao, 21.90 AS preco, 'pantene-hidratacao' AS foto UNION ALL
    SELECT 'Condicionador Restauração Pantene (400 ml)', 'Condicionador Pantene Pro-V da linha Restauração. Frasco de 400 ml.', 24.90, 'pantene-restauracao' UNION ALL
    SELECT 'Shampoo Anticaspa Clear Men Limpeza Profunda (200 ml)', 'Shampoo anticaspa Clear Men Limpeza Profunda. Frasco de 200 ml.', 17.90, 'clear-men-limpeza' UNION ALL
    SELECT 'Creme para Pentear Seda Cachos Definidos (300 ml)', 'Creme para pentear Seda Cachos Definidos. Frasco de 300 ml.', 11.90, 'seda-cachos' UNION ALL
    SELECT 'Máscara de Tratamento Dove Reconstrução Completa (350 g)', 'Máscara capilar Dove Reconstrução Completa. Pote de 350 g.', 24.90, 'dove-reconstrucao' UNION ALL
    SELECT 'Sabonete em Barra Dove Original (6 unidades de 90 g)', 'Sabonete em barra Dove Original. Pacote com seis unidades de 90 g cada.', 19.90, 'dove-original-6' UNION ALL
    SELECT 'Sabonete em Barra Lux Botanicals Buquê de Jasmim (85 g)', 'Sabonete Lux Botanicals com fragrância de jasmim. Barra de 85 g.', 2.49, 'lux-jasmim' UNION ALL
    SELECT 'Sabonete Líquido Corporal Nivea Creme Care (250 ml)', 'Sabonete líquido para o corpo Nivea Creme Care. Frasco de 250 ml.', 13.90, 'nivea-creme-care' UNION ALL
    SELECT 'Desodorante Antitranspirante Rexona Women Bamboo Aerossol (150 ml)', 'Antitranspirante Rexona Women Bamboo em aerossol. Frasco de 150 ml.', 15.90, 'rexona-bamboo' UNION ALL
    SELECT 'Desodorante Roll-On Dove Original (50 ml)', 'Desodorante antitranspirante Dove Original roll-on. Frasco de 50 ml.', 13.90, 'dove-roll-on' UNION ALL
    SELECT 'Hidratante Corporal Johnson''s Soft Lotion (200 ml)', 'Loção corporal Johnson’s Soft Lotion Hidratação Imediata. Frasco de 200 ml.', 15.90, 'johnsons-soft' UNION ALL
    SELECT 'Óleo Corporal Paixão Tentadora (200 ml)', 'Óleo corporal Paixão Tentadora. Frasco de 200 ml.', 17.90, 'paixao-tentadora' UNION ALL
    SELECT 'Creme Dental Colgate Luminous White Carvão Ativado (70 g)', 'Creme dental Colgate Luminous White Carvão Ativado. Bisnaga de 70 g.', 12.90, 'colgate-carvao' UNION ALL
    SELECT 'Creme Dental Sensodyne Rápido Alívio (90 g)', 'Creme dental Sensodyne Rápido Alívio. Bisnaga de 90 g.', 22.90, 'sensodyne-rapido' UNION ALL
    SELECT 'Aparelho de Barbear Gillette Prestobarba3 (2 unidades)', 'Aparelhos descartáveis Gillette Prestobarba3. Pacote com duas unidades.', 13.90, 'gillette-prestobarba3' UNION ALL
    SELECT 'Espuma de Barbear Bozzano Hidratação (190 g)', 'Espuma de barbear Bozzano Hidratação. Frasco de 190 g.', 19.90, 'bozzano-hidratacao' UNION ALL
    SELECT 'Papel Higiênico Neve Folha Dupla Neutro (12 rolos)', 'Papel higiênico Neve Toque da Seda, folha dupla neutra. Pacote com 12 rolos.', 19.90, 'neve-dupla-12' UNION ALL
    SELECT 'Papel Higiênico Personal Vip Folha Dupla (16 rolos)', 'Papel higiênico Personal Vip, folha dupla. Pacote com 16 rolos.', 22.90, 'personal-vip-16' UNION ALL
    SELECT 'Lenço Umedecido Huggies Supreme Care (48 unidades)', 'Lenços umedecidos Huggies Supreme Care. Pacote com 48 unidades.', 13.90, 'huggies-supreme-48' UNION ALL
    SELECT 'Fralda Descartável Pampers Confort Sec Tamanho G (70 unidades)', 'Fraldas descartáveis Pampers Confort Sec tamanho G. Pacote com 70 unidades.', 89.90, 'pampers-confort-g' UNION ALL
    SELECT 'Absorvente Intimus Gel Suave com Abas (8 unidades)', 'Absorventes com abas e cobertura suave. Pacote com oito unidades.', 6.49, 'intimus-gel' UNION ALL
    SELECT 'Protetor Diário Carefree Todo Dia sem Perfume (40 unidades)', 'Protetores diários Carefree Todo Dia sem perfume. Pacote com 40 unidades.', 15.90, 'carefree-sem-perfume' UNION ALL
    SELECT 'Hastes Flexíveis Cotonetes Johnson & Johnson (75 unidades)', 'Hastes flexíveis Cotonetes. Caixa com 75 unidades.', 5.90, 'cotonetes-75' UNION ALL
    SELECT 'Cortador de Unhas Mundial Clássico (1 unidade)', 'Cortador de unhas Mundial da linha Classic. Uma unidade.', 8.90, 'mundial-cortador' UNION ALL
    SELECT 'Esmalte Risqué Renda (8 ml)', 'Esmalte Risqué na cor Renda. Frasco de 8 ml.', 5.49, 'risque-renda'
) p
WHERE c.slug = 'higiene-perfumaria'
  AND NOT EXISTS (
      SELECT 1 FROM produtos existente
      WHERE existente.id_categoria = c.id_categoria AND existente.nome = p.nome
  );
