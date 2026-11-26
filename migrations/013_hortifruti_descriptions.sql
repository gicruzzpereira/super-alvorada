UPDATE produtos p
JOIN categorias c USING(id_categoria)
SET p.descricao = CASE p.nome
  WHEN 'Banana prata' THEN 'Doce e macia, ótima para lanches e vitaminas.'
  WHEN 'Tomate italiano' THEN 'Tomates maduros e suculentos para saladas e molhos.'
  WHEN 'Alface crespa' THEN 'Folhas frescas e crocantes para saladas.'
  WHEN 'Maçã Fuji' THEN 'Maçã firme e suculenta, perfeita para comer a qualquer hora.'
  WHEN 'Laranja Pera' THEN 'Laranja doce e aromática, ideal para sucos naturais.'
  WHEN 'Uva Thompson' THEN 'Uvas verdes sem sementes, leves e refrescantes.'
  WHEN 'Mamão Papaya' THEN 'Mamão de polpa macia e sabor suave para o café da manhã.'
  WHEN 'Abacaxi Pérola' THEN 'Abacaxi doce e perfumado para servir ou preparar sucos.'
  WHEN 'Morango 250g' THEN 'Morangos selecionados, frescos e cheios de sabor.'
  WHEN 'Limão Taiti' THEN 'Limão fresco para temperos, bebidas e receitas.'
  WHEN 'Batata Inglesa' THEN 'Batatas versáteis para assar, cozinhar ou preparar purês.'
  WHEN 'Cenoura' THEN 'Cenouras frescas e crocantes para saladas e pratos quentes.'
  WHEN 'Brócolis Ninja' THEN 'Brócolis compacto e fresco, ótimo no vapor ou refogado.'
  WHEN 'Cebola Nacional' THEN 'Cebolas selecionadas para dar sabor às suas receitas.'
  WHEN 'Pepino Japonês' THEN 'Pepino fresco e crocante para saladas e conservas.'
  WHEN 'Pimentão Verde' THEN 'Pimentão verde fresco para saladas, refogados e recheios.'
  WHEN 'Manga Palmer' THEN 'Manga Palmer de polpa macia e sabor adocicado.'
  WHEN 'Alface Americana' THEN 'Alface de folhas firmes e crocantes para sanduíches e saladas.'
  ELSE p.descricao
END
WHERE c.slug='hortifruti'
  AND p.nome IN ('Banana prata','Tomate italiano','Alface crespa','Maçã Fuji','Laranja Pera','Uva Thompson','Mamão Papaya','Abacaxi Pérola','Morango 250g','Limão Taiti','Batata Inglesa','Cenoura','Brócolis Ninja','Cebola Nacional','Pepino Japonês','Pimentão Verde','Manga Palmer','Alface Americana');
