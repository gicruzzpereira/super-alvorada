-- Atribui fotos individuais aos dois produtos iniciais de Limpeza.
UPDATE produtos p
JOIN categorias c ON c.id_categoria = p.id_categoria
JOIN (
    SELECT 'Detergente neutro' AS nome, '/assets/images/produto-limpeza-detergente-neutro.jpg' AS imagem_url
    UNION ALL
    SELECT 'Sabão em pó 1kg', '/assets/images/produto-limpeza-sabao-po-1kg.jpg'
) fotos ON fotos.nome = p.nome
SET p.imagem_url = fotos.imagem_url
WHERE c.slug = 'limpeza';
