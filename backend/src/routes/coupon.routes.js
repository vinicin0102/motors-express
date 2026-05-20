const express = require('express');
const { authenticate, requireAdmin } = require('../middleware/auth.middleware');
const router = express.Router();

router.post('/', authenticate, requireAdmin, async (req, res) => {
  try {
    const { code, discountType, discountValue, maxUses, expiresAt } = req.body;
    const coupon = await req.prisma.coupon.create({
      data: { code: code.toUpperCase(), discountType, discountValue: parseFloat(discountValue), maxUses: maxUses ? parseInt(maxUses) : null, expiresAt: expiresAt ? new Date(expiresAt) : null },
    });
    res.status(201).json({ coupon });
  } catch (e) { res.status(500).json({ error: 'Failed to create coupon' }); }
});

router.post('/validate', authenticate, async (req, res) => {
  try {
    const { code } = req.body;
    const coupon = await req.prisma.coupon.findUnique({ where: { code: code.toUpperCase() }});
    if (!coupon || !coupon.isActive) return res.status(404).json({ error: 'Invalid coupon' });
    if (coupon.expiresAt && new Date() > coupon.expiresAt) return res.status(400).json({ error: 'Coupon expired' });
    if (coupon.maxUses && coupon.currentUses >= coupon.maxUses) return res.status(400).json({ error: 'Coupon limit reached' });
    const used = await req.prisma.couponUsage.findUnique({ where: { couponId_userId: { couponId: coupon.id, userId: req.user.id }}});
    if (used) return res.status(400).json({ error: 'Coupon already used' });
    res.json({ coupon: { code: coupon.code, discountType: coupon.discountType, discountValue: coupon.discountValue }});
  } catch (e) { res.status(500).json({ error: 'Failed' }); }
});

router.post('/apply', authenticate, async (req, res) => {
  try {
    const { code } = req.body;
    const coupon = await req.prisma.coupon.findUnique({ where: { code: code.toUpperCase() }});
    if (!coupon) return res.status(404).json({ error: 'Invalid' });
    await req.prisma.couponUsage.create({ data: { couponId: coupon.id, userId: req.user.id }});
    await req.prisma.coupon.update({ where: { id: coupon.id }, data: { currentUses: { increment: 1 }}});
    res.json({ message: 'Coupon applied', discount: { type: coupon.discountType, value: coupon.discountValue }});
  } catch (e) { res.status(500).json({ error: 'Failed' }); }
});

module.exports = router;
