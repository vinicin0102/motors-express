const jwt = require('jsonwebtoken');
const logger = require('../utils/logger');

/**
 * Authentication middleware - validates JWT token
 */
const authenticate = (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'Authentication required' });
    }

    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    req.user = {
      id: decoded.id,
      email: decoded.email,
      role: decoded.role,
    };
    
    next();
  } catch (error) {
    logger.warn(`Auth failed: ${error.message}`);
    return res.status(401).json({ error: 'Invalid or expired token' });
  }
};

/**
 * Admin-only middleware
 */
const requireAdmin = (req, res, next) => {
  if (req.user?.role !== 'ADMIN') {
    return res.status(403).json({ error: 'Admin access required' });
  }
  next();
};

/**
 * Subscription check middleware
 */
const requirePlan = (...allowedPlans) => {
  return async (req, res, next) => {
    try {
      const subscription = await req.prisma.subscription.findUnique({
        where: { userId: req.user.id },
        include: { plan: true },
      });

      if (!subscription) {
        return res.status(403).json({
          error: 'Subscription required',
          requiredPlans: allowedPlans,
        });
      }

      // Check trial
      if (subscription.status === 'TRIAL') {
        if (subscription.trialEndsAt && new Date() > subscription.trialEndsAt) {
          await req.prisma.subscription.update({
            where: { id: subscription.id },
            data: { status: 'EXPIRED' },
          });
          return res.status(403).json({ error: 'Trial expired. Please upgrade.' });
        }
      }

      // Check active status
      if (!['ACTIVE', 'TRIAL'].includes(subscription.status)) {
        return res.status(403).json({ error: 'Active subscription required' });
      }

      // Check plan level
      if (!allowedPlans.includes(subscription.plan.slug)) {
        return res.status(403).json({
          error: 'Plan upgrade required',
          currentPlan: subscription.plan.slug,
          requiredPlans: allowedPlans,
        });
      }

      req.subscription = subscription;
      next();
    } catch (error) {
      logger.error(`Plan check error: ${error.message}`);
      return res.status(500).json({ error: 'Internal server error' });
    }
  };
};

/**
 * Usage limit middleware (for FREE plan)
 */
const checkUsageLimit = (feature) => {
  return async (req, res, next) => {
    try {
      const subscription = await req.prisma.subscription.findUnique({
        where: { userId: req.user.id },
        include: { plan: true },
      });

      if (!subscription?.plan?.maxAnalyses) {
        return next(); // unlimited
      }

      const today = new Date();
      today.setHours(0, 0, 0, 0);

      const usageCount = await req.prisma.usageLog.count({
        where: {
          userId: req.user.id,
          feature,
          date: { gte: today },
        },
      });

      if (usageCount >= subscription.plan.maxAnalyses) {
        return res.status(429).json({
          error: 'Daily limit reached',
          limit: subscription.plan.maxAnalyses,
          used: usageCount,
          upgrade: 'Upgrade to PRO for unlimited analyses',
        });
      }

      // Log usage
      await req.prisma.usageLog.create({
        data: { userId: req.user.id, feature },
      });

      next();
    } catch (error) {
      logger.error(`Usage check error: ${error.message}`);
      next();
    }
  };
};

module.exports = { authenticate, requireAdmin, requirePlan, checkUsageLimit };
