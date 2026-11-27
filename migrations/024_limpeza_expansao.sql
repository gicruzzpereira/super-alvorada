-- Amplia a linha de Limpeza com embalagens verificadas.
-- Álcool líquido 70% é exibido no catálogo com estoque zero.
INSERT INTO produtos (id_categoria, nome, descricao, tipo_medida, preco_unitario, estoque_qtd, imagem_url, destaque)
SELECT c.id_categoria, p.nome, p.descricao, 'UN', p.preco, p.estoque,
       CONCAT('/assets/images/produto-limpeza-', p.foto, '.jpg'), 0
FROM categorias c
CROSS JOIN (
    SELECT 'Álcool Líquido 70% Zulu (Frasco 1L)' AS nome, 'Álcool líquido Zulu 70%. Frasco de 1 L.' AS descricao, 0.00 AS preco, 0 AS estoque, 'zulu-alcool-70-1l' AS foto UNION ALL
    SELECT 'Álcool em Gel 70% Giovanna Baby (Frasco 500ml)', 'Álcool em gel 70%. Frasco de 500 ml.', 19.90, 24, 'giovanna-baby-gel-500ml' UNION ALL
    SELECT 'Desinfetante Lysoform Bruto Original (Frasco 1L)', 'Desinfetante Lysoform Bruto Original. Frasco de 1 L.', 15.90, 24, 'lysoform-original-1l' UNION ALL
    SELECT 'Limpador Perfumado Casa & Perfume Sensualidade (Frasco 1L)', 'Limpador perfumado Sensualidade. Frasco de 1 L.', 8.90, 24, 'casa-perfume-sensualidade-1l' UNION ALL
    SELECT 'Saponáceo Cremoso Cif Original (Frasco 450ml)', 'Saponáceo cremoso Cif Original. Frasco de 450 ml.', 11.90, 24, 'cif-original-450ml' UNION ALL
    SELECT 'Detergente em Pó Tixan Ypê Primavera (Caixa 1,6kg)', 'Lava-roupas em pó Tixan Ypê Primavera. Caixa de 1,6 kg.', 19.90, 24, 'tixan-primavera-16kg' UNION ALL
    SELECT 'Lava-Roupas Líquido Brilhante Limpeza Total (Galão 3L)', 'Lava-roupas líquido Limpeza Total. Galão de 3 L.', 29.90, 24, 'brilhante-limpeza-total-3l' UNION ALL
    SELECT 'Alvejante sem Cloro Vanish Poder O2 (Frasco 1,5L)', 'Alvejante líquido Vanish sem cloro. Frasco de 1,5 L.', 21.90, 24, 'vanish-poder-o2-15l' UNION ALL
    SELECT 'Limpa Forno e Fogão Diabo Verde (Frasco 300ml)', 'Limpador Diabo Verde para forno e fogão. Frasco de 300 ml.', 12.90, 24, 'diabo-verde-limpa-forno-300ml' UNION ALL
    SELECT 'Desentupidor Líquido Diabo Verde (Frasco 1L)', 'Desentupidor líquido Diabo Verde. Frasco de 1 L.', 22.90, 24, 'diabo-verde-desentupidor-1l' UNION ALL
    SELECT 'Esponja de Aço Bombril (Pacote com 8 unidades)', 'Esponjas de aço Bombril. Pacote com 8 unidades.', 3.49, 24, 'bombril-8un' UNION ALL
    SELECT 'Vassoura Noviça Original Bettanin', 'Vassoura Noviça Original da Bettanin.', 19.90, 24, 'novica-vassoura-original' UNION ALL
    SELECT 'Luva de Látex Mucambo Multiuso (Par)', 'Um par de luvas multiuso de látex Mucambo.', 9.99, 24, 'mucambo-luva-multiuso'
) p
WHERE c.slug = 'limpeza'
  AND NOT EXISTS (
      SELECT 1 FROM produtos existente
      WHERE existente.id_categoria = c.id_categoria AND existente.nome = p.nome
  );
