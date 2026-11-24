(() => {
  const cacheKey = 'alvorada-cep-location-v1';
  const normalize = (cep) => String(cep || '').replace(/\D/g, '');
  const getCache = (cep) => {
    try { return JSON.parse(localStorage.getItem(cacheKey) || '{}')[cep] || null; }
    catch { return null; }
  };
  const saveCache = (cep, data) => {
    try {
      const cache = JSON.parse(localStorage.getItem(cacheKey) || '{}');
      cache[cep] = data;
      localStorage.setItem(cacheKey, JSON.stringify(cache));
    } catch {}
  };
  async function json(url) {
    const response = await fetch(url, { headers: { Accept: 'application/json' } });
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    return response.json();
  }
  async function lookup(rawCep) {
    const cep = normalize(rawCep);
    if (!/^\d{8}$/.test(cep)) throw new Error('Digite um CEP válido com 8 números.');
    const cached = getCache(cep);
    if (cached && Date.now() - cached.savedAt < 30 * 24 * 60 * 60 * 1000) return cached;

    let address;
    try {
      const result = await json(`https://brasilapi.com.br/api/cep/v2/${cep}`);
      address = {
        street: result.street || '', district: result.neighborhood || '',
        city: result.city || '', state: result.state || '',
        latitude: Number(result.location?.coordinates?.latitude),
        longitude: Number(result.location?.coordinates?.longitude)
      };
    } catch {
      try {
        const result = await json(`https://viacep.com.br/ws/${cep}/json/`);
        if (result.erro) throw new Error('CEP não encontrado. Confira os números e tente novamente.');
        address = { street: result.logradouro || '', district: result.bairro || '', city: result.localidade || '', state: result.uf || '', latitude: NaN, longitude: NaN };
      } catch (error) {
        if (error.message?.startsWith('CEP não encontrado')) throw error;
        throw new Error('Não foi possível consultar este CEP. Verifique sua conexão e tente novamente.');
      }
    }
    if (!address.city || !address.state) throw new Error('CEP não encontrado. Confira os números e tente novamente.');

    if (!Number.isFinite(address.latitude) || !Number.isFinite(address.longitude)) {
      // BrasilAPI coordinates are optional; use the postal address as a geocoding fallback.
      const query = new URLSearchParams({ postalcode: cep, city: address.city, state: address.state, country: 'Brasil', countrycodes: 'br', format: 'jsonv2', addressdetails: '1', limit: '1' });
      try {
        const results = await json(`https://nominatim.openstreetmap.org/search?${query}`);
        const point = results[0];
        if (point && Number.isFinite(Number(point.lat)) && Number.isFinite(Number(point.lon))) {
          address.latitude = Number(point.lat);
          address.longitude = Number(point.lon);
        }
      } catch {}
    }
    if (!Number.isFinite(address.latitude) || !Number.isFinite(address.longitude)) {
      throw new Error('O CEP foi encontrado, mas não há coordenadas disponíveis para calcular a distância e o frete.');
    }
    const result = { cep, ...address, savedAt: Date.now() };
    saveCache(cep, result);
    return result;
  }

  document.addEventListener('submit', async (event) => {
    const form = event.target.closest('form[data-cep-address-form]');
    if (!form || form.dataset.cepValidated === '1') return;
    event.preventDefault();
    const cepField = form.querySelector('[name="cep"]');
    const status = form.querySelector('[data-cep-status]');
    const submit = form.querySelector('[type="submit"]');
    if (submit) submit.disabled = true;
    if (status) status.textContent = 'Localizando CEP…';
    try {
      const address = await lookup(cepField?.value);
      for (const [field, value] of [['logradouro', address.street], ['bairro', address.district], ['cidade', address.city]]) {
        const input = form.querySelector(`[name="${field}"]`);
        if (input && value && !input.value.trim()) input.value = value;
      }
      for (const [field, value] of [['latitude', address.latitude], ['longitude', address.longitude], ['uf', address.state]]) {
        let input = form.querySelector(`[name="${field}"]`);
        if (!input) { input = document.createElement('input'); input.type = 'hidden'; input.name = field; form.append(input); }
        input.value = String(value);
      }
      if (status) status.textContent = `CEP localizado: ${[address.street, address.district, address.city, address.state].filter(Boolean).join(' · ')}.`;
      form.dataset.cepValidated = '1';
      form.requestSubmit(event.submitter || undefined);
    } catch (error) {
      if (status) status.textContent = error.message || 'Não foi possível localizar esse CEP.';
      else alert(error.message || 'Não foi possível localizar esse CEP.');
    } finally { if (submit) submit.disabled = false; }
  });
  window.AlvoradaCep = { lookup, normalize };
})();
