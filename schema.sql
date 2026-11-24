CREATE DATABASE IF NOT EXISTS supermercado_alvorada CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE supermercado_alvorada;
SET FOREIGN_KEY_CHECKS=0;
SET FOREIGN_KEY_CHECKS=1;
CREATE TABLE usuarios(id_usuario INT AUTO_INCREMENT PRIMARY KEY,nome VARCHAR(100) NOT NULL,email VARCHAR(100) NOT NULL UNIQUE,senha VARCHAR(255) NOT NULL,perfil ENUM('visitante','cliente','admin','separador','entregador') NOT NULL DEFAULT 'cliente',telefone VARCHAR(20),foto_perfil VARCHAR(255) NULL,data_nascimento DATE NULL,data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP) ENGINE=InnoDB;
CREATE TABLE enderecos(id_endereco INT AUTO_INCREMENT PRIMARY KEY,id_usuario INT NOT NULL,logradouro VARCHAR(150) NOT NULL,numero VARCHAR(20) NOT NULL,bairro VARCHAR(80) NOT NULL,cidade VARCHAR(80) NOT NULL,cep VARCHAR(10) NOT NULL,atendido TINYINT(1) DEFAULT 1,FOREIGN KEY(id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE) ENGINE=InnoDB;
CREATE TABLE categorias(id_categoria INT AUTO_INCREMENT PRIMARY KEY,nome VARCHAR(50) NOT NULL,slug VARCHAR(50) NOT NULL UNIQUE,imagem_url VARCHAR(255) NULL) ENGINE=InnoDB;
CREATE TABLE produtos(id_produto INT AUTO_INCREMENT PRIMARY KEY,id_categoria INT NOT NULL,nome VARCHAR(100) NOT NULL,tipo_medida ENUM('UN','KG') NOT NULL DEFAULT 'UN',preco_unitario DECIMAL(10,2) NOT NULL,estoque_qtd DECIMAL(10,3) NOT NULL,imagem_url VARCHAR(255),destaque TINYINT(1) DEFAULT 0,ativo TINYINT(1) DEFAULT 1,FOREIGN KEY(id_categoria) REFERENCES categorias(id_categoria)) ENGINE=InnoDB;
CREATE TABLE cupons(id_cupom INT AUTO_INCREMENT PRIMARY KEY,codigo VARCHAR(40) NOT NULL UNIQUE,titulo VARCHAR(100) NOT NULL,descricao VARCHAR(255) NULL,tipo ENUM('percentual','fixo') NOT NULL,valor DECIMAL(10,2) NOT NULL,pedido_minimo DECIMAL(10,2) NOT NULL DEFAULT 0,validade DATE NULL,limite_usos INT NULL,usos INT NOT NULL DEFAULT 0,ativo TINYINT(1) NOT NULL DEFAULT 1,data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP) ENGINE=InnoDB;
CREATE TABLE pedidos(id_pedido INT AUTO_INCREMENT PRIMARY KEY,id_cliente INT NOT NULL,id_separador INT NULL,id_entregador INT NULL,id_endereco INT NULL,id_cupom INT NULL,valor_desconto DECIMAL(10,2) NOT NULL DEFAULT 0,status ENUM('pendente','em_separacao','aguardando_aprovacao','pronto','em_transito','entregue','cancelado','problema') DEFAULT 'pendente',valor_subtotal DECIMAL(10,2) NOT NULL,valor_frete DECIMAL(10,2) NOT NULL DEFAULT 5.00,valor_total DECIMAL(10,2) NOT NULL,metodo_pagamento ENUM('pix','cartao_credito','dinheiro_entrega') NOT NULL,modalidade_entrega ENUM('expressa','agendada','retirada') NOT NULL DEFAULT 'agendada',cep_entrega VARCHAR(9) NULL,data_entrega DATE NULL,horario_entrega VARCHAR(40) NULL,pin_entrega VARCHAR(6) NOT NULL UNIQUE,observacao_separacao TEXT,observacao_problema TEXT,data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,FOREIGN KEY(id_cliente) REFERENCES usuarios(id_usuario),FOREIGN KEY(id_separador) REFERENCES usuarios(id_usuario),FOREIGN KEY(id_entregador) REFERENCES usuarios(id_usuario),FOREIGN KEY(id_endereco) REFERENCES enderecos(id_endereco),FOREIGN KEY(id_cupom) REFERENCES cupons(id_cupom)) ENGINE=InnoDB;
CREATE TABLE cupons_clientes(id_cupom_cliente INT AUTO_INCREMENT PRIMARY KEY,id_usuario INT NOT NULL,id_cupom INT NOT NULL,id_pedido INT NULL,resgatado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,usado_em TIMESTAMP NULL,UNIQUE KEY uk_cupom_cliente(id_usuario,id_cupom),FOREIGN KEY(id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE,FOREIGN KEY(id_cupom) REFERENCES cupons(id_cupom) ON DELETE CASCADE,FOREIGN KEY(id_pedido) REFERENCES pedidos(id_pedido) ON DELETE SET NULL) ENGINE=InnoDB;
CREATE TABLE itens_pedido(id_item INT AUTO_INCREMENT PRIMARY KEY,id_pedido INT NOT NULL,id_produto INT NOT NULL,qtd_solicitada DECIMAL(10,3) NOT NULL,qtd_separada DECIMAL(10,3) NULL,preco_aplicado DECIMAL(10,2) NOT NULL,substituido_id_produto INT NULL,status_item ENUM('solicitado','separado','substituido','em_falta') DEFAULT 'solicitado',FOREIGN KEY(id_pedido) REFERENCES pedidos(id_pedido) ON DELETE CASCADE,FOREIGN KEY(id_produto) REFERENCES produtos(id_produto),FOREIGN KEY(substituido_id_produto) REFERENCES produtos(id_produto)) ENGINE=InnoDB;
CREATE TABLE respostas_item(id_resposta INT AUTO_INCREMENT PRIMARY KEY,id_item INT NOT NULL UNIQUE,cliente_aprovou TINYINT(1) NULL,motivo VARCHAR(255),respondido_em TIMESTAMP NULL,FOREIGN KEY(id_item) REFERENCES itens_pedido(id_item) ON DELETE CASCADE) ENGINE=InnoDB;
CREATE TABLE configuracoes(chave VARCHAR(60) PRIMARY KEY,valor VARCHAR(255) NOT NULL) ENGINE=InnoDB;
CREATE TABLE auditoria(id_auditoria BIGINT AUTO_INCREMENT PRIMARY KEY,id_usuario INT NULL,id_pedido INT NULL,acao VARCHAR(100) NOT NULL,detalhes TEXT,criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,FOREIGN KEY(id_usuario) REFERENCES usuarios(id_usuario) ON DELETE SET NULL,FOREIGN KEY(id_pedido) REFERENCES pedidos(id_pedido) ON DELETE SET NULL) ENGINE=InnoDB;
INSERT INTO categorias(nome,slug) VALUES ('Hortifrúti','hortifruti'),('Padaria','padaria'),('Açougue','acougue'),('Bebidas','bebidas'),('Limpeza','limpeza'),('Farmácia','farmacia'),('Pets','pets'),('Peixaria','peixaria'),('Frios & Laticínios','frios-laticinios'),('Mercearia & Grãos','mercearia-graos'),('Higiene & Perfumaria','higiene-perfumaria'),('Jornal da Semana','jornal');
INSERT INTO produtos(id_categoria,nome,tipo_medida,preco_unitario,estoque_qtd,imagem_url,destaque) VALUES
(1,'Banana prata','KG',7.99,80,'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?auto=format&fit=crop&w=700&q=80',1),(1,'Tomate italiano','KG',8.49,60,NULL,1),(1,'Alface crespa','UN',3.50,40,NULL,0),(2,'Pão francês','KG',16.90,50,NULL,1),(2,'Pão de forma','UN',8.90,35,NULL,0),(3,'Peito de frango','KG',19.90,45,NULL,1),(3,'Carne moída','KG',32.90,40,NULL,0),(4,'Suco de laranja 1L','UN',9.50,30,NULL,1),(4,'Água mineral 1,5L','UN',3.25,100,NULL,0),(5,'Detergente neutro','UN',2.79,70,NULL,0),(5,'Sabão em pó 1kg','UN',12.90,32,NULL,1),(6,'Creme dental','UN',5.99,50,NULL,0),(7,'Ração para cães 1kg','UN',18.90,22,NULL,1);
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

