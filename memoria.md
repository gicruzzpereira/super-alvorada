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
