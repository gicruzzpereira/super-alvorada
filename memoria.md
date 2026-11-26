# Memória do projeto — Supermercado Alvorada

Este documento registra o contexto para retomar o trabalho em outra máquina. Ao continuar, leia este arquivo e confira os arquivos atuais antes de editar; este documento é um resumo do histórico, não substitui o código.

## Projeto

- Loja virtual e painéis operacionais em PHP 8+, MySQL, HTML, CSS e JavaScript sem framework.
- A raiz do projeto é esta pasta. O arquivo principal da loja é `index.php`; estilos compartilhados ficam em `assets/css/style.css`.
- Instruções de instalação, banco e contas locais de demonstração estão em `README.md`.
- O site usa `config/conexao.php` para sessão, conexão PDO, autenticação e funções comuns como `h()`.

## Identidade visual e preferências

- Marca Supermercado Alvorada: fundo creme/bege, marrom escuro e dourado, tipografia elegante nos títulos, cartões claros e cantos arredondados.
- Preservar os arquivos de logo e banner originais. Não esticar nem modificar as imagens da marca.
- O usuário prefere mudanças pontuais: não mexer em partes não mencionadas no pedido.
- As imagens são assets locais em `assets/images`; muitos conteúdos e caminhos de imagens são administrados pelo banco.

## Funcionalidades já trabalhadas

- Cabeçalho com busca, localização de entrega, categorias, perfil, favoritos e carrinho.
- Carrossel de banners na home, com troca automática e navegação; cartões promocionais e encarte do dia com botões de adicionar ao carrinho.
- Categorias de hortifrúti, padaria, açougue, bebidas, limpeza, farmácia, pets, peixaria, frios/laticínios, mercearia/grãos e higiene/perfumaria, com imagens de destaque.
- Cadastro e login; perfil do cliente; endereços; acompanhamento de pedidos; áreas de administração, separação e entrega.
- Carrinho, cupons, cálculo de entrega por CEP, seleção de entrega expressa/agendada ou retirada, calendário/horários administráveis e códigos de retirada/entrega.
- Checkout com opções de Pix (QR de demonstração) e cartão (interface de demonstração, sem API de pagamento ativa).
- Dados de conteúdo, contas, pedidos, cupons, configuração de entrega e estados persistentes do cliente/visitante usam MySQL conforme o schema e as migrações. A migração de conteúdo é `migrations/009_site_content.sql`, aplicada por `migrations/run_009.php`.
- Newsletter disponível no carrinho. O rodapé comum agora é `includes/site-footer.php` e tem links para loja, ofertas, conta, pedidos, endereços e atendimento.

## Decisões recentes / estado atual

- A seção “Jornal da Semana” foi removida da home por solicitação. O encarte continua na seção “Ofertas do Dia”.
- Os blocos de produtos por categoria (ex.: “Hortifrúti”, “Padaria”, “Açougue”) foram removidos da home por solicitação. O catálogo correspondente não é renderizado atualmente na home; confira o destino dos links de categoria antes de reintroduzir qualquer listagem.
- A sobreposição do encarte com o rodapé foi corrigida com regras específicas para `#ofertas` em `assets/css/style.css`, deixando o bloco reservar a própria altura e empurrar o rodapé para baixo.
- O rodapé apresentado na referência foi aplicado às páginas HTML/PHP da loja e aos painéis: home, login, cadastro, carrinho, checkout, perfil, pedidos, administração, separação e entrega. O componente está em `includes/site-footer.php`; estilos reutilizam `.cart-footer` em `assets/css/style.css`.
- Os links do rodapé apontam para âncoras da loja e áreas de conta. O link de atendimento abre WhatsApp no número configurado no componente; confirme esse contato se o telefone mudar.
- As páginas que carregam `style.css` tiveram seus parâmetros de cache atualizados para `v=44` na última edição.
- A última tarefa concluída foi justamente adicionar esse rodapé compartilhado. Não houve validação visual em navegador nesta etapa.

