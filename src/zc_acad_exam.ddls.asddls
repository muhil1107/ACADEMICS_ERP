@EndUserText.label: 'Exam Consumption View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_ACAD_EXAM
  as projection on ZI_ACAD_EXAM
{
  key ExamUuid,
      ClassUuid,
      ExamDate,
      StudentId,
      StudentName,
      Marks,
      MarkStatus,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      _Class : redirected to parent ZC_ACAD_CLASS
}
