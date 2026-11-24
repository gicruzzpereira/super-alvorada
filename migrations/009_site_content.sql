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
('Preço baixo','Preço baixo no Supermercado Alvorada','/assets/images/banner-preco-baixo.jpg?v=1','mercearia-graos','#produtos',7,1)
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
