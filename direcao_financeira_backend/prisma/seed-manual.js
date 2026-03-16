require('dotenv').config();
const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Iniciando seed manual...');

  const plans = [
    {
      name: 'Básico',
      description: 'Ideal para quem está começando a se organizar.',
      price: 0.0,
      durationDays: 30,
      color: '#94a3b8',
      isActive: true,
    },
    {
      name: 'Prata',
      description: 'Recursos avançados para motoristas profissionais.',
      price: 29.9,
      durationDays: 30,
      color: '#6366f1',
      isActive: true,
    },
    {
      name: 'Ouro',
      description: 'A experiência completa com suporte prioritário e todos os recursos.',
      price: 59.9,
      durationDays: 30,
      color: '#f59e0b',
      isActive: true,
    },
  ];

  for (const plan of plans) {
    const result = await prisma.plan.upsert({
      where: { name: plan.name },
      update: {},
      create: plan,
    });
    console.log(`✅ Plano ${result.name} processado!`);
  }

  console.log('✅ Seed manual concluído!');
}

main()
  .catch((e) => {
    console.error('❌ Erro no seed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
