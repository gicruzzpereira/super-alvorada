<?php
$favoriteCatalog = [];
try {
    foreach (db()->query('SELECT p.id_produto, p.nome, c.slug FROM produtos p JOIN categorias c USING(id_categoria) WHERE p.ativo=1') as $item) {
        $favoriteCatalog[(int)$item['id_produto']] = ['name'=>$item['nome'], 'category'=>$item['slug']];
    }
    foreach (db()->query('SELECT id_item_encarte, nome FROM itens_encarte_site WHERE ativo=1') as $item) {
        $favoriteCatalog[-(900 + (int)$item['id_item_encarte'])] = ['name'=>$item['nome'], 'category'=>'ofertas'];
    }
} catch (PDOException $e) {
    // Keep any products already loaded.
}
?>
<dialog class="favorites-dialog" id="favorites-dialog" aria-labelledby="favorites-title"><div class="favorites-dialog-head"><h2 id="favorites-title">Produtos curtidos</h2><button type="button" class="location-close" data-favorites-close aria-label="Fechar">×</button></div><p class="favorites-empty" data-favorites-empty>Você ainda não curtiu nenhum produto.</p><div class="favorites-list" data-favorites-list></div></dialog>
<script type="application/json" id="favorites-catalog" data-csrf="<?=h(csrf())?>"><?=json_encode((object)$favoriteCatalog, JSON_HEX_TAG|JSON_HEX_AMP|JSON_HEX_APOS|JSON_HEX_QUOT|JSON_INVALID_UTF8_SUBSTITUTE)?></script>
<script src="/assets/js/favorites.js?v=1" defer></script>
