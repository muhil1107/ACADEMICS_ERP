@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Class BO Interface View'
define root view entity ZI_ACAD_CLASS
  as select from zacad_class
  composition [0..*] of ZI_ACAD_EXAM as _Exam
{
  key class_uuid          as ClassUuid,
      class_id            as ClassId,
      course_name         as CourseName,
      faculty_id          as FacultyId,
      status              as Status,
      student_count       as StudentCount,
      pass_percentage     as PassPercentage,
      fail_percentage     as FailPercentage,
      
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      _Exam
}