## Arquivos úteis

- Home e seções: `index.php`
- Estilos gerais, responsivos, cabeçalho, carrinho e rodapé: `assets/css/style.css`
- Rodapé compartilhado: `includes/site-footer.php`
- JavaScript da loja: `assets/js/main.js`; CEP: `assets/js/cep.js`
- Configuração e acesso ao banco: `config/conexao.php`, `config/entrega.php`
- Carrinho e checkout: `cliente/carrinho.php`, `cliente/checkout.php`
- Conta do cliente: `cliente/perfil.php`, `cliente/pedidos.php`
- Administração: `admin/painel.php`, `admin/conteudo.php`
- Schema e migrações: `schema.sql`, `migrations/`

## Como abrir localmente

1. Inicie Apache e MySQL no XAMPP/WAMP e confirme o banco `supermercado_alvorada` e as credenciais em `config/conexao.php`.
2. Com XAMPP, o README indica a raiz web `htdocs/supermercado-alvorada`. Para servidor PHP embutido, no terminal aberto na raiz do projeto execute `C:\xampp\php\php.exe -S 127.0.0.1:8000`.
3. Abra `http://127.0.0.1:8000/` (ou `http://localhost/supermercado-alvorada/` no Apache).
4. Se o CSS antigo aparecer, faça recarga forçada no navegador para buscar o `style.css?v=44` atual.

## Observação para a próxima sessão

O terminal usado na última sessão não tinha `php` no PATH e o localhost não respondeu. Para validar PHP e aparência, use o PHP/XAMPP da máquina em que o projeto estiver aberto e confira primeiro o estado atual do banco e dos arquivos.


## Atualização: envio da newsletter

- A inscrição continua sendo salva na tabela `newsletter_inscritos` e agora tenta enviar uma mensagem de boas-vindas com o link `/#ofertas` via SMTP. O fluxo das newsletters na home e no carrinho usa o mesmo handler.
- O envio fica em `config/email.php`. As configurações são lidas de variáveis de ambiente ou do arquivo local `.env.local`, que está ignorado pelo Git. Exemplo: `.env.example`.
- Nesta máquina não há SMTP nem `.env.local` configurado; o e-mail real ainda não pode ser enviado até conectar um provedor e configurar host, porta, TLS/SSL, usuário, senha de aplicativo, remetente e URL pública. O site informa isso sem afirmar falsamente que enviou.

- Provedor escolhido pelo usuário: Gmail. `.env.local` (ignorado pelo Git) contém as credenciais privadas preenchidas pelo usuário. A porta 587/TLS autenticava mas expirava ao aceitar destinatários; a porta 465/SSL passou no teste SMTP. A configuração local e os padrões do projeto foram trocados para porta 465/SSL. Em produção, substituir `ALVORADA_SITE_URL=http://localhost:8000` pelo domínio público.

## Atualização: páginas das categorias

- A página `categoria.php?slug=...` é o modelo de catálogo dedicado e lê categorias e produtos ativos do MySQL. Cada slug tem página própria via URL; `todos` lista o catálogo, `ofertas` e `jornal` exibem o encarte e `acougue-peixaria` reúne os dois departamentos.
- Os links da faixa animada do cabeçalho, dos cartões de categoria e dos menus “Todas as Categorias” levam às páginas correspondentes, inclusive na tela do carrinho. Ações de adicionar ao carrinho e curtir usam o JavaScript já compartilhado.
- O layout das páginas está no fim de `assets/css/style.css` sob `.category-page`; cache da folha de estilos passou para `v=47` e o JavaScript da loja para `v=24`.
- Ajuste após falha de navegação: o handler de clique em `assets/js/main.js` tinha uma condição de link com sintaxe inválida, impedindo o arquivo JavaScript de carregar. A condição foi corrigida e os links das páginas passaram a usar caminhos relativos para funcionar sob raiz ou subpasta. Conferido `http://127.0.0.1:8000/categoria.php?slug=hortifruti` com resposta HTTP 200.- O botão “Todas as Categorias” usa também `assets/js/category-menu.js`, separado do JavaScript principal, para abrir/fechar o menu independentemente das funções de produtos. A home e a página de categoria carregam esse script. Conferido home e script servidos com HTTP 200.
## Atualização: página de cupons

