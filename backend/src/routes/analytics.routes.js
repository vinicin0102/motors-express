const express = require('express');
const { authenticate, requirePlan } = require('../middleware/auth.middleware');
const logger = require('../utils/logger');
const router = express.Router();

router.get('/dashboard', authenticate, async (req, res) => {
  try {
    const today = new Date(); today.setHours(0,0,0,0);
    const weekAgo = new Date(today); weekAgo.setDate(weekAgo.getDate()-7);
    const monthAgo = new Date(today); monthAgo.setDate(monthAgo.getDate()-30);

    const [todayRides, weekRides, monthRides] = await Promise.all([
      req.prisma.ride.findMany({ where: { userId: req.user.id, createdAt: { gte: today }}}),
      req.prisma.ride.findMany({ where: { userId: req.user.id, createdAt: { gte: weekAgo }}}),
      req.prisma.ride.findMany({ where: { userId: req.user.id, createdAt: { gte: monthAgo }}}),
    ]);

    const calc = (rides) => {
      const accepted = rides.filter(r=>r.accepted);
      return {
        total: rides.length, accepted: accepted.length, rejected: rides.length - accepted.length,
        revenue: accepted.reduce((s,r)=>s+r.rideValue,0).toFixed(2),
        profit: accepted.reduce((s,r)=>s+(r.estimatedProfit||0),0).toFixed(2),
        km: accepted.reduce((s,r)=>s+r.distance,0).toFixed(1),
        fuel: accepted.reduce((s,r)=>s+(r.fuelCost||0),0).toFixed(2),
        avgPerKm: accepted.length ? (accepted.reduce((s,r)=>s+r.valuePerKm,0)/accepted.length).toFixed(2) : '0.00',
      };
    };

    res.json({ dashboard: { today: calc(todayRides), week: calc(weekRides), month: calc(monthRides) }});
  } catch (e) { res.status(500).json({ error: 'Failed' }); }
});

router.get('/insights', authenticate, requirePlan('pro','premium'), async (req, res) => {
  try {
    const monthAgo = new Date(); monthAgo.setDate(monthAgo.getDate()-30);
    const rides = await req.prisma.ride.findMany({
      where: { userId: req.user.id, accepted: true, createdAt: { gte: monthAgo }},
    });

    if (rides.length < 5) return res.json({ insights: [{ text: 'Continue registrando corridas para insights personalizados.', type: 'info' }]});

    const byHour = {};
    rides.forEach(r => {
      const h = new Date(r.createdAt).getHours();
      if (!byHour[h]) byHour[h] = { count: 0, totalPerKm: 0 };
      byHour[h].count++; byHour[h].totalPerKm += r.valuePerKm;
    });

    const bestHour = Object.entries(byHour).sort((a,b) => (b[1].totalPerKm/b[1].count) - (a[1].totalPerKm/a[1].count))[0];
    const avgProfit = rides.reduce((s,r)=>s+(r.estimatedProfit||0),0)/rides.length;
    const excellentRides = rides.filter(r=>r.rating==='EXCELLENT'||r.rating==='GOOD');
    const acceptRate = (excellentRides.length/rides.length*100).toFixed(0);

    const insights = [
      { text: `Entre ${bestHour[0]}h e ${parseInt(bestHour[0])+2}h sua média aumenta ${((bestHour[1].totalPerKm/bestHour[1].count - rides.reduce((s,r)=>s+r.valuePerKm,0)/rides.length) / (rides.reduce((s,r)=>s+r.valuePerKm,0)/rides.length) * 100).toFixed(0)}%.`, type: 'tip', icon: '🕐' },
      { text: `Seu lucro médio por corrida é R$${avgProfit.toFixed(2)}.`, type: 'stat', icon: '💰' },
      { text: `${acceptRate}% das corridas analisadas são boas ou excelentes.`, type: 'stat', icon: '📊' },
      { text: `Você analisou ${rides.length} corridas nos últimos 30 dias.`, type: 'info', icon: '🚗' },
    ];

    res.json({ insights });
  } catch (e) { res.status(500).json({ error: 'Failed' }); }
});

router.get('/best-times', authenticate, requirePlan('pro','premium'), async (req, res) => {
  try {
    const rides = await req.prisma.ride.findMany({
      where: { userId: req.user.id, accepted: true },
      orderBy: { createdAt: 'desc' }, take: 200,
    });

    const byHour = Array(24).fill(null).map(()=>({ count:0, totalPerKm:0, totalProfit:0 }));
    rides.forEach(r => {
      const h = new Date(r.createdAt).getHours();
      byHour[h].count++; byHour[h].totalPerKm += r.valuePerKm; byHour[h].totalProfit += (r.estimatedProfit||0);
    });

    const bestTimes = byHour.map((d,i) => ({
      hour: i, rides: d.count,
      avgPerKm: d.count ? (d.totalPerKm/d.count).toFixed(2) : '0.00',
      avgProfit: d.count ? (d.totalProfit/d.count).toFixed(2) : '0.00',
    })).filter(t=>t.rides>0).sort((a,b)=>parseFloat(b.avgPerKm)-parseFloat(a.avgPerKm));

    res.json({ bestTimes });
  } catch (e) { res.status(500).json({ error: 'Failed' }); }
});

module.exports = router;
