const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Seeding database...');

  // Create Plans
  const freePlan = await prisma.plan.upsert({
    where: { slug: 'free' },
    update: {},
    create: {
      name: 'FREE',
      slug: 'free',
      description: 'Plano gratuito com funcionalidades básicas',
      priceMonthly: 0,
      priceYearly: 0,
      maxAnalyses: 20,
      features: JSON.stringify([
        'Dashboard básico',
        'Meta diária simples',
        'Cálculo manual de lucro/km',
        'Histórico limitado (7 dias)',
        'Máximo 20 análises/dia'
      ]),
      badge: null,
    },
  });

  const proPlan = await prisma.plan.upsert({
    where: { slug: 'pro' },
    update: {},
    create: {
      name: 'PRO',
      slug: 'pro',
      description: 'Overlay em tempo real + IA de metas',
      priceMonthly: 19.90,
      priceYearly: 197.00,
      maxAnalyses: null,
      features: JSON.stringify([
        'Overlay em tempo real',
        'Leitura automática de corridas',
        'Análise inteligente',
        'IA de metas',
        'Dashboard premium',
        'Estatísticas completas',
        'Histórico ilimitado',
        'Insights inteligentes',
        'Regiões lucrativas',
        'Melhor horário para rodar',
        'Notificações inteligentes'
      ]),
      badge: 'Mais popular',
      stripePriceMonthly: process.env.STRIPE_PRO_PRICE_MONTHLY || null,
      stripePriceYearly: process.env.STRIPE_PRO_PRICE_YEARLY || null,
    },
  });

  const premiumPlan = await prisma.plan.upsert({
    where: { slug: 'premium' },
    update: {},
    create: {
      name: 'PREMIUM',
      slug: 'premium',
      description: 'IA avançada preditiva + Heatmap + Relatórios',
      priceMonthly: 49.90,
      priceYearly: 497.00,
      maxAnalyses: null,
      features: JSON.stringify([
        'Tudo do PRO',
        'IA avançada preditiva',
        'Heatmap em tempo real',
        'Estratégia automática',
        'Análise profunda de lucro',
        'Relatórios avançados',
        'Comparativos mensais',
        'Multi veículos',
        'Prioridade no suporte',
        'Recursos beta exclusivos'
      ]),
      badge: 'Máximo desempenho',
      stripePriceMonthly: process.env.STRIPE_PREMIUM_PRICE_MONTHLY || null,
      stripePriceYearly: process.env.STRIPE_PREMIUM_PRICE_YEARLY || null,
    },
  });

  // Create Admin User
  const hashedPassword = await bcrypt.hash(process.env.ADMIN_PASSWORD || 'Admin@123', 12);
  
  const admin = await prisma.user.upsert({
    where: { email: process.env.ADMIN_EMAIL || 'admin@driverai.com' },
    update: {},
    create: {
      name: 'Admin',
      email: process.env.ADMIN_EMAIL || 'admin@driverai.com',
      password: hashedPassword,
      role: 'ADMIN',
      city: 'São Paulo',
      platform: 'UBER',
    },
  });

  console.log('✅ Plans created:', { freePlan: freePlan.id, proPlan: proPlan.id, premiumPlan: premiumPlan.id });
  console.log('✅ Admin created:', admin.email);
  console.log('🎉 Seeding completed!');
}

main()
  .catch((e) => {
    console.error('❌ Seed error:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
