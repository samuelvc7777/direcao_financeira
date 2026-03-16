import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('Iniciando seed de planos...');

  const plans = [
    {
      code: 'BASICO',
      name: 'Basico',
      description: 'Ideal para quem esta comecando a se organizar.',
      priceCents: 0,
      durationDays: 30,
      color: '#94a3b8',
      isActive: true,
    },
    {
      code: 'PRATA',
      name: 'Prata',
      description: 'Recursos avancados para motoristas profissionais.',
      priceCents: 2990,
      durationDays: 30,
      color: '#6366f1',
      isActive: true,
    },
    {
      code: 'OURO',
      name: 'Ouro',
      description:
        'A experiencia completa com suporte prioritario e todos os recursos.',
      priceCents: 5990,
      durationDays: 30,
      color: '#f59e0b',
      isActive: true,
    },
  ];

  for (const plan of plans) {
    await prisma.plan.upsert({
      where: { code: plan.code },
      update: {
        name: plan.name,
        description: plan.description,
        priceCents: plan.priceCents,
        durationDays: plan.durationDays,
        color: plan.color,
        isActive: plan.isActive,
      },
      create: plan,
    });
  }

  console.log('Seed de planos concluido!');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
