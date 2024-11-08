-- Academic Performance Reports
CREATE PROCEDURE dbo.sp_academic_performance_report
    @school_id INT,
    @academic_year_id INT,
    @term_id INT = NULL
AS
BEGIN
    -- Overall Class Performance
    WITH ClassPerformance AS (
        SELECT 
            c.class_name,
            s.subject_name,
            COUNT(DISTINCT sa.student_id) as total_students,
            AVG(sa.score) as average_score,
            MIN(sa.score) as lowest_score,
            MAX(sa.score) as highest_score,
            COUNT(CASE WHEN sa.grade IN ('A+', 'A', 'A-') THEN 1 END) as distinctions,
            COUNT(CASE WHEN sa.grade IN ('F') THEN 1 END) as failures
        FROM dbo.student_assessments sa
        JOIN dbo.assessments a ON sa.assessment_id = a.assessment_id
        JOIN dbo.class_subjects cs ON a.class_subject_id = cs.class_subject_id
        JOIN dbo.classes c ON cs.class_id = c.class_id
        JOIN dbo.subjects s ON cs.subject_id = s.subject_id
        WHERE sa.school_id = @school_id
        AND c.academic_year_id = @academic_year_id
        AND (@term_id IS NULL OR a.term_id = @term_id)
        GROUP BY c.class_name, s.subject_name
    )
    SELECT * FROM ClassPerformance
    ORDER BY class_name, subject_name;
END;
GO

-- Student Progress Tracking
CREATE PROCEDURE dbo.sp_student_progress_report
    @school_id INT,
    @class_id INT,
    @academic_year_id INT
AS
BEGIN
    -- Track student performance over terms
    WITH StudentProgress AS (
        SELECT 
            s.admission_number,
            s.first_name + ' ' + s.last_name AS student_name,
            t.term_name,
            sub.subject_name,
            AVG(sa.score) as average_score,
            STRING_AGG(sa.grade, ', ') WITHIN GROUP (ORDER BY a.assessment_date) as grades
        FROM dbo.students s
        JOIN dbo.student_assessments sa ON s.student_id = sa.student_id
        JOIN dbo.assessments a ON sa.assessment_id = a.assessment_id
        JOIN dbo.terms t ON a.term_id = t.term_id
        JOIN dbo.class_subjects cs ON a.class_subject_id = cs.class_subject_id
        JOIN dbo.subjects sub ON cs.subject_id = sub.subject_id
        WHERE s.school_id = @school_id
        AND s.current_class_id = @class_id
        AND t.academic_year_id = @academic_year_id
        GROUP BY s.admission_number, s.first_name, s.last_name, 
                 t.term_name, sub.subject_name
    )
    SELECT * FROM StudentProgress
    PIVOT (
        AVG(average_score)
        FOR term_name IN ([Term 1], [Term 2], [Term 3])
    ) AS PivotTable;
END;
GO

-- Attendance Analytics
CREATE PROCEDURE dbo.sp_attendance_analytics_report
    @school_id INT,
    @academic_year_id INT,
    @class_id INT = NULL
AS
BEGIN
    -- Monthly attendance patterns
    SELECT 
        c.class_name,
        FORMAT(a.date, 'yyyy-MM') as month,
        COUNT(DISTINCT a.student_id) as total_students,
        SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) as attendance_rate,
        SUM(CASE WHEN a.status = 'Late' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) as late_rate,
        COUNT(DISTINCT CASE WHEN a.status = 'Absent' THEN a.student_id END) as students_with_absences
    FROM dbo.attendance a
    JOIN dbo.classes c ON a.class_id = c.class_id
    WHERE a.school_id = @school_id
    AND c.academic_year_id = @academic_year_id
    AND (@class_id IS NULL OR a.class_id = @class_id)
    GROUP BY c.class_name, FORMAT(a.date, 'yyyy-MM')
    ORDER BY c.class_name, FORMAT(a.date, 'yyyy-MM');
END;
GO

-- Financial Analytics
CREATE PROCEDURE dbo.sp_financial_analytics_report
    @school_id INT,
    @academic_year_id INT
AS
BEGIN
    -- Fee collection analysis
    WITH FeeSummary AS (
        SELECT 
            fc.category_name,
            c.class_name,
            COUNT(DISTINCT sf.student_id) as total_students,
            SUM(sf.amount_due) as total_due,
            SUM(sf.amount_paid) as total_collected,
            SUM(sf.late_fee_applied) as total_late_fees,
            SUM(sf.discount_applied) as total_discounts
        FROM dbo.student_fees sf
        JOIN dbo.fee_structures fs ON sf.structure_id = fs.structure_id
        JOIN dbo.fee_categories fc ON fs.category_id = fc.category_id
        JOIN dbo.students s ON sf.student_id = s.student_id
        JOIN dbo.classes c ON s.current_class_id = c.class_id
        WHERE sf.school_id = @school_id
        AND fs.academic_year_id = @academic_year_id
        GROUP BY fc.category_name, c.class_name
    )
    SELECT 
        category_name,
        class_name,
        total_students,
        total_due,
        total_collected,
        (total_collected * 100.0 / NULLIF(total_due, 0)) as collection_rate,
        total_late_fees,
        total_discounts
    FROM FeeSummary
    ORDER BY category_name, class_name;

    -- Payment trends
    SELECT 
        FORMAT(p.payment_date, 'yyyy-MM') as month,
        p.payment_method,
        COUNT(*) as transaction_count,
        SUM(p.amount) as total_amount
    FROM dbo.payments p
    WHERE p.school_id = @school_id
    AND p.payment_date >= (
        SELECT start_date 
        FROM dbo.academic_years 
        WHERE academic_year_id = @academic_year_id
    )
    GROUP BY FORMAT(p.payment_date, 'yyyy-MM'), p.payment_method
    ORDER BY FORMAT(p.payment_date, 'yyyy-MM');
END;
GO 