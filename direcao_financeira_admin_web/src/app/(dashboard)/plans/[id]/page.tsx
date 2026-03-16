import { PlanForm } from '../plan-form';

interface PageProps {
  params: Promise<{
    id: string;
  }>;
}

export default async function EditPlanPage({ params }: PageProps) {
  const { id } = await params;

  return <PlanForm mode="edit" planId={Number(id)} />;
}
