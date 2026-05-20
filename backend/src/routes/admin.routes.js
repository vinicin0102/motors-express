const express = require('express');
const { authenticate, requireAdmin } = require('../middleware/auth.middleware');
const logger = require('../utils/logger');
const router = express.Router();

router.use(authenticate, requireAdmin);

router.get('/stats', async (req, res) => {
  try {
    const [totalUsers, activeUsers, totalRides, activeSubs] = await Promise.all([
      req.prisma.user.count(),
      req.prisma.user.count({ where: { isActive: true }}),
      req.prisma.ride.count(),
      req.prisma.subscription.count({ where: { status: { in: ['ACTIVE','TRIAL'] }}}),
    ]);
    const revenue = await req.prisma.payment.aggregate({ _sum: { amount: true }, where: { status: 'SUCCEEDED' }});
    const planDist = await req.prisma.subscription.groupBy({ by: ['status'], _count: true });
    res.json({ stats: { totalUsers, activeUsers, totalRides, activeSubscriptions: activeSubs, totalRevenue: revenue._sum.amount || 0, planDistribution: planDist }});
  } catch (e) { res.status(500).json({ error: 'Failed' }); }
});

router.get('/users', async (req, res) => {
  try {
    const { page=1, limit=20, search } = req.query;
    const where = search ? { OR: [{ name: { contains: search, mode: 'insensitive' }}, { email: { contains: search, mode: 'insensitive' }}]} : {};
    const [users, total] = await Promise.all([
      req.prisma.user.findMany({ where, include: { subscription: { include: { plan: true }}}, skip: (page-1)*limit, take: parseInt(limit), orderBy: { createdAt: 'desc' }}),
      req.prisma.user.count({ where }),
    ]);
    res.json({ users: users.map(({password,...u})=>u), pagination: { page: parseInt(page), limit: parseInt(limit), total, pages: Math.ceil(total/limit) }});
  } catch (e) { res.status(500).json({ error: 'Failed' }); }
});

router.patch('/users/:id/block', async (req, res) => {
  try {
    const user = await req.prisma.user.update({ where: { id: req.params.id }, data: { isActive: false }});
    res.json({ message: 'User blocked', user: { id: user.id, isActive: user.isActive }});
  } catch (e) { res.status(500).json({ error: 'Failed' }); }
});

router.patch('/users/:id/unblock', async (req, res) => {
  try {
    const user = await req.prisma.user.update({ where: { id: req.params.id }, data: { isActive: true }});
    res.json({ message: 'User unblocked', user: { id: user.id, isActive: user.isActive }});
  } catch (e) { res.status(500).json({ error: 'Failed' }); }
});

router.get('/analytics', async (req, res) => {
  try {
    const thirtyDays = new Date(); thirtyDays.setDate(thirtyDays.getDate()-30);
    const newUsers = await req.prisma.user.count({ where: { createdAt: { gte: thirtyDays }}});
    const newSubs = await req.prisma.subscription.count({ where: { createdAt: { gte: thirtyDays }, status: 'ACTIVE' }});
    const mrr = await req.prisma.payment.aggregate({ _sum: { amount: true }, where: { status: 'SUCCEEDED', paidAt: { gte: thirtyDays }}});
    const cancellations = await req.prisma.subscription.count({ where: { cancelledAt: { gte: thirtyDays }}});
    res.json({ analytics: { newUsers30d: newUsers, newSubscriptions30d: newSubs, mrr: mrr._sum.amount || 0, cancellations30d: cancellations }});
  } catch (e) { res.status(500).json({ error: 'Failed' }); }
});

module.exports = router;
