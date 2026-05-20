const express = require('express');
const router = express.Router();

// Stripe webhook endpoint (needs raw body)
router.post('/', express.raw({ type: 'application/json' }), async (req, res) => {
  const sig = req.headers['stripe-signature'];
  
  try {
    // In production, verify with Stripe
    // const event = stripe.webhooks.constructEvent(req.body, sig, process.env.STRIPE_WEBHOOK_SECRET);
    const event = JSON.parse(req.body);

    switch (event.type) {
      case 'checkout.session.completed':
        console.log('Payment completed:', event.data.object);
        break;
      case 'customer.subscription.updated':
        console.log('Subscription updated:', event.data.object);
        break;
      case 'customer.subscription.deleted':
        console.log('Subscription cancelled:', event.data.object);
        break;
      case 'invoice.payment_succeeded':
        console.log('Invoice paid:', event.data.object);
        break;
      case 'invoice.payment_failed':
        console.log('Invoice failed:', event.data.object);
        break;
      default:
        console.log('Unhandled event:', event.type);
    }

    res.json({ received: true });
  } catch (err) {
    console.error('Webhook error:', err.message);
    res.status(400).send(`Webhook Error: ${err.message}`);
  }
});

module.exports = router;
