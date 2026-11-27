-- Amplia a Padaria & Confeitaria sem duplicar os produtos cadastrados.
INSERT INTO produtos (id_categoria, nome, descricao, tipo_medida, preco_unitario, estoque_qtd, imagem_url, destaque)
SELECT c.id_categoria, p.nome, p.descricao, 'UN', p.preco, p.estoque,
       CONCAT('/assets/images/produto-padaria-', p.foto, '.jpg'), 0
FROM categorias c
CROSS JOIN (
    SELECT 'Pão de Batata Recheado com Requeijão' AS nome, 'Pão de batata macio com recheio cremoso de requeijão.' AS descricao, 6.49 AS preco, 24 AS estoque, 'pao-batata-requeijao' AS foto UNION ALL
    SELECT 'Pão Australiano Artesanal', 'Pão escuro de sabor levemente adocicado, com casca polvilhada.', 16.90, 16, 'pao-australiano' UNION ALL
    SELECT 'Baguete Francesa Tradicional', 'Baguete de casca crocante e miolo aerado.', 9.49, 20, 'baguete-francesa' UNION ALL
    SELECT 'Brioche de Leite (Pacote 400g)', 'Brioche macio de leite com casca dourada. Pacote de 400 g.', 14.90, 18, 'brioche-leite' UNION ALL
    SELECT 'Pão Sírio Integral (Pacote 300g)', 'Pães sírios integrais macios para rechear ou acompanhar pastas. Pacote de 300 g.', 10.90, 18, 'pao-sirio-integral' UNION ALL
    SELECT 'Coxinha de Frango com Catupiry (Assada)', 'Coxinha assada com recheio de frango desfiado e Catupiry.', 8.49, 25, 'coxinha-frango-catupiry-assada' UNION ALL
    SELECT 'Esfiha Aberta de Carne', 'Massa assada com borda macia e recheio aberto de carne moída.', 6.90, 24, 'esfiha-aberta-carne' UNION ALL
    SELECT 'Empada de Palmito', 'Empada de massa quebradiça com recheio cremoso de palmito.', 7.49, 22, 'empada-palmito' UNION ALL
    SELECT 'Enroladinho de Presunto e Queijo', 'Enroladinho assado com presunto e queijo derretido.', 6.99, 24, 'enroladinho-presunto-queijo' UNION ALL
    SELECT 'Pão de Mel Recheado com Doce de Leite', 'Pão de mel coberto com chocolate e recheado com doce de leite.', 6.99, 20, 'pao-mel-doce-de-leite' UNION ALL
    SELECT 'Brownie de Chocolate Meio Amargo', 'Brownie de chocolate meio amargo, com casquinha fina e miolo denso.', 8.90, 18, 'brownie-meio-amargo' UNION ALL
    SELECT 'Torta de Limão com Merengue (Fatia)', 'Fatia de torta com creme de limão, base crocante e merengue dourado.', 11.90, 16, 'torta-limao-merengue' UNION ALL
    SELECT 'Pudim de Leite Condensado (Fatia)', 'Fatia de pudim cremoso de leite condensado com calda de caramelo.', 9.90, 16, 'pudim-leite-condensado' UNION ALL
    SELECT 'Biscoito Polvilho Assado (Pacote 200g)', 'Biscoitos de polvilho leves e crocantes. Pacote de 200 g.', 8.99, 20, 'biscoito-polvilho' UNION ALL
    SELECT 'Sequilhos de Leite Condensado (Pote 250g)', 'Biscoitinhos delicados de leite condensado. Pote de 250 g.', 12.90, 18, 'sequilhos-leite-condensado'
) p
WHERE c.slug = 'padaria'
  AND NOT EXISTS (
      SELECT 1 FROM produtos existente
      WHERE existente.id_categoria = c.id_categoria AND existente.nome = p.nome
  );
