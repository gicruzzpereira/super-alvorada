-- Cadastra temperos verdes e ovos no Hortifrúti sem duplicar produtos existentes.
INSERT INTO produtos (id_categoria, nome, descricao, tipo_medida, preco_unitario, estoque_qtd, imagem_url, destaque)
SELECT c.id_categoria, p.nome, p.descricao, 'UN', p.preco, p.estoque,
       CONCAT('/assets/images/produto-hortifruti-', p.foto, '.jpg'), 0
FROM categorias c
CROSS JOIN (
    SELECT 'Salsinha Fresca (Maço)' AS nome, 'Folhas frescas de sabor suave para finalizar molhos, sopas e saladas.' AS descricao, 3.49 AS preco, 30 AS estoque, 'salsinha' AS foto UNION ALL
    SELECT 'Cebolinha Verde (Maço)', 'Talos verdes de sabor delicado para omeletes, caldos e refogados.', 3.49, 30, 'cebolinha' UNION ALL
    SELECT 'Coentro Fresco (Maço)', 'Folhas aromáticas para peixes, feijão e molhos frescos.', 3.99, 25, 'coentro' UNION ALL
    SELECT 'Manjericão Fresco (Bandeja/Maço)', 'Folhas perfumadas para pesto, massas e saladas com tomate.', 5.99, 20, 'manjericao' UNION ALL
    SELECT 'Hortelã Fresca (Maço)', 'Folhas refrescantes para chás, sucos e saladas.', 3.99, 25, 'hortela' UNION ALL
    SELECT 'Alecrim Fresco (Bandeja)', 'Ramos aromáticos para batatas, legumes e carnes assadas.', 5.99, 20, 'alecrim' UNION ALL
    SELECT 'Orégano Fresco (Maço)', 'Folhas frescas e aromáticas para pizzas, molhos e marinadas.', 4.99, 20, 'oregano' UNION ALL
    SELECT 'Tomilho Fresco (Bandeja)', 'Ramos delicados para legumes, aves e molhos.', 5.99, 20, 'tomilho' UNION ALL
    SELECT 'Sálvia Fresca (Bandeja)', 'Folhas aveludadas para massas, manteiga aromatizada e assados.', 6.49, 15, 'salvia' UNION ALL
    SELECT 'Alho-Poró (Unidade)', 'Uma unidade de sabor suave para sopas, quiches e refogados.', 6.99, 25, 'alho-poro' UNION ALL
    SELECT 'Ovos Brancos Grandes (Bandeja 12 un)', 'Bandeja com 12 ovos brancos grandes.', 12.99, 30, 'ovos-brancos-12' UNION ALL
    SELECT 'Ovos Brancos Grandes (Pente 30 un)', 'Pente com 30 ovos brancos grandes.', 28.99, 20, 'ovos-brancos-30' UNION ALL
    SELECT 'Ovos Vermelhos Extra (Bandeja 12 un)', 'Bandeja com 12 ovos de casca vermelha, tamanho extra.', 15.99, 25, 'ovos-vermelhos-12' UNION ALL
    SELECT 'Ovos Caipiras (Bandeja 12 un)', 'Bandeja com 12 ovos caipiras.', 19.99, 20, 'ovos-caipiras-12' UNION ALL
    SELECT 'Ovos Orgânicos Certificados (Bandeja 6 un)', 'Bandeja com seis ovos orgânicos.', 14.99, 15, 'ovos-organicos-6' UNION ALL
    SELECT 'Ovos de Codorna (Bandeja 30 un)', 'Bandeja com 30 ovos de codorna.', 13.99, 20, 'ovos-codorna-30'
) p
WHERE c.slug = 'hortifruti'
  AND NOT EXISTS (
      SELECT 1 FROM produtos existentes
      WHERE existentes.id_categoria = c.id_categoria AND existentes.nome = p.nome
  );
