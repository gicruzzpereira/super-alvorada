INSERT INTO banners_site(titulo,texto_alternativo,imagem_url,categoria_slug,link_url,ordem,ativo) VALUES
('Cupons diários','Banner de cupons diários do Supermercado Alvorada. Acesse a página de cupons e resgate descontos.','/assets/images/banner-cupons-diarios.jpg','todos','/cupons.php',8,1)
ON DUPLICATE KEY UPDATE titulo=VALUES(titulo),texto_alternativo=VALUES(texto_alternativo),categoria_slug=VALUES(categoria_slug),link_url=VALUES(link_url),ordem=VALUES(ordem),ativo=VALUES(ativo);
