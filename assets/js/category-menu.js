document.addEventListener('DOMContentLoaded', () => {
  const button = document.querySelector('[data-category-menu-toggle]');
  const menu = document.querySelector('#category-mega-menu');
  if (!button || !menu) return;

  const closeMenu = () => {
    button.setAttribute('aria-expanded', 'false');
    menu.hidden = true;
  };

  button.addEventListener('click', () => {
    const open = button.getAttribute('aria-expanded') !== 'true';
    button.setAttribute('aria-expanded', String(open));
    menu.hidden = !open;
  });

  document.addEventListener('click', event => {
    if (!event.target.closest('.category-bar')) closeMenu();
  });
  document.addEventListener('keydown', event => {
    if (event.key === 'Escape') closeMenu();
  });
});
