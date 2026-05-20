const express = require('express');
const { authenticate } = require('../middleware/auth.middleware');
const logger = require('../utils/logger');
const router = express.Router();

router.get('/plans', async (req, res) => {
  try {
    const plans = await req.prisma.plan.findMany({ where: { isActive: true }, orderBy: { priceMonthly: 'asc' }});
    res.json({ plans: plans.map(p => ({ ...p, features: JSON.parse(p.features || '[]') })) });
  } catch (e) { res.status(500).json({ error: 'Failed' }); }
});

router.get('/current', authenticate, async (req, res) => {
  try {
    const sub = await req.prisma.subscription.findUnique({
      where: { userId: req.user.id }, include: { plan: true },
    });
    if (!sub) return res.status(404).json({ error: 'No subscription' });
    const daysLeft = sub.trialEndsAt ? Math.max(0, Math.ceil((new Date(sub.trialEndsAt) - new Date()) / 86400000)) : null;
    res.json({ subscription: { ...sub, plan: { ...sub.plan, features: JSON.parse(sub.plan.features||'[]') }, trialDaysLeft: daysLeft }});
  } catch (e) { res.status(500).json({ error: 'Failed' }); }
});

router.post('/trial', authenticate, async (req, res) => {
  try {
    const sub = await req.prisma.subscription.findUnique({ where: { userId: req.user.id }});
    if (sub && sub.status !== 'ACTIVE') return res.status(400).json({ error: 'Trial not available' });
    const proPlan = await req.prisma.plan.findUnique({ where: { slug: 'pro' }});
    if (!proPlan) return res.status(404).json({ error: 'Plan not found' });
    const trialEnd = new Date(); trialEnd.setDate(trialEnd.getDate() + 7);
    const updated = await req.prisma.subscription.update({
      where: { userId: req.user.id },
      data: { planId: proPlan.id, status: 'TRIAL', trialEndsAt: trialEnd },
    });
    res.json({ subscription: updated, message: 'Trial started! 7 days free.' });
  } catch (e) { res.status(500).json({ error: 'Failed' }); }
});

router.post('/upgrade', authenticate, async (req, res) => {
  try {
    const { planSlug, billingCycle } = req.body;
    const plan = await req.prisma.plan.findUnique({ where: { slug: planSlug }});
    if (!plan) return res.status(404).json({ error: 'Plan not found' });
    const now = new Date();
    const periodEnd = new Date(now);
    periodEnd.setMonth(periodEnd.getMonth() + (billingCycle === 'yearly' ? 12 : 1));
    const sub = await req.prisma.subscription.upsert({
      where: { userId: req.user.id },
      update: { planId: plan.id, status: 'ACTIVE', currentPeriodStart: now, currentPeriodEnd: periodEnd, trialEndsAt: null },
      create: { userId: req.user.id, planId: plan.id, status: 'ACTIVE', currentPeriodStart: now, currentPeriodEnd: periodEnd },
    });
    await req.prisma.payment.create({
      data: { subscriptionId: sub.id, amount: billingCycle === 'yearly' ? plan.priceYearly : plan.priceMonthly, status: 'SUCCEEDED', paidAt: now },
    });
    res.json({ subscription: sub });
  } catch (e) { res.status(500).json({ error: 'Failed' }); }
});

router.post('/cancel', authenticate, async (req, res) => {
  try {
    const sub = await req.prisma.subscription.update({
      where: { userId: req.user.id },
      data: { status: 'CANCELLED', cancelledAt: new Date() },
    });
    res.json({ subscription: sub, message: 'Subscription cancelled' });
  } catch (e) { res.status(500).json({ error: 'Failed' }); }
});

module.exports = router;
