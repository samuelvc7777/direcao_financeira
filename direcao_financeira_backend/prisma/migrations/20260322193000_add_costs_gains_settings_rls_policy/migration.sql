CREATE POLICY "costs_gains_settings_own_rows"
ON "CostsGainsSettings"
FOR ALL
TO authenticated
USING ("userId" = current_app_user_id())
WITH CHECK ("userId" = current_app_user_id());
