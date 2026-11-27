CREATE DATABASE IF NOT EXISTS supermercado_alvorada CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE supermercado_alvorada;
SET FOREIGN_KEY_CHECKS=0;
SET FOREIGN_KEY_CHECKS=1;
CREATE TABLE usuarios(id_usuario INT AUTO_INCREMENT PRIMARY KEY,nome VARCHAR(100) NOT NULL,email VARCHAR(100) NOT NULL UNIQUE,senha VARCHAR(255) NOT NULL,perfil ENUM('visitante','cliente','admin','separador','entregador') NOT NULL DEFAULT 'cliente',telefone VARCHAR(20),foto_perfil VARCHAR(255) NULL,data_nascimento DATE NULL,data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP) ENGINE=InnoDB;
CREATE TABLE enderecos(id_endereco INT AUTO_INCREMENT PRIMARY KEY,id_usuario INT NOT NULL,logradouro VARCHAR(150) NOT NULL,numero VARCHAR(20) NOT NULL,bairro VARCHAR(80) NOT NULL,cidade VARCHAR(80) NOT NULL,cep VARCHAR(10) NOT NULL,atendido TINYINT(1) DEFAULT 1,FOREIGN KEY(id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE) ENGINE=InnoDB;
CREATE TABLE categorias(id_categoria INT AUTO_INCREMENT PRIMARY KEY,nome VARCHAR(50) NOT NULL,slug VARCHAR(50) NOT NULL UNIQUE,imagem_url VARCHAR(255) NULL) ENGINE=InnoDB;
CREATE TABLE produtos(id_produto INT AUTO_INCREMENT PRIMARY KEY,id_categoria INT NOT NULL,nome VARCHAR(100) NOT NULL,descricao VARCHAR(255) NULL,tipo_medida ENUM('UN','KG') NOT NULL DEFAULT 'UN',preco_unitario DECIMAL(10,2) NOT NULL,estoque_qtd DECIMAL(10,3) NOT NULL,imagem_url VARCHAR(255),destaque TINYINT(1) DEFAULT 0,ativo TINYINT(1) DEFAULT 1,FOREIGN KEY(id_categoria) REFERENCES categorias(id_categoria)) ENGINE=InnoDB;
CREATE TABLE cupons(id_cupom INT AUTO_INCREMENT PRIMARY KEY,codigo VARCHAR(40) NOT NULL UNIQUE,titulo VARCHAR(100) NOT NULL,descricao VARCHAR(255) NULL,tipo ENUM('percentual','fixo') NOT NULL,valor DECIMAL(10,2) NOT NULL,pedido_minimo DECIMAL(10,2) NOT NULL DEFAULT 0,validade DATE NULL,limite_usos INT NULL,usos INT NOT NULL DEFAULT 0,ativo TINYINT(1) NOT NULL DEFAULT 1,data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP) ENGINE=InnoDB;
CREATE TABLE pedidos(id_pedido INT AUTO_INCREMENT PRIMARY KEY,id_cliente INT NOT NULL,id_separador INT NULL,id_entregador INT NULL,id_endereco INT NULL,id_cupom INT NULL,valor_desconto DECIMAL(10,2) NOT NULL DEFAULT 0,status ENUM('pendente','em_separacao','aguardando_aprovacao','pronto','em_transito','entregue','cancelado','problema') DEFAULT 'pendente',valor_subtotal DECIMAL(10,2) NOT NULL,valor_frete DECIMAL(10,2) NOT NULL DEFAULT 5.00,valor_total DECIMAL(10,2) NOT NULL,metodo_pagamento ENUM('pix','cartao_credito','dinheiro_entrega') NOT NULL,modalidade_entrega ENUM('expressa','agendada','retirada') NOT NULL DEFAULT 'agendada',cep_entrega VARCHAR(9) NULL,data_entrega DATE NULL,horario_entrega VARCHAR(40) NULL,pin_entrega VARCHAR(6) NOT NULL UNIQUE,observacao_separacao TEXT,observacao_problema TEXT,data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,FOREIGN KEY(id_cliente) REFERENCES usuarios(id_usuario),FOREIGN KEY(id_separador) REFERENCES usuarios(id_usuario),FOREIGN KEY(id_entregador) REFERENCES usuarios(id_usuario),FOREIGN KEY(id_endereco) REFERENCES enderecos(id_endereco),FOREIGN KEY(id_cupom) REFERENCES cupons(id_cupom)) ENGINE=InnoDB;
CREATE TABLE cupons_clientes(id_cupom_cliente INT AUTO_INCREMENT PRIMARY KEY,id_usuario INT NOT NULL,id_cupom INT NOT NULL,id_pedido INT NULL,resgatado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,usado_em TIMESTAMP NULL,UNIQUE KEY uk_cupom_cliente(id_usuario,id_cupom),FOREIGN KEY(id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE,FOREIGN KEY(id_cupom) REFERENCES cupons(id_cupom) ON DELETE CASCADE,FOREIGN KEY(id_pedido) REFERENCES pedidos(id_pedido) ON DELETE SET NULL) ENGINE=InnoDB;
CREATE TABLE itens_pedido(id_item INT AUTO_INCREMENT PRIMARY KEY,id_pedido INT NOT NULL,id_produto INT NOT NULL,qtd_solicitada DECIMAL(10,3) NOT NULL,qtd_separada DECIMAL(10,3) NULL,preco_aplicado DECIMAL(10,2) NOT NULL,substituido_id_produto INT NULL,status_item ENUM('solicitado','separado','substituido','em_falta') DEFAULT 'solicitado',FOREIGN KEY(id_pedido) REFERENCES pedidos(id_pedido) ON DELETE CASCADE,FOREIGN KEY(id_produto) REFERENCES produtos(id_produto),FOREIGN KEY(substituido_id_produto) REFERENCES produtos(id_produto)) ENGINE=InnoDB;
CREATE TABLE respostas_item(id_resposta INT AUTO_INCREMENT PRIMARY KEY,id_item INT NOT NULL UNIQUE,cliente_aprovou TINYINT(1) NULL,motivo VARCHAR(255),respondido_em TIMESTAMP NULL,FOREIGN KEY(id_item) REFERENCES itens_pedido(id_item) ON DELETE CASCADE) ENGINE=InnoDB;
CREATE TABLE configuracoes(chave VARCHAR(60) PRIMARY KEY,valor VARCHAR(255) NOT NULL) ENGINE=InnoDB;
CREATE TABLE auditoria(id_auditoria BIGINT AUTO_INCREMENT PRIMARY KEY,id_usuario INT NULL,id_pedido INT NULL,acao VARCHAR(100) NOT NULL,detalhes TEXT,criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,FOREIGN KEY(id_usuario) REFERENCES usuarios(id_usuario) ON DELETE SET NULL,FOREIGN KEY(id_pedido) REFERENCES pedidos(id_pedido) ON DELETE SET NULL) ENGINE=InnoDB;
INSERT INTO categorias(nome,slug) VALUES ('Hortifrúti','hortifruti'),('Padaria','padaria'),('Açougue','acougue'),('Bebidas','bebidas'),('Limpeza','limpeza'),('Farmácia','farmacia'),('Pets','pets'),('Peixaria','peixaria'),('Frios & Laticínios','frios-laticinios'),('Mercearia & Grãos','mercearia-graos'),('Higiene & Perfumaria','higiene-perfumaria'),('Jornal da Semana','jornal');
INSERT INTO produtos(id_categoria,nome,tipo_medida,preco_unitario,estoque_qtd,imagem_url,destaque) VALUES
(1,'Banana prata','KG',7.99,80,'/assets/images/produto-hortifruti-banana-prata.jpg',1),(1,'Tomate italiano','KG',8.49,60,NULL,1),(1,'Alface crespa','UN',3.50,40,NULL,0),(2,'Pão francês','KG',16.90,50,NULL,1),(2,'Pão de forma','UN',8.90,35,NULL,0),(3,'Peito de frango','KG',19.90,45,NULL,1),(3,'Carne moída','KG',32.90,40,NULL,0),(4,'Suco de laranja 1L','UN',9.50,30,NULL,1),(4,'Água mineral 1,5L','UN',3.25,100,NULL,0),(5,'Detergente neutro','UN',2.79,70,'/assets/images/produto-limpeza-detergente-neutro.jpg',0),(5,'Sabão em pó 1kg','UN',12.90,32,'/assets/images/produto-limpeza-sabao-po-1kg.jpg',1);
INSERT INTO produtos(id_categoria,nome,tipo_medida,preco_unitario,estoque_qtd,imagem_url,destaque) VALUES
(1,'Maçã Fuji','KG',8.90,40,'/assets/images/produto-hortifruti-maca-fuji.jpg',0),
(1,'Laranja Pera','KG',4.79,50,'/assets/images/produto-hortifruti-laranja-pera.jpg',0),
(1,'Uva Thompson','KG',11.90,30,'/assets/images/produto-hortifruti-uva-thompson.jpg',0),
(1,'Mamão Papaya','UN',6.49,25,'/assets/images/produto-hortifruti-mamao-papaya.jpg',0),
(1,'Abacaxi Pérola','UN',7.50,20,'/assets/images/produto-hortifruti-abacaxi-perola.jpg',0),
(1,'Morango 250g','UN',9.90,24,'/assets/images/produto-hortifruti-morango.jpg',0),
(1,'Limão Taiti','KG',5.90,35,'/assets/images/produto-hortifruti-limao-taiti.jpg',0),
(1,'Batata Inglesa','KG',5.49,60,'/assets/images/produto-hortifruti-batata-inglesa.jpg',0),
(1,'Cenoura','KG',5.50,45,'/assets/images/produto-hortifruti-cenoura.jpg',0),
(1,'Brócolis Ninja','UN',6.90,22,'/assets/images/produto-hortifruti-brocolis.jpg',0),
(1,'Cebola Nacional','KG',4.29,50,'/assets/images/produto-hortifruti-cebola.jpg',0),
(1,'Pepino Japonês','KG',7.90,25,'/assets/images/produto-hortifruti-pepino-japones.jpg',0),
(1,'Pimentão Verde','KG',8.90,24,'/assets/images/produto-hortifruti-pimentao-verde.jpg',0),
(1,'Manga Palmer','KG',7.49,28,'/assets/images/produto-hortifruti-manga-palmer.jpg',0),
(1,'Alface Americana','UN',3.49,30,'/assets/images/produto-hortifruti-alface-americana.jpg',0);
UPDATE produtos SET imagem_url='/assets/images/produto-hortifruti-tomate-italiano.jpg' WHERE id_categoria=1 AND nome='Tomate italiano';
UPDATE produtos SET imagem_url='/assets/images/produto-hortifruti-alface-crespa.jpg' WHERE id_categoria=1 AND nome='Alface crespa';
UPDATE produtos p JOIN categorias c USING(id_categoria) SET p.descricao=CASE p.nome
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
  ELSE p.descricao END WHERE c.slug='hortifruti';
INSERT INTO configuracoes(chave,valor) VALUES('frete_padrao','5.00'),('loja_latitude','-23.55052'),('loja_longitude','-46.63331'),('agendamento_dias','1,2,3,4,5,6'),('agendamento_horarios','09:00-12:00
14:00-18:00'),('entrega_horarios','09:00-10:00
10:00-11:00
11:00-12:00
14:00-15:00
15:00-16:00
16:00-17:00
17:00-18:00'),('retirada_horarios','09:00-12:00
14:00-18:00');

CREATE TABLE IF NOT EXISTS newsletter_inscritos(id_inscrito INT AUTO_INCREMENT PRIMARY KEY,email VARCHAR(190) NOT NULL UNIQUE,ativo TINYINT(1) NOT NULL DEFAULT 1,consentido_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Promotional content and storefront metadata are database-backed.
CREATE TABLE IF NOT EXISTS banners_site (
  id_banner INT AUTO_INCREMENT PRIMARY KEY,
  titulo VARCHAR(140) NOT NULL,
  texto_alternativo VARCHAR(255) NOT NULL,
  imagem_url VARCHAR(255) NOT NULL,
  categoria_slug VARCHAR(60) NULL,
  link_url VARCHAR(255) NOT NULL DEFAULT '#ofertas',
  ordem INT NOT NULL DEFAULT 0,
  ativo TINYINT(1) NOT NULL DEFAULT 1,
  atualizado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_banners_imagem (imagem_url),
  INDEX idx_banners_ativos (ativo,ordem)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS promocoes_site (
  id_promocao INT AUTO_INCREMENT PRIMARY KEY,
  slug VARCHAR(80) NOT NULL UNIQUE,
  tipo ENUM('card','encarte') NOT NULL,
  etiqueta VARCHAR(100) NOT NULL,
  titulo VARCHAR(160) NOT NULL,
  chamada VARCHAR(160) NOT NULL,
  imagem_url VARCHAR(255) NULL,
  categoria_slug VARCHAR(60) NULL,
  ordem INT NOT NULL DEFAULT 0,
  ativo TINYINT(1) NOT NULL DEFAULT 1,
  inicio_vigencia DATE NULL,
  fim_vigencia DATE NULL,
  atualizado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_promocoes_visiveis (ativo,tipo,ordem)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS itens_encarte_site (
  id_item_encarte INT AUTO_INCREMENT PRIMARY KEY,
  slug VARCHAR(80) NOT NULL UNIQUE,
  nome VARCHAR(140) NOT NULL,
  detalhe VARCHAR(80) NOT NULL,
  preco DECIMAL(10,2) NOT NULL,
  tipo_medida ENUM('UN','KG') NOT NULL DEFAULT 'UN',
  ordem INT NOT NULL DEFAULT 0,
  ativo TINYINT(1) NOT NULL DEFAULT 1,
  INDEX idx_encarte_ativos (ativo,ordem)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS conteudo_site (
  chave VARCHAR(100) PRIMARY KEY,
  valor TEXT NOT NULL,
  atualizado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS cliente_estado_site (
  id_usuario INT PRIMARY KEY,
  carrinho_json LONGTEXT NULL,
  favoritos_json LONGTEXT NULL,
  localizacao_json LONGTEXT NULL,
  atualizado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_cliente_estado_site_usuario FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS visitante_estado_site (
  session_token CHAR(64) PRIMARY KEY,
  carrinho_json LONGTEXT NULL,
  favoritos_json LONGTEXT NULL,
  localizacao_json LONGTEXT NULL,
  atualizado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  expira_em DATETIME NOT NULL,
  INDEX idx_visitante_expira (expira_em)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

UPDATE categorias SET imagem_url='/assets/images/capa-destaque-hortifruti.png?v=2' WHERE slug='hortifruti';
UPDATE categorias SET imagem_url='/assets/images/capa-destaque-padaria.png?v=1' WHERE slug='padaria';
UPDATE categorias SET imagem_url='/assets/images/capa-destaque-acougue.png?v=1' WHERE slug='acougue';
UPDATE categorias SET imagem_url='/assets/images/capa-destaque-bebidas.png?v=2' WHERE slug='bebidas';
UPDATE categorias SET imagem_url='/assets/images/capa-destaque-limpeza.png?v=1' WHERE slug='limpeza';
UPDATE categorias SET imagem_url='/assets/images/capa-destaque-farmacia.png?v=1' WHERE slug='farmacia';
UPDATE categorias SET imagem_url='/assets/images/capa-destaque-pets.png?v=1' WHERE slug='pets';
UPDATE categorias SET imagem_url='/assets/images/capa-destaque-peixaria.png?v=1' WHERE slug='peixaria';
UPDATE categorias SET imagem_url='/assets/images/capa-destaque-laticinios.png?v=1' WHERE slug='frios-laticinios';
UPDATE categorias SET imagem_url='/assets/images/capa-destaque-mercearia.jpg?v=2' WHERE slug='mercearia-graos';
UPDATE categorias SET imagem_url='/assets/images/capa-destaque-higiene.png?v=1' WHERE slug='higiene-perfumaria';

INSERT INTO banners_site(titulo,texto_alternativo,imagem_url,categoria_slug,link_url,ordem,ativo) VALUES
('Compras entregues na sua casa','Compras entregues na sua casa pelo Supermercado Alvorada','/assets/images/alvorada-hero-novo.jpg?v=1','todos','#ofertas',1,1),
('Terça do Hortifruti','Menos preço, mais frescor na sua mesa; hortifruti em até 30% off e entrega grátis','/assets/images/banner-hortifruti-alvorada.webp?v=1','hortifruti','#produtos',2,1),
('Ofertas de medicamentos','Ofertas do dia em medicamentos com preços acessíveis','/assets/images/banner-farmacia-alvorada.webp?v=1','farmacia','#produtos',3,1),
('Dia do pão','Pães, bolos e salgados com ótimos preços','/assets/images/banner-dia-do-pao.jpg?v=1','padaria','#produtos',4,1),
('Ofertas de churrasco','Ofertas para você acender a brasa; melhores cortes','/assets/images/banner-churrasco.jpg?v=1','acougue','#produtos',5,1),
('Saldão de ração','Saldão de ração para pets com até 50% de desconto','/assets/images/banner-saldao-pet.jpg?v=1','pets','#produtos',6,1),
('Preço baixo','Preço baixo no Supermercado Alvorada','/assets/images/banner-preco-baixo.jpg?v=1','mercearia-graos','#produtos',7,1),
('Cupons diários','Banner de cupons diários do Supermercado Alvorada. Acesse a página de cupons e resgate descontos.','/assets/images/banner-cupons-diarios.jpg','todos','/cupons.php',8,1)
ON DUPLICATE KEY UPDATE titulo=VALUES(titulo),texto_alternativo=VALUES(texto_alternativo),imagem_url=VALUES(imagem_url),categoria_slug=VALUES(categoria_slug),link_url=VALUES(link_url),ordem=VALUES(ordem),ativo=VALUES(ativo);

INSERT INTO promocoes_site(slug,tipo,etiqueta,titulo,chamada,imagem_url,categoria_slug,ordem,ativo) VALUES
('fim-de-semana','card','Especial Fim de Semana','Até 30% OFF','Em Frutas Frescas','/assets/images/capa-destaque-hortifruti.png?v=2','hortifruti',1,1),
('economia-despensa','card','Economia na Despensa','Até 25% OFF','Em Itens do Dia a Dia','/assets/images/capa-destaque-mercearia.jpg?v=2','mercearia-graos',2,1),
('festival-padaria','card','Festival da Padaria','Leve 2 Pague 1','Em Pães e Biscoitos','/assets/images/capa-destaque-padaria.png?v=1','padaria',3,1),
('encarte-ofertas-dia','encarte','Economize no Alvorada','Ofertas do Dia','Encarte de ofertas do Supermercado Alvorada','/assets/images/encarte-ofertas-do-dia.webp?v=1','todos',1,1)
ON DUPLICATE KEY UPDATE tipo=VALUES(tipo),etiqueta=VALUES(etiqueta),titulo=VALUES(titulo),chamada=VALUES(chamada),imagem_url=VALUES(imagem_url),categoria_slug=VALUES(categoria_slug),ordem=VALUES(ordem),ativo=VALUES(ativo);

INSERT INTO itens_encarte_site(slug,nome,detalhe,preco,tipo_medida,ordem,ativo) VALUES
('cuscuz-flocao-500g','Cuscuz Flocão 500g','500 g',1.89,'UN',1,1),
('leite-po-integral-400g','Leite em Pó Integral 400g','400 g',14.90,'UN',2,1),
('acucar-cristal-1kg','Açúcar Cristal 1kg','1 kg',3.49,'UN',3,1),
('biscoito-agua-sal-350g','Biscoito Água e Sal 350g','350 g',4.50,'UN',4,1),
('cafe-torrado-moido-500g','Café Torrado e Moído 500g','500 g',13.90,'UN',5,1),
('arroz-branco-tipo1-5kg','Arroz Branco Tipo 1 5kg','5 kg',24.90,'UN',6,1),
('multiuso-limpeza-500ml','Multiuso Limpeza 500ml','500 ml',3.85,'UN',7,1),
('papel-higienico-folha-dupla-12','Papel Higiênico Folha Dupla 12 rolos','12 rolos',14.50,'UN',8,1),
('lava-roupas-liquido-3l','Lava-Roupas Líquido 3L','3 L',16.90,'UN',9,1),
('pao-frances-500g','Pão Francês 500g','500 g',6.50,'UN',10,1),
('leite-condensado-395g','Leite Condensado 395g','395 g',6.25,'UN',11,1),
('feijao-carioca-1kg','Feijão Carioca 1kg','1 kg',7.60,'UN',12,1)
ON DUPLICATE KEY UPDATE nome=VALUES(nome),detalhe=VALUES(detalhe),preco=VALUES(preco),tipo_medida=VALUES(tipo_medida),ordem=VALUES(ordem),ativo=VALUES(ativo);

INSERT INTO conteudo_site(chave,valor) VALUES
('home.slogan','Qualidade e economia para o seu dia a dia.'),
('home.newsletter.titulo','Inscreva-se em nossa Newsletter para receber ofertas exclusivas'),
('home.newsletter.texto','Receba novidades, descontos e ofertas do Supermercado Alvorada diretamente no seu e-mail.'),
('home.footer.atendimento','Precisa de ajuda com seu pedido?')
ON DUPLICATE KEY UPDATE valor=VALUES(valor);


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


-- Atualiza os itens equivalentes, preservando IDs, preços e estoque.
UPDATE produtos p
JOIN categorias c ON c.id_categoria = p.id_categoria
JOIN (
    SELECT 'Pão francês' AS antigo, 'Pão Francês Fresquinho' AS nome, 'Casquinha crocante e miolo macio, vendido por quilo.' AS descricao, 'pao-frances' AS foto UNION ALL
    SELECT 'Pão de forma', 'Pão de Forma Tradicional (Pacote 500g)', 'Pão fatiado de miolo macio para sanduíches e torradas. Pacote de 500 g.', 'pao-de-forma-tradicional'
) dados ON p.nome = dados.antigo
LEFT JOIN produtos existente ON existente.id_categoria = p.id_categoria AND existente.nome = dados.nome
SET p.nome = dados.nome,
    p.descricao = dados.descricao,
    p.imagem_url = CONCAT('/assets/images/produto-padaria-', dados.foto, '.jpg')
WHERE c.slug = 'padaria' AND existente.id_produto IS NULL;

-- Cadastra os demais itens da Padaria & Confeitaria.
INSERT INTO produtos (id_categoria, nome, descricao, tipo_medida, preco_unitario, estoque_qtd, imagem_url, destaque)
SELECT c.id_categoria, p.nome, p.descricao, p.unidade, p.preco, p.estoque,
       CONCAT('/assets/images/produto-padaria-', p.foto, '.jpg'), 0
FROM categorias c
CROSS JOIN (
    SELECT 'Pão Francês Fresquinho' AS nome, 'Casquinha crocante e miolo macio, vendido por quilo.' AS descricao, 'KG' AS unidade, 16.90 AS preco, 50 AS estoque, 'pao-frances' AS foto UNION ALL
    SELECT 'Pão de Queijo Tradicional (Assado na Hora)', 'Pão de queijo dourado, com casquinha fina e miolo macio.', 'UN', 3.99, 40, 'pao-de-queijo' UNION ALL
    SELECT 'Pão de Forma Tradicional (Pacote 500g)', 'Pão fatiado de miolo macio para sanduíches e torradas. Pacote de 500 g.', 'UN', 8.90, 35, 'pao-de-forma-tradicional' UNION ALL
    SELECT 'Pão de Forma Integral (Pacote 500g)', 'Pão integral fatiado para sanduíches e torradas. Pacote de 500 g.', 'UN', 11.90, 30, 'pao-de-forma-integral' UNION ALL
    SELECT 'Bisnaguinha Tradicional (Pacote 300g)', 'Pãezinhos macios de sabor suave. Pacote de 300 g.', 'UN', 8.49, 24, 'bisnaguinha' UNION ALL
    SELECT 'Croissant de Manteiga', 'Massa folhada com manteiga, crocante por fora e leve por dentro.', 'UN', 7.49, 22, 'croissant' UNION ALL
    SELECT 'Pão Doce de Creme com Coco', 'Pão doce macio coberto com creme e coco ralado.', 'UN', 5.99, 20, 'pao-doce-creme-coco' UNION ALL
    SELECT 'Sonho de Creme de Baunilha', 'Sonho dourado com creme de baunilha e açúcar polvilhado.', 'UN', 6.49, 20, 'sonho-baunilha' UNION ALL
    SELECT 'Bolo Caseiro de Cenoura com Cobertura de Chocolate', 'Bolo inteiro de cenoura com massa fofinha e cobertura de chocolate.', 'UN', 26.90, 12, 'bolo-cenoura-chocolate' UNION ALL
    SELECT 'Bolo Caseiro de Fubá com Goiabada', 'Bolo inteiro de fubá, com pedaços de goiabada na massa.', 'UN', 23.90, 12, 'bolo-fuba-goiabada' UNION ALL
    SELECT 'Bolo de Chocolate Recheado (Fatia)', 'Uma fatia de bolo de chocolate com camadas de recheio cremoso.', 'UN', 10.90, 16, 'bolo-chocolate-fatia' UNION ALL
    SELECT 'Torta Holandesa (Fatia)', 'Uma fatia de torta cremosa com base de biscoito e ganache de chocolate.', 'UN', 12.90, 16, 'torta-holandesa-fatia' UNION ALL
    SELECT 'Carolina Recheada com Doce de Leite', 'Massa choux leve recheada com doce de leite.', 'UN', 4.99, 20, 'carolina-doce-de-leite' UNION ALL
    SELECT 'Rosquinha de Coco Caseira (Bandeja 300g)', 'Rosquinhas assadas com coco ralado. Bandeja de 300 g.', 'UN', 13.90, 18, 'rosquinha-coco' UNION ALL
    SELECT 'Torrada Tradicional da Casa (Pacote 250g)', 'Fatias douradas e crocantes. Pacote de 250 g.', 'UN', 8.90, 20, 'torrada-tradicional'
) p
WHERE c.slug = 'padaria'
  AND NOT EXISTS (
      SELECT 1 FROM produtos existente
      WHERE existente.id_categoria = c.id_categoria AND existente.nome = p.nome
  );


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


-- Cadastra os novos cortes e pescados no Açougue sem duplicar registros.
INSERT INTO produtos (id_categoria, nome, descricao, tipo_medida, preco_unitario, estoque_qtd, imagem_url, destaque)
SELECT c.id_categoria, p.nome, p.descricao, 'KG', p.preco, p.estoque,
       CONCAT('/assets/images/produto-acougue-', p.foto, '.jpg'), 0
FROM categorias c
CROSS JOIN (
    SELECT 'Contrafilé Bovino (Peça ou Bife)' AS nome, 'Corte bovino com capa de gordura, em peça ou bife.' AS descricao, 49.90 AS preco, 30 AS estoque, 'contrafile' AS foto UNION ALL
    SELECT 'Picanha Bovina Tradicional', 'Corte triangular com capa de gordura, ideal para churrasco.', 79.90, 23, 'picanha' UNION ALL
    SELECT 'Patinho Moído de Primeira', 'Patinho moído, de perfil magro, para molhos, almôndegas e refogados.', 42.90, 32, 'patinho-moido' UNION ALL
    SELECT 'Alcatra Bovina em Bife', 'Bifes de alcatra para grelhar ou preparar na frigideira.', 53.90, 25, 'alcatra-bife' UNION ALL
    SELECT 'Costela Bovina Ripada', 'Costela bovina com osso, cortada em tiras para assar.', 28.90, 30, 'costela-ripada' UNION ALL
    SELECT 'Cupim Bovino', 'Corte marmorizado para assados e preparos de cozimento lento.', 39.90, 18, 'cupim' UNION ALL
    SELECT 'Acém Bovino em Cubos', 'Cubos de acém para ensopados e carnes de panela.', 36.90, 25, 'acem-cubos' UNION ALL
    SELECT 'Peito de Frango sem Osso (Filé)', 'Filés de peito de frango sem osso para grelhar, assar ou empanar.', 22.90, 40, 'peito-frango-file' UNION ALL
    SELECT 'Coxa e Sobrecoxa de Frango', 'Cortes de coxa e sobrecoxa para assar ou cozinhar.', 15.90, 35, 'coxa-sobrecoxa' UNION ALL
    SELECT 'Asa de Frango (Tulipa / Meio da Asa)', 'Cortes de asa de frango para assar ou preparar na grelha.', 18.90, 30, 'asa-frango-tulipa' UNION ALL
    SELECT 'Linguiça Toscana para Churrasco', 'Linguiça suína toscana para grelha, forno ou frigideira.', 24.90, 30, 'linguica-toscana' UNION ALL
    SELECT 'Lombo Suíno Temperado', 'Lombo suíno temperado para assar inteiro ou fatiado.', 29.90, 22, 'lombo-suino-temperado' UNION ALL
    SELECT 'Costelinha Suína', 'Costelinha suína com osso para assar ou preparar na grelha.', 32.90, 24, 'costelinha-suina'
) p
WHERE c.slug = 'acougue'
  AND NOT EXISTS (
      SELECT 1 FROM produtos existente
      WHERE existente.id_categoria = c.id_categoria AND existente.nome = p.nome
  );


-- Adiciona bebidas com fotos das embalagens. Bebidas alcoólicas ficam sem estoque para venda.
INSERT INTO produtos (id_categoria, nome, descricao, tipo_medida, preco_unitario, estoque_qtd, imagem_url, destaque)
SELECT c.id_categoria, p.nome, p.descricao, 'UN', p.preco, p.estoque,
       CONCAT('/assets/images/produto-bebidas-', p.foto, '.jpg'), 0
FROM categorias c
CROSS JOIN (
    SELECT 'Refrigerante Coca-Cola Original (Garrafa 2L)' AS nome, 'Refrigerante de cola, versão original. Garrafa de 2 L.' AS descricao, 10.99 AS preco, 36 AS estoque, 'coca-cola-original-2l' AS foto UNION ALL
    SELECT 'Refrigerante Coca-Cola Zero Açúcar (Garrafa 2L)', 'Refrigerante de cola sem açúcar. Garrafa de 2 L.', 10.99, 36, 'coca-cola-zero-2l' UNION ALL
    SELECT 'Refrigerante Guaraná Antarctica (Garrafa 2L)', 'Refrigerante de guaraná Antarctica. Garrafa de 2 L.', 8.99, 30, 'guarana-antarctica-2l' UNION ALL
    SELECT 'Refrigerante Pepsi Black (Lata 350ml)', 'Refrigerante de cola Pepsi Black sem açúcar. Lata de 350 ml.', 3.99, 36, 'pepsi-black-350ml' UNION ALL
    SELECT 'Refrigerante Fanta Laranja (Garrafa 2L)', 'Refrigerante sabor laranja. Garrafa de 2 L.', 8.99, 30, 'fanta-laranja-2l' UNION ALL
    SELECT 'Energético Monster Energy Original (Lata 473ml)', 'Bebida energética Monster Energy Original. Lata de 473 ml.', 9.99, 24, 'monster-original-473ml' UNION ALL
    SELECT 'Energético Red Bull Energy Drink (Lata 250ml)', 'Bebida energética Red Bull Energy Drink. Lata de 250 ml.', 9.49, 24, 'red-bull-250ml' UNION ALL
    SELECT 'Suco Integral de Uva Aurora (Garrafa 1,5L)', 'Suco integral de uva tinto Aurora. Garrafa de 1,5 L.', 22.90, 18, 'suco-uva-aurora-15l' UNION ALL
    SELECT 'Suco Del Valle Néctar Pêssego (Caixa 1L)', 'Néctar de pêssego Del Valle. Caixa de 1 L.', 7.49, 25, 'del-valle-pessego-1l' UNION ALL
    SELECT 'Água de Coco Kero Coco (Caixa 1L)', 'Água de coco Kero Coco. Caixa de 1 L.', 11.90, 22, 'kero-coco-1l' UNION ALL
    SELECT 'Água Mineral Crystal sem Gás (Garrafa 500ml)', 'Água mineral natural sem gás. Garrafa de 500 ml.', 2.49, 40, 'crystal-sem-gas-500ml' UNION ALL
    SELECT 'Água Mineral Minalba com Gás (Garrafa 510ml)', 'Água mineral com gás. Garrafa de 510 ml.', 2.99, 35, 'minalba-com-gas-510ml' UNION ALL
    SELECT 'Chá Gelado Leão Fuze Limão (Garrafa 1,5L)', 'Chá gelado Leão Fuze sabor limão. Garrafa de 1,5 L.', 8.99, 24, 'leao-fuze-limao-15l' UNION ALL
    SELECT 'Cerveja Heineken Lager (Long Neck 330ml)', 'Cerveja lager Heineken. Garrafa long neck de 330 ml.', 0.00, 0, 'heineken-lager-330ml' UNION ALL
    SELECT 'Cerveja Brahma Chopp Pilsen (Lata 350ml)', 'Cerveja pilsen Brahma Chopp. Lata de 350 ml.', 0.00, 0, 'brahma-chopp-350ml' UNION ALL
    SELECT 'Cerveja Skol Pilsen (Lata 350ml)', 'Cerveja pilsen Skol. Lata de 350 ml.', 0.00, 0, 'skol-pilsen-350ml' UNION ALL
    SELECT 'Cerveja Heineken 0.0 Zero Álcool (Long Neck 330ml)', 'Heineken 0.0 sem álcool. Garrafa long neck de 330 ml.', 6.99, 24, 'heineken-zero-330ml' UNION ALL
    SELECT 'Vinho Tinto Suave Pérgola (Garrafa 1L)', 'Vinho tinto suave Pérgola. Garrafa de 1 L.', 0.00, 0, 'vinho-pergola-1l' UNION ALL
    SELECT 'Vinho Tinto Reservado Concha y Toro Cabernet Sauvignon (Garrafa 750ml)', 'Vinho tinto Cabernet Sauvignon da linha Reservado. Garrafa de 750 ml.', 0.00, 0, 'vinho-concha-y-toro-750ml' UNION ALL
    SELECT 'Espumante Salton Brut (Garrafa 750ml)', 'Espumante Salton Brut. Garrafa de 750 ml.', 0.00, 0, 'espumante-salton-brut-750ml'
) p
WHERE c.slug = 'bebidas'
  AND NOT EXISTS (
      SELECT 1 FROM produtos existente
      WHERE existente.id_categoria = c.id_categoria AND existente.nome = p.nome
  );


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


-- Inclui destilados para exibição no catálogo, com compra indisponível.
INSERT INTO produtos (id_categoria, nome, descricao, tipo_medida, preco_unitario, estoque_qtd, imagem_url, destaque)
SELECT c.id_categoria, p.nome, p.descricao, 'UN', 0, 0,
       CONCAT('/assets/images/produto-bebidas-', p.foto, '.jpg'), 0
FROM categorias c
CROSS JOIN (
    SELECT 'Whisky Johnnie Walker Red Label (Garrafa 1L)' AS nome, 'Whisky Johnnie Walker Red Label. Garrafa de 1 L.' AS descricao, 'red-label-1l' AS foto UNION ALL
    SELECT 'Whisky Johnnie Walker Black Label 12 Anos (Garrafa 750ml)', 'Whisky Johnnie Walker Black Label 12 Anos. Garrafa de 750 ml.', 'black-label-750ml' UNION ALL
    SELECT 'Whisky Jack Daniel''s Old No. 7 Tennessee (Garrafa 1L)', 'Whisky Jack Daniel''s Old No. 7 Tennessee. Garrafa de 1 L.', 'jack-daniels-1l' UNION ALL
    SELECT 'Whisky Ballantine''s Finest (Garrafa 1L)', 'Whisky Ballantine''s Finest. Garrafa de 1 L.', 'ballantines-1l' UNION ALL
    SELECT 'Whisky Chivas Regal 12 Anos (Garrafa 750ml)', 'Whisky Chivas Regal 12 Anos. Garrafa de 750 ml.', 'chivas-750ml' UNION ALL
    SELECT 'Whisky White Horse (Garrafa 1L)', 'Whisky White Horse. Garrafa de 1 L.', 'white-horse-1l' UNION ALL
    SELECT 'Gin Tanqueray London Dry (Garrafa 750ml)', 'Gin Tanqueray London Dry. Garrafa de 750 ml.', 'tanqueray-750ml' UNION ALL
    SELECT 'Gin Beefeater London Dry (Garrafa 750ml)', 'Gin Beefeater London Dry. Garrafa de 750 ml.', 'beefeater-750ml' UNION ALL
    SELECT 'Gin Gordon''s London Dry (Garrafa 750ml)', 'Gin Gordon''s London Dry. Garrafa de 750 ml.', 'gordons-750ml' UNION ALL
    SELECT 'Gin Bombay Sapphire (Garrafa 750ml)', 'Gin Bombay Sapphire. Garrafa de 750 ml.', 'bombay-750ml' UNION ALL
    SELECT 'Gin Rock''s Strawberry (Garrafa 1L)', 'Gin Rock''s Strawberry. Garrafa de 1 L.', 'rocks-strawberry-1l' UNION ALL
    SELECT 'Gin Seagers (Garrafa 980ml)', 'Gin Seagers. Garrafa de 980 ml.', 'seagers-980ml'
) p
WHERE c.slug = 'bebidas'
  AND NOT EXISTS (
      SELECT 1 FROM produtos existente
      WHERE existente.id_categoria = c.id_categoria AND existente.nome = p.nome
  );


-- Adiciona produtos de marca ao catálogo de Limpeza sem duplicar registros.
INSERT INTO produtos (id_categoria, nome, descricao, tipo_medida, preco_unitario, estoque_qtd, imagem_url, destaque)
SELECT c.id_categoria, p.nome, p.descricao, 'UN', p.preco, 24,
       CONCAT('/assets/images/produto-limpeza-', p.foto, '.jpg'), 0
FROM categorias c
CROSS JOIN (
    SELECT 'Sabão em Pó OMO Lavagem Perfeita (Caixa 1,6kg)' AS nome, 'Sabão em pó para lavanderia. Caixa de 1,6 kg.' AS descricao, 22.90 AS preco, 'omo-16kg' AS foto UNION ALL
    SELECT 'Sabão Líquido Ariel Concentrado (Galão 3L)', 'Sabão líquido concentrado para roupas. Galão de 3 L.', 38.90, 'ariel-3l' UNION ALL
    SELECT 'Amaciante Concentrado Downy Brisa de Verão (Frasco 1L)', 'Amaciante concentrado Brisa de Verão. Frasco de 1 L.', 23.90, 'downy-verao-1l' UNION ALL
    SELECT 'Amaciante Comfort Puro Cuidado (Frasco 1,8L)', 'Amaciante Puro Cuidado. Frasco de 1,8 L.', 33.90, 'comfort-18l' UNION ALL
    SELECT 'Tira-Manchas em Pó Vanish Oxi Action (Pote 450g)', 'Tira-manchas em pó para roupas. Pote de 450 g.', 24.90, 'vanish-450g' UNION ALL
    SELECT 'Sabão em Barra Ypê Neutro (Pacote com 5 unidades)', 'Sabão em barra neutro. Pacote com 5 unidades.', 12.90, 'ype-barra-5un' UNION ALL
    SELECT 'Detergente Líquido Ypê Neutro (Frasco 500ml)', 'Detergente líquido neutro para louças. Frasco de 500 ml.', 2.79, 'ype-detergente-500ml' UNION ALL
    SELECT 'Detergente Líquido Limpol Cristal (Frasco 500ml)', 'Detergente líquido Cristal para louças. Frasco de 500 ml.', 2.99, 'limpol-cristal-500ml' UNION ALL
    SELECT 'Esponja Multiuso Scotch-Brite (Pacote com 4 unidades)', 'Esponjas multiuso. Pacote com 4 unidades.', 8.99, 'scotch-brite-4un' UNION ALL
    SELECT 'Desengordurante Veja Cozinha Limão (Frasco 500ml)', 'Desengordurante de cozinha com fragrância de limão. Frasco de 500 ml.', 12.90, 'veja-cozinha-limao-500ml' UNION ALL
    SELECT 'Papel Toalha Snob Folha Dupla (Pacote com 2 rolos)', 'Papel toalha de folha dupla. Pacote com 2 rolos.', 6.99, 'snob-2rolos' UNION ALL
    SELECT 'Água Sanitária Qboa (Galão 2L)', 'Água sanitária Qboa. Galão de 2 L.', 7.99, 'qboa-2l' UNION ALL
    SELECT 'Desinfetante Pinho Sol Original (Frasco 1L)', 'Desinfetante Pinho Sol Original. Frasco de 1 L.', 12.90, 'pinho-sol-1l' UNION ALL
    SELECT 'Desinfetante Veja Perfume e Limpeza Lavanda (Frasco 2L)', 'Veja Perfume e Limpeza, fragrância lavanda. Frasco de 2 L.', 15.90, 'veja-lavanda-2l' UNION ALL
    SELECT 'Limpador Multiuso Veja Original (Frasco 500ml)', 'Limpador multiuso Veja Original. Frasco de 500 ml.', 5.49, 'veja-multiuso-500ml' UNION ALL
    SELECT 'Limpa Vidros Veja Vidrex (Frasco 500ml)', 'Limpador Veja Vidrex para vidros. Frasco de 500 ml.', 12.49, 'vidrex-500ml' UNION ALL
    SELECT 'Lustra-Móveis Poliflor Lavanda (Frasco 200ml)', 'Lustra-móveis com fragrância lavanda. Frasco de 200 ml.', 8.49, 'poliflor-lavanda-200ml' UNION ALL
    SELECT 'Inseticida Aerossol SBP Multi-Inseticida (Frasco 380ml)', 'SBP Multi-Inseticida em aerossol. Frasco de 380 ml.', 17.90, 'sbp-380ml' UNION ALL
    SELECT 'Saco para Lixo Dover Roll 50 Litros (Rolo com 30 unidades)', 'Sacos para lixo de 50 L. Rolo com 30 unidades.', 19.90, 'dover-roll-50l-30un' UNION ALL
    SELECT 'Pano Multiuso Perfex (Pacote com 5 panos)', 'Panos multiuso Perfex. Pacote com 5 panos.', 8.90, 'perfex-5un'
) p
WHERE c.slug = 'limpeza'
  AND NOT EXISTS (
      SELECT 1 FROM produtos existente
      WHERE existente.id_categoria = c.id_categoria AND existente.nome = p.nome
  );


-- Amplia a linha de Limpeza com embalagens verificadas.
-- Álcool líquido 70% é exibido no catálogo com estoque zero.
INSERT INTO produtos (id_categoria, nome, descricao, tipo_medida, preco_unitario, estoque_qtd, imagem_url, destaque)
SELECT c.id_categoria, p.nome, p.descricao, 'UN', p.preco, p.estoque,
       CONCAT('/assets/images/produto-limpeza-', p.foto, '.jpg'), 0
FROM categorias c
CROSS JOIN (
    SELECT 'Álcool Líquido 70% Zulu (Frasco 1L)' AS nome, 'Álcool líquido Zulu 70%. Frasco de 1 L.' AS descricao, 0.00 AS preco, 0 AS estoque, 'zulu-alcool-70-1l' AS foto UNION ALL
    SELECT 'Álcool em Gel 70% Giovanna Baby (Frasco 500ml)', 'Álcool em gel 70%. Frasco de 500 ml.', 19.90, 24, 'giovanna-baby-gel-500ml' UNION ALL
    SELECT 'Desinfetante Lysoform Bruto Original (Frasco 1L)', 'Desinfetante Lysoform Bruto Original. Frasco de 1 L.', 15.90, 24, 'lysoform-original-1l' UNION ALL
    SELECT 'Limpador Perfumado Casa & Perfume Sensualidade (Frasco 1L)', 'Limpador perfumado Sensualidade. Frasco de 1 L.', 8.90, 24, 'casa-perfume-sensualidade-1l' UNION ALL
    SELECT 'Saponáceo Cremoso Cif Original (Frasco 450ml)', 'Saponáceo cremoso Cif Original. Frasco de 450 ml.', 11.90, 24, 'cif-original-450ml' UNION ALL
    SELECT 'Detergente em Pó Tixan Ypê Primavera (Caixa 1,6kg)', 'Lava-roupas em pó Tixan Ypê Primavera. Caixa de 1,6 kg.', 19.90, 24, 'tixan-primavera-16kg' UNION ALL
    SELECT 'Lava-Roupas Líquido Brilhante Limpeza Total (Galão 3L)', 'Lava-roupas líquido Limpeza Total. Galão de 3 L.', 29.90, 24, 'brilhante-limpeza-total-3l' UNION ALL
    SELECT 'Alvejante sem Cloro Vanish Poder O2 (Frasco 1,5L)', 'Alvejante líquido Vanish sem cloro. Frasco de 1,5 L.', 21.90, 24, 'vanish-poder-o2-15l' UNION ALL
    SELECT 'Limpa Forno e Fogão Diabo Verde (Frasco 300ml)', 'Limpador Diabo Verde para forno e fogão. Frasco de 300 ml.', 12.90, 24, 'diabo-verde-limpa-forno-300ml' UNION ALL
    SELECT 'Desentupidor Líquido Diabo Verde (Frasco 1L)', 'Desentupidor líquido Diabo Verde. Frasco de 1 L.', 22.90, 24, 'diabo-verde-desentupidor-1l' UNION ALL
    SELECT 'Esponja de Aço Bombril (Pacote com 8 unidades)', 'Esponjas de aço Bombril. Pacote com 8 unidades.', 3.49, 24, 'bombril-8un' UNION ALL
    SELECT 'Vassoura Noviça Original Bettanin', 'Vassoura Noviça Original da Bettanin.', 19.90, 24, 'novica-vassoura-original' UNION ALL
    SELECT 'Luva de Látex Mucambo Multiuso (Par)', 'Um par de luvas multiuso de látex Mucambo.', 9.99, 24, 'mucambo-luva-multiuso'
) p
WHERE c.slug = 'limpeza'
  AND NOT EXISTS (
      SELECT 1 FROM produtos existente
      WHERE existente.id_categoria = c.id_categoria AND existente.nome = p.nome
  );


-- Cadastra a categoria Farmácia com imagens das embalagens.
-- Medicamentos ficam em exibição no catálogo, sem preço ou estoque de venda.
INSERT INTO produtos (id_categoria, nome, descricao, tipo_medida, preco_unitario, estoque_qtd, imagem_url, destaque)
SELECT c.id_categoria, p.nome, p.descricao, 'UN', p.preco, p.estoque,
       CONCAT('/assets/images/produto-farmacia-', p.foto, '.jpg'), 0
FROM categorias c
CROSS JOIN (
    SELECT 'Dorflex 36 comprimidos' AS nome, 'Caixa com 36 comprimidos.' AS descricao, 0.00 AS preco, 0 AS estoque, 'dorflex-36' AS foto UNION ALL
    SELECT 'Dorflex UNO 1g 10 comprimidos', 'Caixa com 10 comprimidos de 1 g.', 0.00, 0, 'dorflex-uno-10' UNION ALL
    SELECT 'Tylenol 750mg 20 comprimidos', 'Caixa com 20 comprimidos de 750 mg.', 0.00, 0, 'tylenol-750-20' UNION ALL
    SELECT 'Advil 400mg 8 cápsulas líquidas', 'Caixa com 8 cápsulas líquidas de 400 mg.', 0.00, 0, 'advil-400-8' UNION ALL
    SELECT 'Benegrip Multi Dia (Caixa com 20 comprimidos)', 'Caixa com 20 comprimidos.', 0.00, 0, 'benegrip-multi-20' UNION ALL
    SELECT 'Vick VapoRub pote 30g', 'Pote de 30 g.', 0.00, 0, 'vick-30g' UNION ALL
    SELECT 'Eno Sal de Fruta Tradicional 2 envelopes 5g', 'Embalagem com 2 envelopes.', 0.00, 0, 'eno-tradicional-2' UNION ALL
    SELECT 'Estomazil Abacaxi envelope 5g', 'Envelope de 5 g.', 0.00, 0, 'estomazil-abacaxi-5g' UNION ALL
    SELECT 'Listerine Cool Mint 500ml', 'Enxaguante bucal Cool Mint. Frasco de 500 ml.', 21.90, 24, 'listerine-500ml' UNION ALL
    SELECT 'Strepsils Mel e Limão 16 pastilhas', 'Caixa com 16 pastilhas sabor mel e limão.', 0.00, 0, 'strepsils-16' UNION ALL
    SELECT 'Band-Aid Transparente 40 unidades', 'Caixa com 40 curativos adesivos transparentes.', 14.90, 24, 'bandaid-40' UNION ALL
    SELECT 'Merthiolate Incolor spray 30ml', 'Antisséptico incolor. Frasco spray de 30 ml.', 0.00, 0, 'merthiolate-30ml' UNION ALL
    SELECT 'Algodão Hidrófilo Cremer 50g', 'Pacote de algodão hidrófilo de 50 g.', 6.49, 24, 'algodao-cremer-50g' UNION ALL
    SELECT 'Gaze Estéril Cremer 10 unidades', 'Pacote com 10 compressas estéreis.', 5.49, 24, 'gaze-cremer-10' UNION ALL
    SELECT 'Fita Flexível Impermeável Nexcare (Rolo 2,5 cm × 4,5 m)', 'Rolo de 2,5 cm × 4,5 m.', 13.90, 24, 'nexcare-25-45' UNION ALL
    SELECT 'Redoxon Vitamina C laranja 10 comprimidos efervescentes', 'Embalagem com 10 comprimidos efervescentes sabor laranja.', 0.00, 0, 'redoxon-10' UNION ALL
    SELECT 'Centrum Essencial 30 comprimidos', 'Suplemento alimentar. Embalagem com 30 comprimidos.', 35.90, 24, 'centrum-30' UNION ALL
    SELECT 'Neutrogena Sun Fresh Facial FPS 70 40g', 'Protetor solar facial FPS 70. Embalagem de 40 g.', 43.90, 24, 'neutrogena-fps70-40g' UNION ALL
    SELECT 'Nivea Milk Pele Seca 200ml', 'Hidratante corporal para pele seca a extrasseca. Frasco de 200 ml.', 17.90, 24, 'nivea-milk-200ml' UNION ALL
    SELECT 'OFF! Family Spray 200ml', 'Repelente em spray. Frasco de 200 ml.', 22.90, 24, 'off-family-200ml'
) p
WHERE c.slug = 'farmacia'
  AND NOT EXISTS (
      SELECT 1 FROM produtos existente
      WHERE existente.id_categoria = c.id_categoria AND existente.nome = p.nome
  );


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


-- Adiciona produtos de Pets com fotos das apresentações verificadas.
INSERT INTO produtos (id_categoria, nome, descricao, tipo_medida, preco_unitario, estoque_qtd, imagem_url, destaque)
SELECT c.id_categoria, p.nome, p.descricao, 'UN', p.preco, 24,
       CONCAT('/assets/images/produto-pets-', p.foto, '.jpg'), 0
FROM categorias c
CROSS JOIN (
    SELECT 'Ração Seca Pedigree Adulto Carne, Frango e Cereais (10,1 kg)' AS nome, 'Ração seca para cães adultos. Pacote de 10,1 kg.' AS descricao, 119.90 AS preco, 'pedigree-adulto-101kg' AS foto UNION ALL
    SELECT 'Ração Seca GoldeN Formula Adulto Frango e Arroz (15 kg)', 'Ração seca para cães adultos, sabor frango e arroz. Pacote de 15 kg.', 169.90, 'golden-adulto-15kg' UNION ALL
    SELECT 'Ração Úmida Pedigree Carne ao Molho (Sachê 100 g)', 'Alimento úmido para cães adultos. Sachê de 100 g.', 3.99, 'pedigree-sache-carne-100g' UNION ALL
    SELECT 'Petisco Bifinho Keldog Carne e Cereais (55 g)', 'Bifinhos sabor carne e cereais para cães de porte pequeno. Pacote de 55 g.', 5.90, 'keldog-bifinho-55g' UNION ALL
    SELECT 'Tapete Higiênico Super Secão (30 unidades)', 'Pacote com 30 tapetes higiênicos.', 64.90, 'super-secao-30' UNION ALL
    SELECT 'Shampoo Neutro Sanol Dog (500 ml)', 'Shampoo neutro Sanol Dog. Frasco de 500 ml.', 16.90, 'sanol-dog-neutro-500ml' UNION ALL
    SELECT 'Ração Seca Whiskas Adulto Carne (10,1 kg)', 'Ração seca sabor carne para gatos adultos. Pacote de 10,1 kg.', 119.90, 'whiskas-carne-101kg' UNION ALL
    SELECT 'Ração Seca GoldeN Gatos Castrados Salmão (3 kg)', 'Ração seca sabor salmão para gatos adultos castrados. Pacote de 3 kg.', 57.90, 'golden-gatos-castrados-3kg' UNION ALL
    SELECT 'Ração Úmida Whiskas Atum ao Molho (Sachê 85 g)', 'Alimento úmido sabor atum para gatos adultos. Sachê de 85 g.', 3.69, 'whiskas-sache-atum-85g' UNION ALL
    SELECT 'Petisco Cremoso Churu Atum (4 tubos de 14 g)', 'Petisco cremoso sabor atum. Pacote com quatro tubos de 14 g.', 22.90, 'churu-atum-4' UNION ALL
    SELECT 'Areia Sanitária Pipicat Classic (4 kg)', 'Areia sanitária para gatos. Pacote de 4 kg.', 15.90, 'pipicat-classic-4kg' UNION ALL
    SELECT 'Areia Sanitária Sílica Chalesco (1,8 kg)', 'Cristais de sílica para a caixa sanitária. Pacote de 1,8 kg.', 32.90, 'chalesco-silica-18kg' UNION ALL
    SELECT 'Mistura de Sementes Megazoo Mix Canários (350 g)', 'Mix de sementes com grãos extrusados para canários. Pacote de 350 g.', 18.90, 'megazoo-mix-canarios-350g' UNION ALL
    SELECT 'Alpiste Selecionado Zootekna (500 g)', 'Alpiste selecionado para pássaros. Pacote de 500 g.', 10.90, 'zootekna-alpiste-500g' UNION ALL
    SELECT 'Painço Comum Zootekna (500 g)', 'Painço para pássaros. Pacote de 500 g.', 9.90, 'zootekna-painco-500g' UNION ALL
    SELECT 'Bebedouro Plástico Caçula Jel Plast (60 ml)', 'Bebedouro plástico modelo Caçula para gaiolas. Capacidade de 60 ml.', 6.90, 'jel-plast-bebedouro' UNION ALL
    SELECT 'Ração Extrusada Nutrópica para Hamster e Roedores (300 g)', 'Alimento extrusado Nutrópica para hamsters. Pacote de 300 g.', 19.90, 'nutropica-hamster-300g' UNION ALL
    SELECT 'Mistura de Sementes para Hamster Reino das Aves (500 g)', 'Mix para hamsters da linha Reino das Aves. Pacote de 500 g.', 12.90, 'reino-aves-hamster-500g' UNION ALL
    SELECT 'Roda de Exercícios com Rolamento para Hamster Jel Plast (Unidade)', 'Rodinha de exercícios com rolamento, de 11 cm de diâmetro. Uma unidade.', 21.90, 'jel-plast-roda-hamster' UNION ALL
    SELECT 'Ração Extrusada Nutrópica para Coelho Adulto (1,2 kg)', 'Ração extrusada natural para coelhos adultos. Pacote de 1,2 kg.', 43.90, 'nutropica-coelho-12kg'
) p
WHERE c.slug = 'pets'
  AND NOT EXISTS (
      SELECT 1 FROM produtos existente
      WHERE existente.id_categoria = c.id_categoria AND existente.nome = p.nome
  );


-- Adiciona os pescados e conservas com apresentações verificadas.
INSERT INTO produtos (id_categoria, nome, descricao, tipo_medida, preco_unitario, estoque_qtd, imagem_url, destaque)
SELECT c.id_categoria, p.nome, p.descricao, 'UN', p.preco, 24,
       CONCAT('/assets/images/produto-peixaria-', p.foto, '.jpg'), 0
FROM categorias c
CROSS JOIN (
    SELECT 'Filé de Tilápia Congelado Copacol (Pacote 800 g)' AS nome, 'Filés de tilápia congelados. Pacote de 800 g.' AS descricao, 34.90 AS preco, 'copacol-tilapia-800g' AS foto UNION ALL
    SELECT 'Medalhão de Salmão Frescatto (500 g)', 'Medalhões de salmão congelados. Embalagem de 500 g.', 46.90, 'frescatto-medalhao-salmao-500g' UNION ALL
    SELECT 'Pedaços de Filé de Salmão Swift (500 g)', 'Pedaços congelados de filé de salmão. Pacote de 500 g.', 49.90, 'swift-file-salmao-500g' UNION ALL
    SELECT 'Filé de Merluza Congelado Costa Sul (Pacote 800 g)', 'Filés de merluza congelados. Pacote de 800 g.', 29.90, 'costa-sul-merluza-800g' UNION ALL
    SELECT 'Filé de Panga Congelado Frescatto (Pacote 500 g)', 'Filés de panga congelados. Pacote de 500 g.', 25.90, 'frescatto-pangasius-500g' UNION ALL
    SELECT 'Lombo de Bacalhau Dessalgado Riberalves (Pacote 800 g)', 'Lombos de bacalhau dessalgados e congelados. Embalagem de 800 g.', 99.90, 'riberalves-bacalhau-800g' UNION ALL
    SELECT 'Posta de Cação Congelada Costa Sul (Pacote 800 g)', 'Postas de cação congeladas. Pacote de 800 g.', 32.90, 'costa-sul-cacao-800g' UNION ALL
    SELECT 'Camarão Cinza Descascado e Limpo Frescatto (Pacote 400 g)', 'Camarão cinza descascado e limpo. Embalagem de 400 g.', 35.90, 'frescatto-camarao-cinza-400g' UNION ALL
    SELECT 'Anéis de Lula Congelados Costa Sul (Pacote 400 g)', 'Lula em anéis congelada. Pacote de 400 g.', 28.90, 'costa-sul-lula-400g' UNION ALL
    SELECT 'Mix de Frutos do Mar para Paella Costa Sul (Pacote 400 g)', 'Mix congelado de frutos do mar para paella. Pacote de 400 g.', 25.90, 'costa-sul-paella-400g' UNION ALL
    SELECT 'Atum Sólido ao Natural Gomes da Costa (Lata 170 g)', 'Atum sólido ao natural. Lata de 170 g.', 11.49, 'gomes-costa-atum-natural-170g' UNION ALL
    SELECT 'Atum Ralado em Óleo Coqueiro (Lata 170 g)', 'Atum ralado em óleo. Lata de 170 g.', 8.49, 'coqueiro-atum-ralado-170g' UNION ALL
    SELECT 'Sardinha com Óleo Gomes da Costa (Lata 125 g)', 'Sardinhas com óleo. Lata de 125 g.', 6.49, 'gomes-costa-sardinha-oleo-125g' UNION ALL
    SELECT 'Sardinha ao Molho de Tomate Coqueiro (Lata 125 g)', 'Sardinhas em molho de tomate. Lata de 125 g.', 6.49, 'coqueiro-sardinha-tomate-125g' UNION ALL
    SELECT 'Tirinhas de Peixe Empanadas Seara (Pacote 300 g)', 'Tirinhas de peixe empanadas e congeladas. Pacote de 300 g.', 18.90, 'seara-empanado-peixe-300g'
) p
WHERE c.slug = 'peixaria'
  AND NOT EXISTS (
      SELECT 1 FROM produtos existente
      WHERE existente.id_categoria = c.id_categoria AND existente.nome = p.nome
  );

