const express = require('express');
const { authenticate, checkUsageLimit } = require('../middleware/auth.middleware');
const logger = require('../utils/logger');

const router = express.Router();

/**
 * Rate a ride based on value per km
 */
function rateRide(valuePerKm, costPerKm) {
  const profitRatio = valuePerKm / (costPerKm || 1);
  
  if (profitRatio >= 3.0) return 'EXCELLENT';
  if (profitRatio >= 2.0) return 'GOOD';
  if (profitRatio >= 1.2) return 'AVERAGE';
  return 'BAD';
}

// ─── ANALYZE RIDE ────────────────────────────────────────
router.post('/analyze', authenticate, checkUsageLimit('ride_analysis'), async (req, res) => {
  try {
    const { rideValue, distance, duration, origin, destination, platform, vehicleId } = req.body;

    if (!rideValue || !distance) {
      return res.status(400).json({ error: 'Ride value and distance are required' });
    }

    // Get vehicle for cost calculation
    let costPerKm = 0.30; // default
    let vehicle = null;

    if (vehicleId) {
      vehicle = await req.prisma.vehicle.findUnique({ where: { id: vehicleId } });
      if (vehicle) costPerKm = vehicle.costPerKm || (vehicle.fuelPrice / vehicle.consumption);
    } else {
      vehicle = await req.prisma.vehicle.findFirst({
        where: { userId: req.user.id, isActive: true },
        orderBy: { createdAt: 'desc' },
      });
      if (vehicle) costPerKm = vehicle.costPerKm || (vehicle.fuelPrice / vehicle.consumption);
    }

    const valuePerKm = rideValue / distance;
    const fuelCost = costPerKm * distance;
    const estimatedProfit = rideValue - fuelCost;
    const rating = rateRide(valuePerKm, costPerKm);

    // Save ride analysis
    const ride = await req.prisma.ride.create({
      data: {
        userId: req.user.id,
        vehicleId: vehicle?.id,
        platform: platform || 'UBER',
        rideValue: parseFloat(rideValue),
        distance: parseFloat(distance),
        duration: duration ? parseInt(duration) : null,
        origin,
        destination,
        valuePerKm,
        estimatedProfit,
        fuelCost,
        rating,
      },
    });

    // Update daily goal
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const todayStr = today.toISOString().split('T')[0];

    const dailyGoal = await req.prisma.goal.findFirst({
      where: {
        userId: req.user.id,
        type: 'DAILY',
        period: todayStr,
      },
    });

    if (dailyGoal) {
      await req.prisma.goal.update({
        where: { id: dailyGoal.id },
        data: {
          currentAmount: { increment: estimatedProfit > 0 ? estimatedProfit : 0 },
          isCompleted: dailyGoal.currentAmount + estimatedProfit >= dailyGoal.targetAmount,
        },
      });
    }

    const compensa = rating === 'EXCELLENT' || rating === 'GOOD';

    res.status(201).json({
      analysis: {
        id: ride.id,
        valuePerKm: valuePerKm.toFixed(2),
        fuelCost: fuelCost.toFixed(2),
        estimatedProfit: estimatedProfit.toFixed(2),
        rating,
        compensa,
        recommendation: compensa
          ? `✅ COMPENSA - R$${valuePerKm.toFixed(2)}/km | Lucro: R$${estimatedProfit.toFixed(2)}`
          : `❌ NÃO COMPENSA - R$${valuePerKm.toFixed(2)}/km | Lucro: R$${estimatedProfit.toFixed(2)}`,
        details: {
          rideValue,
          distance,
          duration,
          origin,
          destination,
          costPerKm: costPerKm.toFixed(2),
        },
      },
    });
  } catch (error) {
    logger.error(`Ride analysis error: ${error.message}`);
    res.status(500).json({ error: 'Failed to analyze ride' });
  }
});

// ─── ACCEPT/REJECT RIDE ──────────────────────────────────
router.patch('/:id/accept', authenticate, async (req, res) => {
  try {
    const ride = await req.prisma.ride.update({
      where: { id: req.params.id, userId: req.user.id },
      data: { accepted: req.body.accepted || true },
    });

    res.json({ ride });
  } catch (error) {
    logger.error(`Accept ride error: ${error.message}`);
    res.status(500).json({ error: 'Failed to update ride' });
  }
});

// ─── GET RIDE HISTORY ────────────────────────────────────
router.get('/history', authenticate, async (req, res) => {
  try {
    const { page = 1, limit = 20, startDate, endDate } = req.query;
    const skip = (parseInt(page) - 1) * parseInt(limit);

    const where = { userId: req.user.id };
    if (startDate || endDate) {
      where.createdAt = {};
      if (startDate) where.createdAt.gte = new Date(startDate);
      if (endDate) where.createdAt.lte = new Date(endDate);
    }

    const [rides, total] = await Promise.all([
      req.prisma.ride.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip,
        take: parseInt(limit),
        include: { vehicle: true },
      }),
      req.prisma.ride.count({ where }),
    ]);

    res.json({
      rides,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / parseInt(limit)),
      },
    });
  } catch (error) {
    logger.error(`Get history error: ${error.message}`);
    res.status(500).json({ error: 'Failed to get ride history' });
  }
});

// ─── GET TODAY SUMMARY ───────────────────────────────────
router.get('/today', authenticate, async (req, res) => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const rides = await req.prisma.ride.findMany({
      where: {
        userId: req.user.id,
        createdAt: { gte: today },
      },
    });

    const accepted = rides.filter(r => r.accepted);
    const rejected = rides.filter(r => !r.accepted);
    const totalProfit = accepted.reduce((sum, r) => sum + (r.estimatedProfit || 0), 0);
    const totalKm = accepted.reduce((sum, r) => sum + r.distance, 0);
    const totalFuel = accepted.reduce((sum, r) => sum + (r.fuelCost || 0), 0);
    const avgValuePerKm = accepted.length > 0
      ? accepted.reduce((sum, r) => sum + r.valuePerKm, 0) / accepted.length
      : 0;

    res.json({
      summary: {
        totalRides: rides.length,
        accepted: accepted.length,
        rejected: rejected.length,
        totalProfit: totalProfit.toFixed(2),
        totalKm: totalKm.toFixed(1),
        totalFuel: totalFuel.toFixed(2),
        avgValuePerKm: avgValuePerKm.toFixed(2),
        totalRevenue: accepted.reduce((sum, r) => sum + r.rideValue, 0).toFixed(2),
      },
    });
  } catch (error) {
    logger.error(`Get today summary error: ${error.message}`);
    res.status(500).json({ error: 'Failed to get today summary' });
  }
});

module.exports = router;