- Criada `cupons.php` com cupons ativos, valor do desconto, requisitos e validade. Clientes conectados podem resgatar; o cupom fica vinculado à conta em `cupons_clientes` para aplicação no checkout. Visitantes podem entrar ou criar conta e retornam à página de cupons.
- O atalho de cupons foi colocado ao lado do coração no cabeçalho da home, das páginas de categoria e do carrinho. A nova página segue as cores e a tipografia Alvorada e mostra também os cupons já resgatados pelo cliente.
- As regras visuais estão no fim de `assets/css/style.css`; a revisão do cache da folha é `v=49`.

## Atualização: banner de cupons na home

- O arquivo original `Gemini_Generated_Image_1rwlxv1rwlxv1rwl.jpg` foi copiado sem alteração para `assets/images/banner-cupons-diarios.jpg`.
- O novo banner entra no carrossel principal da home e toda a imagem aponta para `/cupons.php`. Há um fallback no `index.php` caso a linha ainda não exista no banco.
- A inclusão persistente foi adicionada ao `schema.sql` e à migração `migrations/010_coupon_home_banner.sql`, para também aparecer no gerenciamento de banners.

- Banner de cupons atualizado: `assets/images/banner-cupons-diarios.jpg` agora contém a nova imagem `Gemini_Generated_Image_kqrmkqkqrmkqkqrm.jpg`. O caminho permaneceu igual; o carrossel e o link `/cupons.php` continuam funcionando sem alteração.

## Atualização: movimento sutil no site

- `assets/js/motion.js` usa IntersectionObserver para revelar gradualmente cartões e seções conforme entram na tela, com pequeno escalonamento entre itens próximos.
- `assets/css/style.css` adiciona microinterações de hover/press e respeita `prefers-reduced-motion` para pessoas que preferem movimento reduzido.
- O script é carregado pelo rodapé compartilhado. A revisão CSS `v=50` foi aplicada à home, categorias, cupons, carrinho e páginas de conta/checkout.

## Atualização: fotos na página Ofertas do Dia

- Os cartões de `categoria.php?slug=ofertas` (e do encarte semanal) agora exibem recortes dos produtos correspondentes no arquivo `assets/images/encarte-ofertas-do-dia.webp`, usando os mesmos recortes já utilizados no carrinho.
- Os recortes são selecionados pelo slug do item; o produto fica centralizado em um quadro quadrado para não mostrar itens vizinhos do encarte. Itens sem recorte correspondente mantêm um marcador de oferta.
- A folha de estilo da página de categoria passou para `v=51`.

- Na página `categoria.php?slug=jornal`, os cartões individuais de produtos do encarte semanal foram removidos. A página mantém a imagem do encarte e o link para abrir as ofertas completas. `categoria.php?slug=ofertas` continua exibindo produtos com fotos e botão de adicionar.

## Atualização: jornal digital com três páginas

- A página `categoria.php?slug=jornal` deixou o banner único e passou a exibir um leitor de jornal digital com três páginas: Hortifrúti/Padaria/Açougue, Mercearia/Frios/Bebidas e Limpeza/Higiene.
- As imagens originais estão em `assets/images/jornal-semana-pagina-1-hortifruti.jpg`, `jornal-semana-pagina-2-mercearia.jpg` e `jornal-semana-pagina-3-limpeza.jpg`.
- Os controles anterior/próxima, os indicadores de página e as setas do teclado funcionam via `assets/js/weekly-flyer.js`; o visual está em `assets/css/style.css` com cache `v=53`.

