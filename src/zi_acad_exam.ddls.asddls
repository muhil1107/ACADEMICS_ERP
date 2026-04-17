@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Exam BO Interface View'
define view entity ZI_ACAD_EXAM
  as select from zacad_exam
  association to parent ZI_ACAD_CLASS as _Class
    on $projection.ClassUuid = _Class.ClassUuid
{
  key exam_uuid           as ExamUuid,
      class_uuid          as ClassUuid,
      exam_date           as ExamDate,
      student_id          as StudentId,
      student_name        as StudentName,
      marks               as Marks,
      mark_status         as MarkStatus, 
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

      _Class
}
