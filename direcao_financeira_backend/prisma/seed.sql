INSERT INTO "Plan" (name, description, price, "durationDays", color, "isActive", "createdAt", "updatedAt") 
VALUES 
('Básico', 'Ideal para quem está começando a se organizar.', 0.0, 30, '#94a3b8', true, NOW(), NOW()),
('Prata', 'Recursos avançados para motoristas profissionais.', 29.9, 30, '#6366f1', true, NOW(), NOW()),
('Ouro', 'A experiência completa com suporte prioritário e todos os recursos.', 59.9, 30, '#f59e0b', true, NOW(), NOW())
ON CONFLICT (name) DO NOTHING;