- O enquadramento do jornal digital foi ampliado no desktop: páginas mais altas e margens internas menores, preservando a proporção e mostrando a imagem completa. No celular, o tamanho continua limitado à tela. CSS da página de categoria atualizado para `v=54`.

- A área de leitura do jornal foi ampliada mais uma vez no desktop (`122vh`, máximo 1440px), mantendo o limite responsivo próprio para celular. Cache de `categoria.php` atualizado para CSS `v=55`.

- O leitor do jornal digital agora tem uma lupa para alternar entre visualização normal e zoom de 150%. Com zoom ativo, a página pode ser arrastada pelo quadro para ler detalhes; trocar de página redefine o zoom.

- Adicionadas setas flutuantes nas laterais do leitor do jornal para avançar e voltar páginas. Elas compartilham o mesmo controle funcional dos botões superiores e respondem ao toque em telas menores. Cache CSS da página do jornal atualizado para `v=57`.

## Atualização: 15 novos produtos do Hortifrúti

- Foram incluídos 15 produtos vendáveis na categoria Hortifrúti, com unidade/quilo, preços, estoque inicial, registros no banco e imagens individuais.
- As fotos profissionais foram geradas para o catálogo, redimensionadas para 720×720 e comprimidas em JPEG leve; estão em `assets/images/produto-hortifruti-*.jpg`.
- A migração idempotente `migrations/011_hortifruti_products.sql` e o executor CLI `migrations/run_011.php` foram criados. A migração foi aplicada ao banco local ativo.
- Os botões de adicionar usam o identificador real de cada produto e seguem o fluxo existente do carrinho. A página usa imagem em `contain` apenas no Hortifrúti, para evitar cortes; o cache CSS passou para `v=58`.

## Correção das fotos do Hortifrúti

- Tomate italiano e alface crespa agora têm imagens de catálogo próprias, em vez da imagem geral da cesta.
- As novas fotos estão em `assets/images/produto-hortifruti-tomate-italiano.jpg` e `assets/images/produto-hortifruti-alface-crespa.jpg`.
- Migração `migrations/012_hortifruti_product_photos.sql` aplicada no banco local e incluída no `schema.sql` para instalações novas.

## Ajustes nos cartões de produto

- Na página de categorias, o atalho “Carrinho” agora inclui um ícone vetorial de carrinho e abre diretamente `cliente/carrinho.php`.
- Os 18 produtos de Hortifrúti receberam descrições curtas salvas na coluna `produtos.descricao`. Migração `migrations/013_hortifruti_descriptions.sql` e executor CLI `migrations/run_013.php` aplicados ao banco local.
- A coluna `descricao` também foi adicionada à definição de `produtos` em `schema.sql`; descrições aparecem nos cartões e respeitam o layout responsivo. CSS atualizado para `v=59`.

## Botão único de compra nos produtos

- Os cartões de produto da página de categorias agora têm apenas um botão, com ícone de carrinho e texto “Comprar”. Ao clicar, ele salva a quantidade no carrinho e abre diretamente a tela do carrinho.
- Atualizados os caches para CSS `v=60` e JavaScript `v=25`.

- O botão único de compra dos produtos agora mostra “Adicionar”; continua gravando o item no carrinho e abrindo a tela do carrinho após o clique. Cache CSS atualizado para `v=61`.

- Corrigido o fluxo do botão de adicionar: a gravação do carrinho no armazenamento compartilhado agora retorna uma promessa e é aguardada antes de abrir `cliente/carrinho.php`, evitando perder o item durante a navegação. JavaScript da página de categoria atualizado para `v=26`.

- Banana prata: substituída a foto antiga por uma foto individual em fundo marfim, no mesmo padrão das fotos do Hortifrúti. Arquivo `assets/images/produto-hortifruti-banana-prata.jpg`; migração `014_hortifruti_banana_photo.sql` aplicada ao banco e seed atualizado no `schema.sql`.
