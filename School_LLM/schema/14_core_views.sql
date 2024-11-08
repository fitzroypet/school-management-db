-- Student Information View
CREATE VIEW dbo.vw_student_info AS
SELECT 
    s.school_id,
    s.student_id,
    s.admission_number,
    s.first_name + ' ' + s.last_name AS student_name,
    c.class_name,
    p.first_name + ' ' + p.last_name AS parent_name,
    p.phone_number AS parent_contact,
    s.status
FROM dbo.students s
LEFT JOIN dbo.classes c ON s.current_class_id = c.class_id
LEFT JOIN dbo.parents p ON s.parent_id = p.parent_id;
GO

-- Class Performance View
CREATE VIEW dbo.vw_class_performance AS
SELECT 
    sa.school_id,
    c.class_name,
    s.subject_name,
    ast.type_name AS assessment_type,
    COUNT(DISTINCT sa.student_id) AS total_students,
    AVG(sa.score) AS average_score,
    MIN(sa.score) AS minimum_score,
    MAX(sa.score) AS maximum_score
FROM dbo.student_assessments sa
JOIN dbo.assessments a ON sa.assessment_id = a.assessment_id
JOIN dbo.class_subjects cs ON a.class_subject_id = cs.class_subject_id
JOIN dbo.classes c ON cs.class_id = c.class_id
JOIN dbo.subjects s ON cs.subject_id = s.subject_id
JOIN dbo.assessment_types ast ON a.assessment_type_id = ast.assessment_type_id
GROUP BY sa.school_id, c.class_name, s.subject_name, ast.type_name;
GO

-- Fee Collection Status View
CREATE VIEW dbo.vw_fee_collection_status AS
SELECT 
    sf.school_id,
    c.class_name,
    fc.category_name AS fee_type,
    COUNT(DISTINCT sf.student_id) AS total_students,
    SUM(sf.amount_due) AS total_due,
    SUM(sf.amount_paid) AS total_collected,
    SUM(sf.amount_due - sf.amount_paid) AS total_pending
FROM dbo.student_fees sf
JOIN dbo.fee_structures fs ON sf.structure_id = fs.structure_id
JOIN dbo.fee_categories fc ON fs.category_id = fc.category_id
JOIN dbo.students s ON sf.student_id = s.student_id
JOIN dbo.classes c ON s.current_class_id = c.class_id
GROUP BY sf.school_id, c.class_name, fc.category_name;
GO 