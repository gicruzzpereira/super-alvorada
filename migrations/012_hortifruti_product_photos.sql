UPDATE produtos p
JOIN categorias c USING(id_categoria)
SET p.imagem_url='/assets/images/produto-hortifruti-tomate-italiano.jpg'
WHERE c.slug='hortifruti' AND p.nome='Tomate italiano';

UPDATE produtos p
JOIN categorias c USING(id_categoria)
SET p.imagem_url='/assets/images/produto-hortifruti-alface-crespa.jpg'
WHERE c.slug='hortifruti' AND p.nome='Alface crespa';
