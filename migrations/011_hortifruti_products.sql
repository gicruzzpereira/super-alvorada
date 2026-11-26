-- Adiciona 15 produtos com fotos individuais ao Hortifruti.
-- A consulta por nome e categoria permite reaplicar esta migration sem duplicar produtos.
INSERT INTO produtos(id_categoria,nome,tipo_medida,preco_unitario,estoque_qtd,imagem_url,destaque)
SELECT c.id_categoria,p.nome,p.tipo_medida,p.preco_unitario,p.estoque_qtd,p.imagem_url,0
FROM categorias c
JOIN (
  SELECT 'Maçã Fuji' nome,'KG' tipo_medida,8.90 preco_unitario,40.000 estoque_qtd,'/assets/images/produto-hortifruti-maca-fuji.jpg' imagem_url UNION ALL
  SELECT 'Laranja Pera','KG',4.79,50.000,'/assets/images/produto-hortifruti-laranja-pera.jpg' UNION ALL
  SELECT 'Uva Thompson','KG',11.90,30.000,'/assets/images/produto-hortifruti-uva-thompson.jpg' UNION ALL
  SELECT 'Mamão Papaya','UN',6.49,25.000,'/assets/images/produto-hortifruti-mamao-papaya.jpg' UNION ALL
  SELECT 'Abacaxi Pérola','UN',7.50,20.000,'/assets/images/produto-hortifruti-abacaxi-perola.jpg' UNION ALL
  SELECT 'Morango 250g','UN',9.90,24.000,'/assets/images/produto-hortifruti-morango.jpg' UNION ALL
  SELECT 'Limão Taiti','KG',5.90,35.000,'/assets/images/produto-hortifruti-limao-taiti.jpg' UNION ALL
  SELECT 'Batata Inglesa','KG',5.49,60.000,'/assets/images/produto-hortifruti-batata-inglesa.jpg' UNION ALL
  SELECT 'Cenoura','KG',5.50,45.000,'/assets/images/produto-hortifruti-cenoura.jpg' UNION ALL
  SELECT 'Brócolis Ninja','UN',6.90,22.000,'/assets/images/produto-hortifruti-brocolis.jpg' UNION ALL
  SELECT 'Cebola Nacional','KG',4.29,50.000,'/assets/images/produto-hortifruti-cebola.jpg' UNION ALL
  SELECT 'Pepino Japonês','KG',7.90,25.000,'/assets/images/produto-hortifruti-pepino-japones.jpg' UNION ALL
  SELECT 'Pimentão Verde','KG',8.90,24.000,'/assets/images/produto-hortifruti-pimentao-verde.jpg' UNION ALL
  SELECT 'Manga Palmer','KG',7.49,28.000,'/assets/images/produto-hortifruti-manga-palmer.jpg' UNION ALL
  SELECT 'Alface Americana','UN',3.49,30.000,'/assets/images/produto-hortifruti-alface-americana.jpg'
) p
WHERE c.slug='hortifruti'
  AND NOT EXISTS (
    SELECT 1 FROM produtos ja WHERE ja.id_categoria=c.id_categoria AND ja.nome=p.nome
  );
