/* ============================================================================
   GoEdu — админ-модуль для фронтенда.
   Подключается ОДНОЙ строкой в index.html ПОСЛЕ script.js:
     <script src="admin-panel.js"></script>
   Сам определяет, админ ли пользователь (через /admin/users), и если да —
   добавляет вкладку "Админ" в сайдбар. Бэкенд менять не нужно.
   ========================================================================== */
(function () {
  const ADMIN_API = 'http://localhost:8080';
  const tok = () => localStorage.getItem('goedu_token') || '';
  const AH = () => ({ 'Authorization': 'Bearer ' + tok(), 'Content-Type': 'application/json' });
  const esc = s => String(s == null ? '' : s)
    .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');

  // ---- стили (используют твои CSS-переменные из style.css) ----
  function injectStyles() {
    if (document.getElementById('adm-styles')) return;
    const css = `
      #view-admin .adm-card{background:var(--card);border:1px solid var(--border);
        border-radius:var(--radius);padding:20px;margin-bottom:18px}
      #view-admin h3.adm-h{font-family:var(--mono);font-size:16px;color:var(--accent);margin:0 0 14px}
      #view-admin label{display:block;font-size:12px;color:var(--text2);margin:10px 0 4px}
      #view-admin input,#view-admin textarea,#view-admin select{width:100%;background:var(--bg);
        border:1px solid var(--border);color:var(--text);border-radius:var(--radius-sm);
        padding:9px 11px;font-size:14px;font-family:var(--sans)}
      #view-admin textarea{min-height:64px;resize:vertical}
      #view-admin .adm-row{display:flex;gap:12px;flex-wrap:wrap}
      #view-admin .adm-row>div{flex:1;min-width:120px}
      #view-admin .adm-btn{background:var(--accent);color:#06231c;border:0;border-radius:var(--radius-sm);
        padding:10px 18px;font-size:14px;font-weight:700;cursor:pointer;margin-top:14px}
      #view-admin .adm-btn:hover{filter:brightness(1.08)}
      #view-admin .adm-item{display:flex;justify-content:space-between;align-items:center;
        padding:10px 12px;border:1px solid var(--border);border-radius:var(--radius-sm);margin-bottom:8px}
      #view-admin .adm-del{background:var(--danger);color:#fff;border:0;border-radius:6px;
        padding:6px 12px;font-size:13px;cursor:pointer}
      #view-admin .adm-badge{display:inline-block;background:var(--bg3);color:var(--accent);
        border-radius:6px;padding:2px 8px;font-size:11px;margin-left:6px}
      #view-admin .adm-muted{color:var(--text2);font-size:13px}
      #view-admin .adm-hint{font-size:11px;color:var(--text3);margin-top:3px}
      #view-admin .adm-msg{padding:10px 14px;border-radius:var(--radius-sm);margin-bottom:14px;font-size:14px;display:none}
      #view-admin .adm-msg.ok{background:var(--accent-dim);color:var(--accent);display:block}
      #view-admin .adm-msg.err{background:var(--danger-dim);color:var(--danger);display:block}
    `;
    const st = document.createElement('style');
    st.id = 'adm-styles'; st.textContent = css;
    document.head.appendChild(st);
  }

  // ---- построить вкладку и view (один раз) ----
  function build() {
    injectStyles();

    // нав-кнопка в сайдбаре
    const nav = document.querySelector('.sidebar-nav');
    if (nav && !document.getElementById('adm-nav-item')) {
      const btn = document.createElement('button');
      btn.id = 'adm-nav-item';
      btn.className = 'nav-item';
      btn.onclick = adminOpen;
      btn.innerHTML = `<svg class="nav-icon" viewBox="0 0 20 20" fill="currentColor">
        <path d="M10 2a3 3 0 100 6 3 3 0 000-6zM4 16a6 6 0 1112 0v1H4v-1z"/>
        <path d="M15.5 3.5l1 1-1.2 1.2-1-1 1.2-1.2z"/></svg><span>Админ</span>`;
      nav.appendChild(btn);
    }

    // сам view
    const anchor = document.getElementById('view-dashboard');
    if (anchor && !document.getElementById('view-admin')) {
      const v = document.createElement('div');
      v.id = 'view-admin';
      v.className = 'view';
      v.innerHTML = `
        <div class="view-header"><h1 class="view-title">Админ-панель</h1>
          <p class="view-subtitle">Управление уроками и пользователями</p></div>
        <div id="adm-msg" class="adm-msg"></div>

        <div class="adm-card">
          <h3 class="adm-h">➕ Добавить урок</h3>
          <label>Название (title)</label>
          <input id="adm-title" placeholder="Например: Переменные в Go">
          <label>Теория (theory)</label>
          <textarea id="adm-theory" placeholder="Теоретический материал..."></textarea>
          <label>Вопрос (question)</label>
          <input id="adm-question" placeholder="Текст вопроса">
          <label>Варианты ответа — через запятую (options)</label>
          <input id="adm-options" placeholder="вариант1, вариант2, вариант3">
          <div class="adm-hint">Пример: let x = 5, var x int, x = int</div>
          <div class="adm-row">
            <div><label>№ правильного (answer)</label>
              <input id="adm-answer" type="number" value="0">
              <div class="adm-hint">0 = первый вариант, 1 = второй...</div></div>
            <div><label>Сложность</label>
              <select id="adm-difficulty"><option>easy</option><option>medium</option><option>hard</option></select></div>
            <div><label>Категория</label><input id="adm-category" value="Основы"></div>
            <div><label>XP</label><input id="adm-xp" type="number" value="10"></div>
          </div>
          <button class="adm-btn" onclick="adminAddLesson()">Добавить урок</button>
        </div>

        <div class="adm-card">
          <h3 class="adm-h">📚 Уроки</h3>
          <div id="adm-lessons"><span class="adm-muted">Загрузка...</span></div>
        </div>

        <div class="adm-card">
          <h3 class="adm-h">👤 Пользователи</h3>
          <div id="adm-users"><span class="adm-muted">Загрузка...</span></div>
        </div>`;
      anchor.parentNode.appendChild(v);
    }
  }

  function teardown() {
    const n = document.getElementById('adm-nav-item'); if (n) n.remove();
    const v = document.getElementById('view-admin'); if (v) v.remove();
  }

  function msg(type, text) {
    const e = document.getElementById('adm-msg'); if (!e) return;
    e.className = 'adm-msg ' + type; e.textContent = text;
    if (type === 'ok') setTimeout(() => { e.className = 'adm-msg'; }, 2500);
  }

  // ---- открыть вкладку (как showView, но для admin) ----
  window.adminOpen = function () {
    document.querySelectorAll('.view').forEach(v => v.classList.remove('active'));
    document.querySelectorAll('.nav-item').forEach(n => n.classList.remove('active'));
    const v = document.getElementById('view-admin'); if (v) v.classList.add('active');
    const n = document.getElementById('adm-nav-item'); if (n) n.classList.add('active');
    adminLoadLessons(); adminLoadUsers();
  };

  // ---- добавить урок ----
  window.adminAddLesson = async function () {
    const g = id => document.getElementById(id);
    const opts = g('adm-options').value.split(',').map(s => s.trim()).filter(Boolean);
    const body = {
      title: g('adm-title').value.trim(),
      theory: g('adm-theory').value.trim(),
      question: g('adm-question').value.trim(),
      options: opts,
      answer: parseInt(g('adm-answer').value) || 0,
      difficulty: g('adm-difficulty').value,
      category: g('adm-category').value.trim(),
      xp_reward: parseInt(g('adm-xp').value) || 10
    };
    if (!body.title || !body.question) return msg('err', 'Название и вопрос обязательны');
    try {
      const r = await fetch(ADMIN_API + '/admin/lessons', { method: 'POST', headers: AH(), body: JSON.stringify(body) });
      if (!r.ok) return msg('err', 'Ошибка добавления (' + r.status + ')');
      msg('ok', 'Урок добавлен ✓');
      ['adm-title', 'adm-theory', 'adm-question', 'adm-options'].forEach(i => g(i).value = '');
      adminLoadLessons();
      if (typeof loadLessons === 'function') loadLessons(); // обновить основной список
    } catch { msg('err', 'Нет связи с сервером'); }
  };

  // ---- список уроков ----
  window.adminLoadLessons = async function () {
    const box = document.getElementById('adm-lessons'); if (!box) return;
    try {
      const r = await fetch(ADMIN_API + '/lessons');
      const list = await r.json();
      if (!list || !list.length) { box.innerHTML = '<span class="adm-muted">Уроков нет</span>'; return; }
      box.innerHTML = list.map(l => `
        <div class="adm-item">
          <div><b>#${l.id}</b> ${esc(l.title)}
            <span class="adm-badge">${esc(l.difficulty)}</span>
            <span class="adm-badge">${esc(l.category)}</span></div>
          <button class="adm-del" onclick="adminDelLesson(${l.id})">Удалить</button>
        </div>`).join('');
    } catch { box.innerHTML = '<span class="adm-muted">Ошибка загрузки</span>'; }
  };

  window.adminDelLesson = async function (id) {
    if (!confirm('Удалить урок #' + id + '?')) return;
    try {
      const r = await fetch(ADMIN_API + '/admin/lessons/' + id, { method: 'DELETE', headers: AH() });
      if (!r.ok) return msg('err', 'Ошибка удаления (' + r.status + ')');
      msg('ok', 'Урок удалён ✓');
      adminLoadLessons();
      if (typeof loadLessons === 'function') loadLessons();
    } catch { msg('err', 'Нет связи с сервером'); }
  };

  // ---- список пользователей ----
  window.adminLoadUsers = async function () {
    const box = document.getElementById('adm-users'); if (!box) return;
    try {
      const r = await fetch(ADMIN_API + '/admin/users', { headers: AH() });
      const list = await r.json();
      if (!list || !list.length) { box.innerHTML = '<span class="adm-muted">Пользователей нет</span>'; return; }
      box.innerHTML = list.map(u => `
        <div class="adm-item">
          <div><b>#${u.id}</b> ${esc(u.email)}
            ${u.role === 'admin' ? '<span class="adm-badge">admin</span>' : ''}
            <span class="adm-muted">· XP ${u.xp} · 🔥 ${u.streak}</span></div>
          ${u.role === 'admin' ? '<span class="adm-muted">—</span>' : `<button class="adm-del" onclick="adminDelUser(${u.id})">Удалить</button>`}
        </div>`).join('');
    } catch { box.innerHTML = '<span class="adm-muted">Ошибка загрузки</span>'; }
  };

  window.adminDelUser = async function (id) {
    if (!confirm('Удалить пользователя #' + id + '? Его прогресс тоже удалится.')) return;
    try {
      const r = await fetch(ADMIN_API + '/admin/users/' + id, { method: 'DELETE', headers: AH() });
      if (!r.ok) return msg('err', 'Ошибка удаления (' + r.status + ')');
      msg('ok', 'Пользователь удалён ✓');
      adminLoadUsers();
    } catch { msg('err', 'Нет связи с сервером'); }
  };

  // ---- проверка прав и инициализация ----
  async function adminInit() {
    if (!tok()) { teardown(); return; }
    try {
      const r = await fetch(ADMIN_API + '/admin/users', { headers: AH() });
      if (r.ok) build();        // админ → показать вкладку
      else teardown();          // обычный юзер → ничего
    } catch { teardown(); }
  }

  // ---- хуки в существующие функции приложения ----
  const _enter = window.enterApp;
  window.enterApp = function () {
    if (_enter) _enter.apply(this, arguments);
    setTimeout(adminInit, 300);
  };
  const _logout = window.doLogout;
  window.doLogout = function () {
    teardown();
    if (_logout) _logout.apply(this, arguments);
  };

  // если уже залогинен при загрузке страницы
  if (tok()) setTimeout(adminInit, 500);
})();