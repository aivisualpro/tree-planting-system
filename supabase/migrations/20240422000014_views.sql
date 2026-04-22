CREATE OR REPLACE VIEW v_visits_detail AS
SELECT 
  v.*,
  c.name_en AS country_name,
  ca.name_en AS core_area_name,
  a.name_en AS activity_name,
  (SELECT string_agg(ts.common_name_en, ', ') 
   FROM visit_trees vt 
   JOIN tree_species ts ON vt.tree_species_id = ts.id 
   WHERE vt.visit_id = v.id) AS planted_species,
  (SELECT count(*) FROM visit_media vm WHERE vm.visit_id = v.id) AS media_count
FROM visits v
JOIN countries c ON v.country_id = c.id
JOIN core_areas ca ON v.core_area_id = ca.id
JOIN activities a ON v.activity_id = a.id
WHERE v.deleted_at IS NULL;
