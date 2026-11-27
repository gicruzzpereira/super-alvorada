document.addEventListener('DOMContentLoaded', () => {
  const dialog = document.querySelector('#favorites-dialog');
  const catalogData = document.querySelector('#favorites-catalog');
  const buttons = document.querySelectorAll('[data-favorites-open]');
  if (!dialog || !catalogData || !buttons.length) return;

  const catalog = JSON.parse(catalogData.textContent);
  const list = dialog.querySelector('[data-favorites-list]');
  const empty = dialog.querySelector('[data-favorites-empty]');
  const storageKey = 'alvorada-favorites';
  const endpoint = '/api/cliente_estado.php';
  const cards = document.querySelectorAll('.product[data-id]');
  let pendingSave = Promise.resolve();

  function read() {
    try {
      const value = JSON.parse(localStorage.getItem(storageKey) || '[]');
      return Array.isArray(value) ? [...new Set(value.map(Number).filter(Number.isSafeInteger))] : [];
    } catch {
      return [];
    }
  }

  function save(ids) {
    localStorage.setItem(storageKey, JSON.stringify(ids));
    render();
    pendingSave = pendingSave.then(() => fetch(endpoint, {
      method: 'POST',
      credentials: 'same-origin',
      keepalive: true,
      headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': catalogData.dataset.csrf },
      body: JSON.stringify({ favorites: ids }),
    })).catch(() => {});
  }

  const heart = buttons[0].querySelector('svg');
  cards.forEach(card => {
    const id = Number(card.dataset.id);
    if (!catalog[id]) return;
    const toggle = document.createElement('button');
    toggle.type = 'button';
    toggle.className = 'favorite-toggle';
    toggle.dataset.favoriteToggle = String(id);
    toggle.append(heart.cloneNode(true));
    toggle.addEventListener('click', () => {
      const ids = read();
      save(ids.includes(id) ? ids.filter(value => value !== id) : [...ids, id]);
    });
    card.append(toggle);
  });

  function render() {
    const ids = read().filter(id => catalog[id]);
    buttons.forEach(button => {
      const badge = button.querySelector('[data-favorites-count]');
      badge.textContent = String(ids.length);
      badge.hidden = ids.length === 0;
    });
    cards.forEach(card => {
      const toggle = card.querySelector('[data-favorite-toggle]');
      if (!toggle) return;
      const liked = ids.includes(Number(card.dataset.id));
      toggle.classList.toggle('is-liked', liked);
      toggle.setAttribute('aria-pressed', String(liked));
      toggle.setAttribute('aria-label', (liked ? 'Remover dos curtidos: ' : 'Curtir: ') + card.dataset.name);
    });
    empty.hidden = ids.length > 0;
    list.replaceChildren();
    ids.forEach(id => {
      const item = catalog[id];
      const row = document.createElement('div');
      row.className = 'favorite-item';
      const name = document.createElement('span');
      name.className = 'favorite-item-name';
      name.textContent = item.name;
      const view = document.createElement('a');
      view.className = 'favorite-view';
      view.href = '/categoria.php?slug=' + encodeURIComponent(item.category) + '#produto-' + id;
      view.textContent = 'Ver produto';
      view.addEventListener('click', () => dialog.close());
      const remove = document.createElement('button');
      remove.type = 'button';
      remove.className = 'favorite-remove';
      remove.setAttribute('aria-label', 'Remover ' + item.name + ' dos curtidos');
      remove.textContent = 'Remover';
      remove.addEventListener('click', () => save(read().filter(value => value !== id)));
      row.append(name, view, remove);
      list.append(row);
    });
  }

  buttons.forEach(button => button.addEventListener('click', () => {
    render();
    dialog.showModal();
  }));
  dialog.querySelector('[data-favorites-close]').addEventListener('click', () => dialog.close());
  dialog.addEventListener('click', event => {
    if (event.target === dialog) dialog.close();
  });
  window.addEventListener('storage', event => {
    if (event.key === storageKey || event.key === null) render();
  });
  window.addEventListener('pageshow', render);
  window.addEventListener('alvorada-customer-state-loaded', render);
  render();

  if (!window.AlvoradaCustomerState) {
    const initialSave = pendingSave;
    fetch(endpoint, { credentials: 'same-origin' })
      .then(response => response.ok ? response.json() : null)
      .then(data => {
        if (pendingSave === initialSave && Array.isArray(data?.state?.favorites)) {
          localStorage.setItem(storageKey, JSON.stringify(data.state.favorites));
          render();
        }
      }).catch(() => {});
  }
});
