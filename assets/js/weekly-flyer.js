(() => {
  const init = () => {
    const reader = document.querySelector('[data-weekly-flyer]');
    if (!reader) return;

    const slides = [...reader.querySelectorAll('[data-flyer-slide]')];
    const dots = [...reader.querySelectorAll('[data-flyer-dot]')];
    const counter = reader.querySelector('[data-flyer-counter]');
    const previous = reader.querySelectorAll('[data-flyer-prev]');
    const next = reader.querySelectorAll('[data-flyer-next]');
    const stage = reader.querySelector('[data-flyer-stage]');
    const zoomButton = reader.querySelector('[data-flyer-zoom]');
    const zoomMark = zoomButton?.querySelector('[data-flyer-zoom-mark]');
    if (!slides.length) return;

    let current = Math.max(0, slides.findIndex((slide) => slide.classList.contains('is-active')));
    let zoom = 1;
    let offsetX = 0;
    let offsetY = 0;
    let drag = null;

    const renderZoom = () => {
      const image = slides[current]?.querySelector('img');
      if (image) image.style.transform = `translate3d(${offsetX}px,${offsetY}px,0) scale(${zoom})`;
      stage?.classList.toggle('is-zoomed', zoom > 1);
      zoomButton?.setAttribute('aria-pressed', String(zoom > 1));
      zoomButton?.setAttribute('aria-label', zoom > 1 ? 'Reduzir zoom' : 'Ampliar página');
      if (zoomButton) zoomButton.title = zoom > 1 ? 'Reduzir zoom' : 'Ampliar página';
      zoomMark?.setAttribute('d', zoom > 1 ? 'M8 10.5h5' : 'M8 10.5h5m-2.5-2.5v5');
    };

    const resetZoom = () => {
      zoom = 1;
      offsetX = 0;
      offsetY = 0;
      drag = null;
      stage?.classList.remove('is-dragging');
      renderZoom();
    };

    const show = (index) => {
      const target = (index + slides.length) % slides.length;
      reader.dataset.direction = target >= current ? 'next' : 'previous';
      resetZoom();
      current = target;
      slides.forEach((slide, i) => {
        const active = i === current;
        slide.classList.toggle('is-active', active);
        slide.setAttribute('aria-hidden', String(!active));
        slide.inert = !active;
      });
      dots.forEach((dot, i) => {
        const active = i === current;
        dot.classList.toggle('is-active', active);
        if (active) dot.setAttribute('aria-current', 'page');
        else dot.removeAttribute('aria-current');
      });
      if (counter) counter.textContent = `Página ${current + 1} de ${slides.length}`;
      renderZoom();
    };

    zoomButton?.addEventListener('click', () => {
      zoom = zoom > 1 ? 1 : 1.5;
      offsetX = 0;
      offsetY = 0;
      renderZoom();
    });
    previous.forEach((button) => button.addEventListener('click', () => show(current - 1)));
    next.forEach((button) => button.addEventListener('click', () => show(current + 1)));
    dots.forEach((dot, index) => dot.addEventListener('click', () => show(index)));
    stage?.addEventListener('pointerdown', (event) => {
      if (zoom <= 1 || event.target.closest('button')) return;
      event.preventDefault();
      drag = { x: event.clientX, y: event.clientY, offsetX, offsetY };
      stage.classList.add('is-dragging');
      stage.setPointerCapture(event.pointerId);
    });
    stage?.addEventListener('pointermove', (event) => {
      if (!drag) return;
      const image = slides[current]?.querySelector('img');
      const maxX = Math.max(0, ((image?.offsetWidth || 0) * zoom - stage.clientWidth) / 2);
      const maxY = Math.max(0, ((image?.offsetHeight || 0) * zoom - stage.clientHeight) / 2);
      offsetX = Math.max(-maxX, Math.min(maxX, drag.offsetX + event.clientX - drag.x));
      offsetY = Math.max(-maxY, Math.min(maxY, drag.offsetY + event.clientY - drag.y));
      renderZoom();
    });
    const stopDrag = () => {
      if (!drag) return;
      drag = null;
      stage?.classList.remove('is-dragging');
    };
    stage?.addEventListener('pointerup', stopDrag);
    stage?.addEventListener('pointercancel', stopDrag);
    reader.addEventListener('keydown', (event) => {
      if (event.key === 'ArrowLeft') { event.preventDefault(); show(current - 1); }
      if (event.key === 'ArrowRight') { event.preventDefault(); show(current + 1); }
      if (event.key === '+' || event.key === '=') { event.preventDefault(); zoomButton?.click(); }
      if (event.key === '-' && zoom > 1) { event.preventDefault(); zoomButton?.click(); }
    });
    renderZoom();
  };

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init, { once: true });
  else init();
})();
