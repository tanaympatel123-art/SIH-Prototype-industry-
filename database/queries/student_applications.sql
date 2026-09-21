-- Query 3: Student Applications Pipeline & Timeline
-- SIH26044: Academia-Industry Collaboration Portal
-- Purpose: Student dashboard view showing all applied opportunities, company details, match scores, and status history timeline

SELECT 
    a.id AS application_id,
    o.id AS opportunity_id,
    o.title AS internship_title,
    o.work_mode,
    o.stipend,
    cp.company_name,
    cp.headquarters AS company_location,
    a.match_score,
    a.status AS current_status,
    a.applied_at,
    COALESCE(
        json_agg(
            json_build_object(
                'old_status', ash.old_status,
                'new_status', ash.new_status,
                'remarks', ash.remarks,
                'timestamp', ash.changed_at
            ) ORDER BY ash.changed_at ASC
        ) FILTER (WHERE ash.id IS NOT NULL),
        '[]'::json
    ) AS status_history_timeline
FROM applications a
JOIN opportunities o ON a.opportunity_id = o.id
JOIN company_profiles cp ON o.company_id = cp.id
JOIN student_profiles sp ON a.student_id = sp.id
JOIN users u ON sp.user_id = u.id
LEFT JOIN application_status_history ash ON ash.application_id = a.id
WHERE u.email = 'rahul.sharma@dtu.ac.in'
GROUP BY a.id, o.id, o.title, o.work_mode, o.stipend, cp.company_name, cp.headquarters, a.match_score, a.status, a.applied_at
ORDER BY a.applied_at DESC;
