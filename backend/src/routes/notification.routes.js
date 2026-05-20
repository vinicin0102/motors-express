const express = require('express');
const { authenticate } = require('../middleware/auth.middleware');
const router = express.Router();

router.get('/', authenticate, async (req, res) => {
  try {
    const notifs = await req.prisma.notification.findMany({
      where: { userId: req.user.id }, orderBy: { createdAt: 'desc' }, take: 50,
    });
    res.json({ notifications: notifs });
  } catch (e) { res.status(500).json({ error: 'Failed' }); }
});

router.patch('/:id/read', authenticate, async (req, res) => {
  try {
    await req.prisma.notification.update({ where: { id: req.params.id, userId: req.user.id }, data: { isRead: true }});
    res.json({ message: 'Marked as read' });
  } catch (e) { res.status(500).json({ error: 'Failed' }); }
});

router.patch('/read-all', authenticate, async (req, res) => {
  try {
    await req.prisma.notification.updateMany({ where: { userId: req.user.id, isRead: false }, data: { isRead: true }});
    res.json({ message: 'All marked as read' });
  } catch (e) { res.status(500).json({ error: 'Failed' }); }
});

module.exports = router;
