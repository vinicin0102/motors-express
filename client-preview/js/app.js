/**
   DRIVER AI — CLIENT APP JAVASCRIPT (PREVIEW)
 */

let costPerKm = 0.49;
let dailyGoal = 280.00;
let todayEarnings = 187.50;
let todayKm = 48.5;
let todayRidesCount = 12;

let ridesHistory = [
  { val: 28.00, km: 13.0, platform: 'Uber', accepted: true, rate: 'EXCELENTE', time: '17:02', from: 'Centro', to: 'Vila Nova' },
  { val: 12.50, km: 4.2, platform: '99', accepted: true, rate: 'BOA', time: '16:15', from: 'Shopping', to: 'Moema' },
  { val: 15.00, km: 19.5, platform: 'Uber', accepted: false, rate: 'RUIM', time: '15:30', from: 'Aeroporto', to: 'Lapa' },
  { val: 35.00, km: 15.0, platform: 'InDrive', accepted: true, rate: 'EXCELENTE', time: '14:20', from: 'Pinheiros', to: 'Paulista' },
  { val: 9.00, km: 11.0, platform: '99', accepted: false, rate: 'RUIM', time: '12:45', from: 'Santana', to: 'Centro' },
];

let lastSimulatedRide = null;

document.addEventListener('DOMContentLoaded', () => {
  // Auto transition Splash to Login
  setTimeout(() => {
    navigate('login');
  }, 1800);

  calculateOperCost();
  renderHistory();
});

function navigate(screenId) {
  // Hide all screens
  const screens = document.querySelectorAll('.screen');
  screens.forEach(s => s.classList.remove('active'));

  // Show target
  const target = document.getElementById(`screen-${screenId}`);
  if (target) target.classList.add('active');

  // Handle bottom navigation visibility
  const bottomNav = document.getElementById('bottom-nav');
  const noNavScreens = ['splash', 'login', 'register', 'vehicle', 'subscription'];
  if (noNavScreens.includes(screenId)) {
    bottomNav.style.display = 'none';
  } else {
    bottomNav.style.display = 'flex';
  }

  // Update active bottom nav button
  const navBtns = document.querySelectorAll('.nav-btn');
  navBtns.forEach(btn => {
    btn.classList.remove('active');
    if (btn.dataset.target === screenId) {
      btn.classList.add('active');
    }
  });

  if (screenId === 'history') {
    renderHistory();
  }
}

// ─── COST CALCULATION ──────────────────────────────────
function calculateOperCost() {
  const cons = parseFloat(document.getElementById('veh-cons').value) || 12;
  const price = parseFloat(document.getElementById('veh-price').value) || 5.89;
  const fuelType = document.getElementById('veh-fuel').value;

  // Simple operational cost calculation
  let fuelCost = price / cons;
  let maintenanceCost = 0.12; // estimated maintenance/depreciation per km
  costPerKm = fuelCost + maintenanceCost;

  document.getElementById('oper-cost-val').textContent = `R$ ${costPerKm.toFixed(2)} / km`;

  // Update UI values that depend on it
  const totalFuelCostVal = costPerKm * todayKm;
  const fuelDash = document.getElementById('dash-fuel');
  if (fuelDash) {
    fuelDash.textContent = `R$ ${totalFuelCostVal.toFixed(2)}`;
  }
}

function saveVehicleAndGo() {
  const customGoal = parseFloat(document.getElementById('goal-daily').value) || 280;
  dailyGoal = customGoal;
  navigate('dashboard');
}

// ─── SIMULATION & OVERLAY ──────────────────────────────
function simulateRide(excellent) {
  // Prepare simulation data
  let val, km, platform;
  const platforms = ['Uber', '99', 'InDrive'];
  platform = platforms[Math.floor(Math.random() * platforms.length)];

  if (excellent) {
    km = parseFloat((Math.random() * 8 + 3).toFixed(1)); // 3 to 11 km
    val = parseFloat((km * (costPerKm * 4.5)).toFixed(2)); // High earnings per km
  } else {
    km = parseFloat((Math.random() * 12 + 6).toFixed(1)); // 6 to 18 km
    val = parseFloat((km * (costPerKm * 1.05)).toFixed(2)); // Low earnings per km
  }

  const ratePerKm = val / km;
  const fuelCost = costPerKm * km;
  const netProfit = val - fuelCost;
  const compensa = ratePerKm >= costPerKm * 1.8;

  lastSimulatedRide = { val, km, platform, ratePerKm, netProfit, compensa };

  // Setup Overlay contents
  document.getElementById('overlay-platform').textContent = `🚗 ${platform}`;
  document.getElementById('overlay-km-rate').textContent = `💰 R$ ${ratePerKm.toFixed(2)}/km`;
  document.getElementById('overlay-profit').textContent = `⛽ Lucro estimado: R$ ${netProfit.toFixed(2)}`;
  document.getElementById('overlay-details').textContent = `R$ ${val.toFixed(2)} • ${km}km`;

  const badge = document.getElementById('overlay-badge');
  if (compensa) {
    badge.textContent = '🟢 COMPENSA';
    badge.className = 'overlay-badge success';
    document.getElementById('ride-overlay').style.borderColor = 'var(--neon-green)';
    document.getElementById('ride-overlay').style.boxShadow = '0 10px 25px rgba(0, 0, 0, 0.5), 0 0 15px rgba(0, 230, 118, 0.2)';
  } else {
    badge.textContent = '🔴 NÃO COMPENSA';
    badge.className = 'overlay-badge danger';
    document.getElementById('ride-overlay').style.borderColor = 'var(--error)';
    document.getElementById('ride-overlay').style.boxShadow = '0 10px 25px rgba(0, 0, 0, 0.5), 0 0 15px rgba(255, 82, 82, 0.2)';
  }

  // Show overlay
  document.getElementById('ride-overlay').classList.remove('hidden');
}

