/**
 * Driver AI — Admin Panel JavaScript
 * Navigation, data loading, and interactions
 */

document.addEventListener('DOMContentLoaded', () => {
  initNavigation();
  initMenuToggle();
  animateStats();
});

// ─── NAVIGATION ──────────────────────────────────────────
function initNavigation() {
  const navItems = document.querySelectorAll('.nav-item');
  const pages = document.querySelectorAll('.page');
  const pageTitle = document.getElementById('pageTitle');

  const titles = {
    dashboard: 'Dashboard',
    users: 'Gerenciar Usuários',
    subscriptions: 'Assinaturas',
    analytics: 'Analytics',
    notifications: 'Notificações',
    coupons: 'Cupons',
    settings: 'Configurações',
  };

  navItems.forEach(item => {
    item.addEventListener('click', (e) => {
      e.preventDefault();
      const page = item.dataset.page;

      // Update active nav
      navItems.forEach(n => n.classList.remove('active'));
      item.classList.add('active');

      // Update page
      pages.forEach(p => p.classList.remove('active'));
      const target = document.getElementById(`page-${page}`);
      if (target) target.classList.add('active');

      // Update title
      if (pageTitle) pageTitle.textContent = titles[page] || 'Dashboard';

      // Close mobile menu
      document.getElementById('sidebar').classList.remove('open');
    });
  });
}

// ─── MENU TOGGLE ─────────────────────────────────────────
function initMenuToggle() {
  const toggle = document.getElementById('menuToggle');
  const sidebar = document.getElementById('sidebar');

  if (toggle && sidebar) {
    toggle.addEventListener('click', () => {
      sidebar.classList.toggle('open');
    });

    // Close sidebar on click outside
    document.addEventListener('click', (e) => {
      if (window.innerWidth <= 768 && !sidebar.contains(e.target) && !toggle.contains(e.target)) {
        sidebar.classList.remove('open');
      }
    });
  }
}

// ─── ANIMATE STATS ───────────────────────────────────────
function animateStats() {
  const values = document.querySelectorAll('.stat-value');
  values.forEach(el => {
    const text = el.textContent;
    const numMatch = text.match(/[\d,.]+/);
    if (!numMatch) return;

    const target = parseFloat(numMatch[0].replace(/[,.]/g, ''));
    const prefix = text.substring(0, text.indexOf(numMatch[0]));
    const suffix = text.substring(text.indexOf(numMatch[0]) + numMatch[0].length);
    const isDecimal = numMatch[0].includes(',') || numMatch[0].includes('.');

    let current = 0;
    const duration = 1500;
    const start = performance.now();

    function animate(timestamp) {
      const elapsed = timestamp - start;
      const progress = Math.min(elapsed / duration, 1);
      const eased = 1 - Math.pow(1 - progress, 3);

      current = Math.round(target * eased);

      let formatted;
      if (target > 1000) {
        formatted = current.toLocaleString('pt-BR');
      } else {
        formatted = current.toString();
      }

      el.textContent = prefix + formatted + suffix;

      if (progress < 1) requestAnimationFrame(animate);
    }

    requestAnimationFrame(animate);
  });
}

// ─── CHART ANIMATION ─────────────────────────────────────
const chartBars = document.querySelectorAll('.chart-bar');
chartBars.forEach((bar, i) => {
  const height = bar.style.height;
  bar.style.height = '0%';
  setTimeout(() => {
    bar.style.height = height;
  }, 300 + i * 100);
});

// ─── NOTIFICATION FORM ───────────────────────────────────
const notifForm = document.getElementById('notifForm');
if (notifForm) {
  notifForm.addEventListener('submit', (e) => {
    e.preventDefault();
    const title = document.getElementById('notifTitle').value;
    const body = document.getElementById('notifBody').value;
    const target = document.getElementById('notifTarget').value;

    if (!title || !body) {
      alert('Preencha todos os campos');
      return;
    }

    console.log('Sending notification:', { title, body, target });
    alert(`Notificação "${title}" enviada para: ${target}`);
    notifForm.reset();
  });
}

// ─── SEARCH ──────────────────────────────────────────────
const searchInput = document.getElementById('searchInput');
if (searchInput) {
  searchInput.addEventListener('input', (e) => {
    const query = e.target.value.toLowerCase();
    const rows = document.querySelectorAll('#usersTableBody tr, #allUsersTable tr');
    rows.forEach(row => {
      const text = row.textContent.toLowerCase();
      row.style.display = text.includes(query) ? '' : 'none';
    });
  });
}

// ─── API INTEGRATION ─────────────────────────────────────
const API_URL = 'http://localhost:3000/api';

async function fetchAdminStats() {
  try {
    const token = localStorage.getItem('admin_token');
    const res = await fetch(`${API_URL}/admin/stats`, {
      headers: { 'Authorization': `Bearer ${token}` },
    });
    const data = await res.json();

    if (data.stats) {
      document.getElementById('totalUsers').textContent = data.stats.totalUsers.toLocaleString('pt-BR');
      document.getElementById('activeUsers').textContent = data.stats.activeUsers.toLocaleString('pt-BR');
      document.getElementById('totalRevenue').textContent = `R$ ${data.stats.totalRevenue.toLocaleString('pt-BR')}`;
      document.getElementById('totalRides').textContent = data.stats.totalRides.toLocaleString('pt-BR');
    }
  } catch (err) {
    console.log('Using demo data (backend not connected)');
  }
}

// Load data on init
fetchAdminStats();
