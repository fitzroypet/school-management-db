-- Generate Student Report Card
CREATE PROCEDURE dbo.sp_generate_report_card
    @school_id INT,
    @student_id INT,
    @term_id INT
AS
BEGIN
    -- Get Student Info
    SELECT 
        s.admission_number,
        s.first_name + ' ' + s.last_name AS student_name,
        c.class_name,
        t.term_name,
        ay.year_name AS academic_year
    FROM dbo.students s
    JOIN dbo.classes c ON s.current_class_id = c.class_id
    JOIN dbo.terms t ON t.term_id = @term_id
    JOIN dbo.academic_years ay ON t.academic_year_id = ay.academic_year_id
    WHERE s.school_id = @school_id AND s.student_id = @student_id;

    -- Get Assessment Results
    SELECT 
        sub.subject_name,
        ast.type_name AS assessment_type,
        sa.score,
        sa.grade,
        ast.weight_percentage,
        sa.remarks
    FROM dbo.student_assessments sa
    JOIN dbo.assessments a ON sa.assessment_id = a.assessment_id
    JOIN dbo.assessment_types ast ON a.assessment_type_id = ast.assessment_type_id
    JOIN dbo.class_subjects cs ON a.class_subject_id = cs.class_subject_id
    JOIN dbo.subjects sub ON cs.subject_id = sub.subject_id
    WHERE sa.school_id = @school_id 
    AND sa.student_id = @student_id
    AND a.term_id = @term_id;

    -- Get Attendance Summary
    SELECT
        COUNT(*) AS total_school_days,
        SUM(CASE WHEN status = 'Present' THEN 1 ELSE 0 END) AS days_present,
        SUM(CASE WHEN status = 'Absent' THEN 1 ELSE 0 END) AS days_absent
    FROM dbo.attendance
    WHERE school_id = @school_id 
    AND student_id = @student_id
    AND date BETWEEN (SELECT start_date FROM dbo.terms WHERE term_id = @term_id)
    AND (SELECT end_date FROM dbo.terms WHERE term_id = @term_id);
END;
GO 