# Supermercado Alvorada

Aplicação didática de comércio eletrônico e operação de mercado, construída em PHP 8+, MySQL, HTML, CSS e JavaScript sem frameworks.

## Instalação com XAMPP ou WAMP

1. Copie a pasta do projeto para `htdocs/supermercado-alvorada` (XAMPP) ou `www/supermercado-alvorada` (WAMP).
2. Inicie Apache e MySQL no painel local.
3. Abra phpMyAdmin, importe `schema.sql` e confirme a criação de `supermercado_alvorada`.
4. Confira `config/conexao.php`. O padrão local é host `127.0.0.1`, usuário `root`, senha vazia. Ajuste para a sua instalação.
5. Acesse `http://localhost/supermercado-alvorada/`.

Se instalou em subpasta, configure o VirtualHost para apontar o document root para a raiz do projeto (os links usam caminhos absolutos a partir do document root). Para criar contas internas, cadastre um usuário cliente pelo formulário e altere seu `perfil` somente pelo banco, ou crie as contas de separação e entrega pelo painel de administração.

## Perfis de teste

Opcionalmente, execute `php seed_demo.php` no terminal do XAMPP/WAMP para criar contas locais de demonstração. O script só aceita execução CLI e salva as senhas usando `password_hash`.

| Perfil | E-mail | Senha |
|---|---|---|
| Visitante (conta de referência) | visitante@alvorada.local | Visitante123! |
| Cliente | cliente@alvorada.local | Cliente123! |
| Administrador | admin@alvorada.local | Admin123! |
| Separador | separador@alvorada.local | Separador123! |
| Entregador | entregador@alvorada.local | Entrega123! |

Visitante navega sem login; a conta de referência só existe para validar o perfil ENUM. Troque ou remova essas credenciais antes de qualquer publicação.

## Fluxos para validação manual

- Catálogo: busca, abas de categorias, detalhes e adição por unidade ou peso.
- Cliente: criar conta, incluir endereço na área de CEP de demonstração, montar carrinho, concluir compra, acompanhar pedido, cancelar pedido pendente e consultar PIN.
- Separação: iniciar pedido, registrar quantidade pesada ou falta e liberar para entrega.
- Entrega: assumir pedido pronto, abrir rota, registrar ocorrência ou confirmar com PIN do cliente.
- Administração: criar e editar produtos, criar usuários operacionais, configurar frete e intervalo de CEP, consultar pedidos e auditoria.

## Observações de configuração

O intervalo de CEP inicial é demonstrativo (01000-000 a 04999-999), não representa cálculo geográfico real de raio. Configure os limites e o frete no painel. A imagem padrão usa Unsplash e requer conexão. Para uma publicação real, configure HTTPS, credenciais de banco fora do repositório, política de backup, logs e provedores de pagamento/entrega.

## Contas de teste Alvorada

A base `supermercado_alvorada` foi inicializada com `schema.sql`. As contas de teste padrão podem ser recriadas pelo terminal com `php seed_test_accounts.php`:

| Perfil | E-mail | Senha |
|---|---|---|
| Cliente | cliente@superalvorada.com | Cliente123! |
| Administrador | admin@superalvorada.com | Admin123! |

Os cadastros da loja e as contas adicionadas pelo painel administrativo são salvos automaticamente na tabela `usuarios`. O painel permite criar contas de cliente, administrador, separador, entregador e visitante.
## Atualização do conteúdo do site no banco

As categorias, produtos, usuários, endereços, pedidos, cupons, configurações de entrega e inscritos da newsletter são persistidos no MySQL. Os banners, cartões promocionais, encarte e ofertas do encarte também são carregados das tabelas do banco; os arquivos de imagem continuam em `assets/images` e seus caminhos ficam armazenados no banco.

Para uma instalação existente, aplique a migração de conteúdo pelo terminal:

```powershell
C:\xampp\php\php.exe migrations\run_009.php
```

A migração é compatível com instalações que já têm categorias cadastradas e preserva os registros atuais. A interface, folhas de estilo, código e arquivos binários das imagens permanecem no projeto; dados de perfil e pedidos continuam nas tabelas relacionais.
Carrinhos, favoritos e localização também são sincronizados com o banco: para clientes vinculados à conta e para visitantes por sessão (dados temporários expiram em 30 dias). O painel administrativo ganhou a página `admin/conteudo.php` para editar banners, cartões promocionais, ofertas do encarte e textos armazenados.