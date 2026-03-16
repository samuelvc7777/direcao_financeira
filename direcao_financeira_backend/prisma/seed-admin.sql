INSERT INTO "User" (email, password, name, role, "isActive", "createdAt", "updatedAt") 
VALUES 
('admin@admin.com', '$2b$10$7R9r2iG0q/5O9nN630H3i.6l6R6l6R6l6R6l6R6l6R6l6R6l6R6l6', 'Administrador', 'ADMIN', true, NOW(), NOW())
ON CONFLICT (email) DO NOTHING;
