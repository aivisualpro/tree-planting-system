-- profiles
CREATE POLICY "Users can select own profile" ON profiles FOR SELECT USING (id = auth.uid());
CREATE POLICY "Admins can select all profiles" ON profiles FOR SELECT USING (is_admin());
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (id = auth.uid()) WITH CHECK (id = auth.uid());
CREATE POLICY "Admins can update any profile" ON profiles FOR UPDATE USING (is_admin());

-- countries/masters
CREATE POLICY "Masters readable by authenticated" ON countries FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Masters modifiable by admin" ON countries FOR ALL USING (is_admin());

CREATE POLICY "Subwatersheds readable by authenticated" ON subwatersheds FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Subwatersheds modifiable by admin" ON subwatersheds FOR ALL USING (is_admin());

CREATE POLICY "Communities readable by authenticated" ON communities FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Communities modifiable by admin" ON communities FOR ALL USING (is_admin());

CREATE POLICY "Groups readable by authenticated" ON groups FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Groups modifiable by admin" ON groups FOR ALL USING (is_admin());

CREATE POLICY "Schools readable by authenticated" ON schools FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Schools modifiable by admin" ON schools FOR ALL USING (is_admin());

CREATE POLICY "Churches readable by authenticated" ON churches FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Churches modifiable by admin" ON churches FOR ALL USING (is_admin());

CREATE POLICY "Core areas readable by authenticated" ON core_areas FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Core areas modifiable by admin" ON core_areas FOR ALL USING (is_admin());

CREATE POLICY "Activities readable by authenticated" ON activities FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Activities modifiable by admin" ON activities FOR ALL USING (is_admin());

CREATE POLICY "Units readable by authenticated" ON units FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Units modifiable by admin" ON units FOR ALL USING (is_admin());

CREATE POLICY "Activity units readable by authenticated" ON activity_units FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Activity units modifiable by admin" ON activity_units FOR ALL USING (is_admin());

CREATE POLICY "Tree species readable by authenticated" ON tree_species FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Tree species modifiable by admin" ON tree_species FOR ALL USING (is_admin());

-- visits
CREATE POLICY "Visits select policy" ON visits FOR SELECT USING (
    created_by = auth.uid() OR
    has_country_access(country_id) OR
    (SELECT view_all_visits FROM profiles WHERE id = auth.uid()) = true
);
CREATE POLICY "Visits insert policy" ON visits FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Visits update policy" ON visits FOR UPDATE USING (
    created_by = auth.uid() OR has_country_access(country_id)
);
CREATE POLICY "Visits delete policy" ON visits FOR DELETE USING (is_admin() AND has_country_access(country_id));

-- visit_trees
CREATE POLICY "Visit trees select policy" ON visit_trees FOR SELECT USING (
    EXISTS (SELECT 1 FROM visits WHERE visits.id = visit_trees.visit_id)
);
CREATE POLICY "Visit trees insert policy" ON visit_trees FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM visits WHERE visits.id = visit_trees.visit_id AND (visits.created_by = auth.uid() OR has_country_access(visits.country_id)))
);
CREATE POLICY "Visit trees update policy" ON visit_trees FOR UPDATE USING (
    EXISTS (SELECT 1 FROM visits WHERE visits.id = visit_trees.visit_id AND (visits.created_by = auth.uid() OR has_country_access(visits.country_id)))
);
CREATE POLICY "Visit trees delete policy" ON visit_trees FOR DELETE USING (
    EXISTS (SELECT 1 FROM visits WHERE visits.id = visit_trees.visit_id AND (visits.created_by = auth.uid() OR has_country_access(visits.country_id)))
);

-- visit_media
CREATE POLICY "Visit media select policy" ON visit_media FOR SELECT USING (
    EXISTS (SELECT 1 FROM visits WHERE visits.id = visit_media.visit_id)
);
CREATE POLICY "Visit media insert policy" ON visit_media FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM visits WHERE visits.id = visit_media.visit_id AND (visits.created_by = auth.uid() OR has_country_access(visits.country_id)))
);
CREATE POLICY "Visit media update policy" ON visit_media FOR UPDATE USING (
    EXISTS (SELECT 1 FROM visits WHERE visits.id = visit_media.visit_id AND (visits.created_by = auth.uid() OR has_country_access(visits.country_id)))
);
CREATE POLICY "Visit media delete policy" ON visit_media FOR DELETE USING (
    EXISTS (SELECT 1 FROM visits WHERE visits.id = visit_media.visit_id AND (visits.created_by = auth.uid() OR has_country_access(visits.country_id)))
);

-- translations
CREATE POLICY "Translations select policy" ON translations FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Translations all policy" ON translations FOR ALL USING (is_admin());

-- audit_log
CREATE POLICY "Audit log select admin" ON audit_log FOR SELECT USING (is_admin());

-- sync_log
CREATE POLICY "Sync log insert auth" ON sync_log FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "Sync log select" ON sync_log FOR SELECT USING (user_id = auth.uid() OR is_admin());
