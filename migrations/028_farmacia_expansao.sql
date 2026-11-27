-- Amplia a categoria Farmácia. Medicamentos ficam em exibição, sem venda online.
INSERT INTO produtos (id_categoria, nome, descricao, tipo_medida, preco_unitario, estoque_qtd, imagem_url, destaque)
SELECT c.id_categoria, p.nome, p.descricao, 'UN', p.preco, p.estoque,
       CONCAT('/assets/images/produto-farmacia-', p.foto, '.jpg'), 0
FROM categorias c
CROSS JOIN (
    SELECT 'Dipirona Monoidratada Medley 1 g (Caixa com 10 comprimidos)' AS nome, 'Caixa com 10 comprimidos de 1 g.' AS descricao, 0.00 AS preco, 0 AS estoque, 'dipirona-medley-1g-10' AS foto UNION ALL
    SELECT 'Neosaldina (Blister com 4 drágeas)', 'Blister com 4 drágeas.', 0.00, 0, 'neosaldina-4' UNION ALL
    SELECT 'Torsilax (Caixa com 12 comprimidos)', 'Caixa com 12 comprimidos.', 0.00, 0, 'torsilax-12' UNION ALL
    SELECT 'Cimegripe (Caixa com 20 cápsulas)', 'Caixa com 20 cápsulas.', 0.00, 0, 'cimegripe-20' UNION ALL
    SELECT 'Neosoro Adulto (Frasco 30 ml)', 'Solução nasal. Frasco de 30 ml.', 0.00, 0, 'neosoro-adulto-30ml' UNION ALL
    SELECT 'Sonrisal Tradicional (Envelope com 2 comprimidos efervescentes)', 'Envelope com 2 comprimidos efervescentes.', 0.00, 0, 'sonrisal-tradicional-2' UNION ALL
    SELECT 'Soro Fisiológico 0,9% Needs (Frasco 500 ml)', 'Solução fisiológica de cloreto de sódio a 0,9%. Frasco de 500 ml.', 7.90, 24, 'soro-needs-500ml' UNION ALL
    SELECT 'Termômetro Clínico Digital G-Tech', 'Termômetro clínico digital de ponta rígida.', 24.90, 24, 'termometro-gtech' UNION ALL
    SELECT 'Creme Dental Colgate Total 12 Clean Mint (Bisnaga 90 g)', 'Creme dental Clean Mint. Bisnaga de 90 g.', 9.90, 24, 'colgate-total-12-90g' UNION ALL
    SELECT 'Escova Dental Oral-B Indicator Plus (Unidade)', 'Escova dental Indicator Plus. Uma unidade.', 8.49, 24, 'oral-b-indicator-plus' UNION ALL
    SELECT 'Fio Dental Johnson''s Reach Expansion Plus Menta (50 m)', 'Fio dental Reach Expansion Plus sabor menta. Rolo de 50 m.', 9.90, 24, 'reach-menta-50m' UNION ALL
    SELECT 'Desodorante Antitranspirante Rexona Men Invisible Aerossol (150 ml)', 'Antitranspirante em aerossol. Frasco de 150 ml.', 15.90, 24, 'rexona-men-invisible-150ml' UNION ALL
    SELECT 'Sabonete Líquido Íntimo Dermacyd Neutralize (200 ml)', 'Sabonete líquido íntimo. Frasco de 200 ml.', 22.90, 24, 'dermacyd-neutralize-200ml' UNION ALL
    SELECT 'Absorvente Always Noites Tranquilas Suave com Abas (8 unidades)', 'Absorvente noturno suave com abas. Pacote com 8 unidades.', 10.90, 24, 'always-noites-8' UNION ALL
    SELECT 'Preservativo Jontex Lubrificado (Pacote com 3 unidades)', 'Pacote com 3 preservativos lubrificados.', 7.90, 24, 'jontex-lubrificado-3'
) p
WHERE c.slug = 'farmacia'
  AND NOT EXISTS (
      SELECT 1 FROM produtos existente
      WHERE existente.id_categoria = c.id_categoria AND existente.nome = p.nome
  );
