UPDATE produtos p
JOIN categorias c USING(id_categoria)
SET p.imagem_url='/assets/images/produto-hortifruti-banana-prata.jpg'
WHERE c.slug='hortifruti' AND p.nome='Banana prata';
