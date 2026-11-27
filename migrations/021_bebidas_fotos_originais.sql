-- Atribui fotos e descrições próprias às duas bebidas do catálogo inicial.
UPDATE produtos p
JOIN categorias c ON c.id_categoria = p.id_categoria
JOIN (
    SELECT 'Suco de laranja 1L' AS nome, 'Suco de laranja em garrafa de 1 L.' AS descricao,
           '/assets/images/produto-bebidas-suco-laranja-1l.jpg' AS imagem_url
    UNION ALL
    SELECT 'Água mineral 1,5L', 'Água mineral em garrafa de 1,5 L.',
           '/assets/images/produto-bebidas-agua-mineral-15l.jpg'
) dados ON dados.nome = p.nome
SET p.imagem_url = dados.imagem_url,
    p.descricao = COALESCE(NULLIF(p.descricao, ''), dados.descricao)
WHERE c.slug = 'bebidas';