function dismissOverlay() {
  document.getElementById('ride-overlay').classList.add('hidden');
}

function acceptRideSim() {
  dismissOverlay();
  if (!lastSimulatedRide) return;

  // Add to today's earnings
  todayEarnings += lastSimulatedRide.val;
  todayKm += lastSimulatedRide.km;
  todayRidesCount += 1;

  // Save to history
  ridesHistory.unshift({
    val: lastSimulatedRide.val,
    km: lastSimulatedRide.km,
    platform: lastSimulatedRide.platform,
    accepted: true,
    rate: lastSimulatedRide.compensa ? 'EXCELENTE' : 'RUIM',
    time: new Date().toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' }),
    from: 'Ponto A',
    to: 'Ponto B'
  });

  // Update UI
  updateDashboardValues();
}

function rejectRideSim() {
  dismissOverlay();
  if (!lastSimulatedRide) return;

  ridesHistory.unshift({
    val: lastSimulatedRide.val,
    km: lastSimulatedRide.km,
    platform: lastSimulatedRide.platform,
    accepted: false,
    rate: lastSimulatedRide.compensa ? 'EXCELENTE' : 'RUIM',
    time: new Date().toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' }),
    from: 'Ponto A',
    to: 'Ponto B'
  });
}

function updateDashboardValues() {
  const dashProfit = document.getElementById('dash-profit');
  if (dashProfit) {
    dashProfit.textContent = `R$ ${todayEarnings.toFixed(2)}`;
  }
  
  const stats = document.querySelectorAll('.stat-card-2');
  if (stats.length >= 4) {
    stats[0].querySelector('.num').textContent = todayRidesCount;
    stats[1].querySelector('.num').textContent = todayKm.toFixed(1);
    
    const fuelCost = costPerKm * todayKm;
    stats[2].querySelector('.num').textContent = `R$ ${fuelCost.toFixed(2)}`;
    
    const avg = todayEarnings / todayKm;
    stats[3].querySelector('.num').textContent = avg.toFixed(2);
  }

  // Update progress bar
  const progressPct = Math.min((todayEarnings / dailyGoal) * 100, 100);
  const fill = document.querySelector('.progress-fill');
  if (fill) fill.style.width = `${progressPct.toFixed(0)}%`;
  
  const pctText = document.querySelector('.goal-pct');
  if (pctText) pctText.textContent = `${progressPct.toFixed(0)}%`;
  
  const trackerDesc = document.querySelector('.goal-desc span');
  if (trackerDesc) {
    trackerDesc.textContent = `R$ ${todayEarnings.toFixed(2)} / R$ ${dailyGoal.toFixed(2)}`;
  }

  const remainVal = dailyGoal - todayEarnings;
  const remainText = document.querySelector('.goal-remain');
  if (remainText) {
    if (remainVal > 0) {
      remainText.textContent = `Faltam R$ ${remainVal.toFixed(2)}`;
    } else {
      remainText.textContent = `Meta batida! 🎉`;
      remainText.style.color = 'var(--neon-green)';
    }
  }
}

// ─── RENDER HISTORY ────────────────────────────────────
function renderHistory() {
  const container = document.getElementById('history-list');
  if (!container) return;

  container.innerHTML = '';
  ridesHistory.forEach(r => {
    const isGood = r.rate === 'EXCELENTE' || r.rate === 'BOA';
    const acceptText = r.accepted ? '✅ Aceita' : '❌ Recusada';
    const badgeClass = isGood ? 'excelente' : 'ruim';

    const item = document.createElement('div');
    item.className = 'history-item';
    item.innerHTML = `
      <div class="hist-left">
        <span class="hist-val">R$ ${r.val.toFixed(2)} (${r.platform})</span>
        <span class="hist-route">${acceptText} • R$ ${(r.val / r.km).toFixed(2)}/km</span>
      </div>
      <div class="hist-right">
        <span class="hist-km">${r.km} km</span>
        <span class="hist-rate-badge ${badgeClass}">${r.rate}</span>
      </div>
    `;
    container.appendChild(item);
  });
}

function upgradeToPro() {
  alert('Seu plano PRO foi ativado com sucesso!');
  navigate('dashboard');
}

function upgradeToPremium() {
  alert('Seu plano PREMIUM foi ativado com sucesso!');
  navigate('dashboard');
}
