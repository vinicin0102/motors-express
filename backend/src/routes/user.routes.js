const express = require('express');
const { authenticate } = require('../middleware/auth.middleware');
const logger = require('../utils/logger');

const router = express.Router();

// ─── GET PROFILE ─────────────────────────────────────────
router.get('/me', authenticate, async (req, res) => {
  try {
    const user = await req.prisma.user.findUnique({
      where: { id: req.user.id },
      include: {
        vehicles: { where: { isActive: true } },
        subscription: { include: { plan: true } },
        goals: { orderBy: { createdAt: 'desc' }, take: 3 },
      },
    });

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    const { password, ...userData } = user;
    res.json({ user: userData });
  } catch (error) {
    logger.error(`Get profile error: ${error.message}`);
    res.status(500).json({ error: 'Failed to get profile' });
  }
});

// ─── UPDATE PROFILE ──────────────────────────────────────
router.put('/me', authenticate, async (req, res) => {
  try {
    const { name, phone, city, platform } = req.body;

    const user = await req.prisma.user.update({
      where: { id: req.user.id },
      data: { name, phone, city, platform },
    });

    const { password, ...userData } = user;
    res.json({ user: userData });
  } catch (error) {
    logger.error(`Update profile error: ${error.message}`);
    res.status(500).json({ error: 'Failed to update profile' });
  }
});

// ─── DELETE ACCOUNT ──────────────────────────────────────
router.delete('/me', authenticate, async (req, res) => {
  try {
    await req.prisma.user.update({
      where: { id: req.user.id },
      data: { isActive: false },
    });

    res.json({ message: 'Account deactivated successfully' });
  } catch (error) {
    logger.error(`Delete account error: ${error.message}`);
    res.status(500).json({ error: 'Failed to deactivate account' });
  }
});

module.exports = router;
