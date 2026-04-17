@EndUserText.label: 'Class Consumption View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_ACAD_CLASS
  provider contract transactional_query
  as projection on ZI_ACAD_CLASS
{
  key ClassUuid,
      ClassId,
      CourseName,
      FacultyId,
      Status,
      StudentCount,
      PassPercentage,
      FailPercentage,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      _Exam : redirected to composition child ZC_ACAD_EXAM
}
