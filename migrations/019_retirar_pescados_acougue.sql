-- Retira os dois pescados do catálogo sem apagar referências de pedidos.
UPDATE produtos p
JOIN categorias c ON c.id_categoria = p.id_categoria
SET p.ativo = 0
WHERE c.slug = 'acougue'
  AND p.ativo = 1
  AND p.imagem_url IN (
      '/assets/images/produto-acougue-file-tilapia.jpg',
      '/assets/images/produto-acougue-posta-salmao.jpg'
  );
