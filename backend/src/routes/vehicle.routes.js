const express = require('express');
const { authenticate } = require('../middleware/auth.middleware');
const logger = require('../utils/logger');

const router = express.Router();

// ─── CREATE VEHICLE ──────────────────────────────────────
router.post('/', authenticate, async (req, res) => {
  try {
    const { brand, model, year, fuelType, consumption, fuelPrice } = req.body;

    if (!brand || !model || !year || !fuelType || !consumption || !fuelPrice) {
      return res.status(400).json({ error: 'All vehicle fields are required' });
    }

    // Calculate cost per km
    const costPerKm = fuelPrice / consumption;

    const vehicle = await req.prisma.vehicle.create({
      data: {
        userId: req.user.id,
        brand,
        model,
        year: parseInt(year),
        fuelType,
        consumption: parseFloat(consumption),
        fuelPrice: parseFloat(fuelPrice),
        costPerKm,
      },
    });

    logger.info(`Vehicle created for user ${req.user.id}: ${brand} ${model}`);
    res.status(201).json({ vehicle });
  } catch (error) {
    logger.error(`Create vehicle error: ${error.message}`);
    res.status(500).json({ error: 'Failed to create vehicle' });
  }
});

// ─── GET VEHICLES ────────────────────────────────────────
router.get('/', authenticate, async (req, res) => {
  try {
    const vehicles = await req.prisma.vehicle.findMany({
      where: { userId: req.user.id, isActive: true },
      orderBy: { createdAt: 'desc' },
    });

    res.json({ vehicles });
  } catch (error) {
    logger.error(`Get vehicles error: ${error.message}`);
    res.status(500).json({ error: 'Failed to get vehicles' });
  }
});

// ─── UPDATE VEHICLE ──────────────────────────────────────
router.put('/:id', authenticate, async (req, res) => {
  try {
    const { id } = req.params;
    const { brand, model, year, fuelType, consumption, fuelPrice } = req.body;

    const costPerKm = fuelPrice && consumption ? fuelPrice / consumption : undefined;

    const vehicle = await req.prisma.vehicle.update({
      where: { id, userId: req.user.id },
      data: {
        ...(brand && { brand }),
        ...(model && { model }),
        ...(year && { year: parseInt(year) }),
        ...(fuelType && { fuelType }),
        ...(consumption && { consumption: parseFloat(consumption) }),
        ...(fuelPrice && { fuelPrice: parseFloat(fuelPrice) }),
        ...(costPerKm && { costPerKm }),
      },
    });

    res.json({ vehicle });
  } catch (error) {
    logger.error(`Update vehicle error: ${error.message}`);
    res.status(500).json({ error: 'Failed to update vehicle' });
  }
});

// ─── DELETE VEHICLE ──────────────────────────────────────
router.delete('/:id', authenticate, async (req, res) => {
  try {
    await req.prisma.vehicle.update({
      where: { id: req.params.id, userId: req.user.id },
      data: { isActive: false },
    });

    res.json({ message: 'Vehicle removed successfully' });
  } catch (error) {
    logger.error(`Delete vehicle error: ${error.message}`);
    res.status(500).json({ error: 'Failed to delete vehicle' });
  }
});

module.exports = router;
