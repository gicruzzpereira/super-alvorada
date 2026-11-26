(() => {
  const start = () => {
    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;
    if (!('IntersectionObserver' in window)) return;

    const targets = document.querySelectorAll([
      '.home-section .section-head',
      '.category-card',
      '.promo-card',
      '.product',
      '.daily-deal-content',
      '.category-page-hero',
      '.coupon-hero',
      '.coupon-card',
      '.coupon-owned-item',
      '.cart-summary',
      '.cart-benefits',
      '.cart-newsletter',
      '.site-footer'
    ].join(','));

    if (!targets.length) return;

    const observer = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return;
        entry.target.classList.add('is-visible');
        observer.unobserve(entry.target);
      });
    }, { threshold: 0.08, rootMargin: '0px 0px -24px 0px' });

    targets.forEach((element) => {
      const siblings = element.parentElement ? [...element.parentElement.children] : [];
      const position = siblings.indexOf(element);
      element.style.setProperty('--motion-delay', `${Math.min(Math.max(position, 0), 3) * 45}ms`);
      element.classList.add('motion-reveal');
      observer.observe(element);
    });
  };

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', start, { once: true });
  } else {
    start();
  }
})();
