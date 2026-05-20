const express = require('express');
const { authenticate } = require('../middleware/auth.middleware');
const logger = require('../utils/logger');

const router = express.Router();

router.post('/', authenticate, async (req, res) => {
  try {
    const { type, targetAmount } = req.body;
    if (!type || !targetAmount) {
      return res.status(400).json({ error: 'Type and target amount are required' });
    }

    const today = new Date();
    let period;
    switch (type) {
      case 'DAILY': period = today.toISOString().split('T')[0]; break;
      case 'WEEKLY':
        const ws = new Date(today); ws.setDate(today.getDate() - today.getDay());
        period = ws.toISOString().split('T')[0]; break;
      case 'MONTHLY':
        period = `${today.getFullYear()}-${String(today.getMonth()+1).padStart(2,'0')}`; break;
    }

    const existing = await req.prisma.goal.findFirst({
      where: { userId: req.user.id, type, period },
    });

    const goal = existing
      ? await req.prisma.goal.update({ where: { id: existing.id }, data: { targetAmount: parseFloat(targetAmount) } })
      : await req.prisma.goal.create({ data: { userId: req.user.id, type, targetAmount: parseFloat(targetAmount), period } });

    res.status(201).json({ goal });
  } catch (error) {
    logger.error(`Goal error: ${error.message}`);
    res.status(500).json({ error: 'Failed' });
  }
});

router.get('/', authenticate, async (req, res) => {
  try {
    const goals = await req.prisma.goal.findMany({
      where: { userId: req.user.id }, orderBy: { createdAt: 'desc' }, take: 10,
    });
    const mapped = goals.map(g => ({
      ...g,
      progress: g.targetAmount > 0 ? Math.min((g.currentAmount / g.targetAmount)*100, 100).toFixed(1) : 0,
      remaining: Math.max(g.targetAmount - g.currentAmount, 0).toFixed(2),
      estimatedRides: Math.ceil(Math.max(g.targetAmount - g.currentAmount, 0) / 15),
    }));
    res.json({ goals: mapped });
  } catch (error) {
    res.status(500).json({ error: 'Failed' });
  }
});

router.get('/summary', authenticate, async (req, res) => {
  try {
    const today = new Date();
    const todayStr = today.toISOString().split('T')[0];
    const ws = new Date(today); ws.setDate(today.getDate()-today.getDay());
    const monthStr = `${today.getFullYear()}-${String(today.getMonth()+1).padStart(2,'0')}`;
    const [daily, weekly, monthly] = await Promise.all([
      req.prisma.goal.findFirst({ where: { userId: req.user.id, type: 'DAILY', period: todayStr }}),
      req.prisma.goal.findFirst({ where: { userId: req.user.id, type: 'WEEKLY', period: ws.toISOString().split('T')[0] }}),
      req.prisma.goal.findFirst({ where: { userId: req.user.id, type: 'MONTHLY', period: monthStr }}),
    ]);
    const fmt = g => g ? { target: g.targetAmount, current: g.currentAmount, remaining: Math.max(g.targetAmount-g.currentAmount,0), progress: (g.currentAmount/g.targetAmount*100).toFixed(1), isCompleted: g.isCompleted } : null;
    res.json({ summary: { daily: fmt(daily), weekly: fmt(weekly), monthly: fmt(monthly) }});
  } catch (error) {
    res.status(500).json({ error: 'Failed' });
  }
});

module.exports = router;
