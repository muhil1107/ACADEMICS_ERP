CLASS lhc_class DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Class RESULT result.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Class RESULT result.

    METHODS lockclass FOR MODIFY
      IMPORTING keys FOR ACTION Class~lockClass RESULT result.

    METHODS unlockclass FOR MODIFY
      IMPORTING keys FOR ACTION Class~unlockClass RESULT result.

    METHODS setDefaultStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Class~setDefaultStatus.

ENDCLASS.

CLASS lhc_class IMPLEMENTATION.

  METHOD get_global_authorizations.
    IF requested_authorizations-%create = if_abap_behv=>mk-on.
      result-%create = if_abap_behv=>auth-allowed.
    ENDIF.
    IF requested_authorizations-%update = if_abap_behv=>mk-on.
      result-%update = if_abap_behv=>auth-allowed.
    ENDIF.
    IF requested_authorizations-%delete = if_abap_behv=>mk-on.
      result-%delete = if_abap_behv=>auth-allowed.
    ENDIF.
    IF requested_authorizations-%action-lockClass = if_abap_behv=>mk-on.
      result-%action-lockClass = if_abap_behv=>auth-allowed.
    ENDIF.
    IF requested_authorizations-%action-unlockClass = if_abap_behv=>mk-on.
      result-%action-unlockClass = if_abap_behv=>auth-allowed.
    ENDIF.
  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF zi_acad_class IN LOCAL MODE
      ENTITY Class FIELDS ( Status ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_classes).

    result = VALUE #( FOR ls_class IN lt_classes
                      ( %tky = ls_class-%tky
                        %update             = COND #( WHEN ls_class-Status = 'L' THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
                        %delete             = COND #( WHEN ls_class-Status = 'L' THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
                        %action-lockClass   = COND #( WHEN ls_class-Status = 'L' THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
                        %action-unlockClass = COND #( WHEN ls_class-Status = 'L' THEN if_abap_behv=>fc-o-enabled ELSE if_abap_behv=>fc-o-disabled )
                      ) ).
  ENDMETHOD.

  METHOD lockclass.
    READ ENTITIES OF zi_acad_class IN LOCAL MODE
      ENTITY Class FIELDS ( ClassUuid Status ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_classes).

    DATA lt_update TYPE TABLE FOR UPDATE zi_acad_class\\Class.

    LOOP AT lt_classes INTO DATA(ls_class).
      IF ls_class-Status <> 'L'.
        APPEND VALUE #( %tky = ls_class-%tky Status = 'L' %control = VALUE #( Status = if_abap_behv=>mk-on ) ) TO lt_update.
      ENDIF.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zi_acad_class IN LOCAL MODE
        ENTITY Class UPDATE FIELDS ( Status ) WITH lt_update.
    ENDIF.

    READ ENTITIES OF zi_acad_class IN LOCAL MODE
      ENTITY Class ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_result).

    result = VALUE #( FOR ls_res IN lt_result ( %tky = ls_res-%tky %param = ls_res ) ).
  ENDMETHOD.

  METHOD unlockclass.
    READ ENTITIES OF zi_acad_class IN LOCAL MODE
      ENTITY Class FIELDS ( ClassUuid Status ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_classes).

    DATA lt_update TYPE TABLE FOR UPDATE zi_acad_class\\Class.

    LOOP AT lt_classes INTO DATA(ls_class).
      IF ls_class-Status = 'L'.
        APPEND VALUE #( %tky = ls_class-%tky Status = 'O' %control = VALUE #( Status = if_abap_behv=>mk-on ) ) TO lt_update.
      ENDIF.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zi_acad_class IN LOCAL MODE
        ENTITY Class UPDATE FIELDS ( Status ) WITH lt_update.
    ENDIF.

    READ ENTITIES OF zi_acad_class IN LOCAL MODE
      ENTITY Class ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_result).

    result = VALUE #( FOR ls_res IN lt_result ( %tky = ls_res-%tky %param = ls_res ) ).
  ENDMETHOD.

  METHOD setDefaultStatus.
    READ ENTITIES OF zi_acad_class IN LOCAL MODE
      ENTITY Class FIELDS ( Status ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_classes).

    DATA lt_update TYPE TABLE FOR UPDATE zi_acad_class\\Class.

    LOOP AT lt_classes INTO DATA(ls_class).
      IF ls_class-Status IS INITIAL.
        APPEND VALUE #( %tky = ls_class-%tky Status = 'O' %control = VALUE #( Status = if_abap_behv=>mk-on ) ) TO lt_update.
      ENDIF.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zi_acad_class IN LOCAL MODE
        ENTITY Class UPDATE FIELDS ( Status ) WITH lt_update.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_exam DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Exam RESULT result.

    METHODS validateRules FOR VALIDATE ON SAVE
      IMPORTING keys FOR Exam~validateRules.

    METHODS calculatePercentages FOR DETERMINE ON SAVE
      IMPORTING keys FOR Exam~calculatePercentages.

    " NEW: Method to determine Pass/Fail Status
    METHODS determineMarkStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Exam~determineMarkStatus.

ENDCLASS.

CLASS lhc_exam IMPLEMENTATION.

  METHOD get_instance_features.
    READ ENTITIES OF zi_acad_class IN LOCAL MODE
      ENTITY Exam BY \_Class FIELDS ( Status ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_classes).

    DATA(lv_parent_locked) = COND #( WHEN line_exists( lt_classes[ Status = 'L' ] )
                                     THEN if_abap_behv=>fc-o-disabled
                                     ELSE if_abap_behv=>fc-o-enabled ).

    result = VALUE #( FOR key IN keys
                      ( %tky = key-%tky %update = lv_parent_locked %delete = lv_parent_locked ) ).
  ENDMETHOD.

  METHOD validateRules.
    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).

    READ ENTITIES OF zi_acad_class IN LOCAL MODE
      ENTITY Exam FIELDS ( ExamUuid Marks ExamDate ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_exam).

    LOOP AT lt_exam INTO DATA(ls_exam).
      IF ls_exam-Marks < 0 OR ls_exam-Marks > 100.
        APPEND VALUE #( %tky = ls_exam-%tky ) TO failed-exam.
        APPEND VALUE #( %tky = ls_exam-%tky %state_area = 'VALIDATE_MARKS'
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = 'Marks must be between 0 and 100' )
                        %element-Marks = if_abap_behv=>mk-on ) TO reported-exam.
      ENDIF.

      IF ls_exam-ExamDate > lv_today AND ls_exam-ExamDate IS NOT INITIAL.
        APPEND VALUE #( %tky = ls_exam-%tky ) TO failed-exam.
        APPEND VALUE #( %tky = ls_exam-%tky %state_area = 'VALIDATE_DATE'
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = 'Exam date cannot be in the future' )
                        %element-ExamDate = if_abap_behv=>mk-on ) TO reported-exam.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD calculatePercentages.
    READ ENTITIES OF zi_acad_class IN LOCAL MODE
      ENTITY Exam BY \_Class FIELDS ( ClassUuid ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_classes).

    SORT lt_classes BY ClassUuid.
    DELETE ADJACENT DUPLICATES FROM lt_classes COMPARING ClassUuid.

    LOOP AT lt_classes INTO DATA(ls_class).
      READ ENTITIES OF zi_acad_class IN LOCAL MODE
        ENTITY Class BY \_Exam FIELDS ( Marks ) WITH VALUE #( ( %tky = ls_class-%tky ) )
        RESULT DATA(lt_exams).

      DATA: lv_total TYPE f, lv_passed TYPE f, lv_failed TYPE f.
      lv_total = lines( lt_exams ).
      lv_passed = 0.
      lv_failed = 0.

      IF lv_total > 0.
        LOOP AT lt_exams INTO DATA(ls_exam).
          IF ls_exam-Marks >= 35. lv_passed = lv_passed + 1. ELSE. lv_failed = lv_failed + 1. ENDIF.
        ENDLOOP.
        DATA(lv_pass_pct) = ( lv_passed / lv_total ) * 100.
        DATA(lv_fail_pct) = ( lv_failed / lv_total ) * 100.
      ELSE.
        lv_pass_pct = 0. lv_fail_pct = 0.
      ENDIF.

      MODIFY ENTITIES OF zi_acad_class IN LOCAL MODE
        ENTITY Class UPDATE FIELDS ( PassPercentage FailPercentage StudentCount ) " <--- ADDED HERE
        WITH VALUE #( ( %tky           = ls_class-%tky
                        PassPercentage = lv_pass_pct
                        FailPercentage = lv_fail_pct
                        StudentCount   = lv_total ) ).
    ENDLOOP.
  ENDMETHOD.

  " --- NEW LOGIC: Calculate 'Pass' or 'Fail' Text ---
  METHOD determineMarkStatus.
    READ ENTITIES OF zi_acad_class IN LOCAL MODE
      ENTITY Exam FIELDS ( Marks ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_exams).

    DATA lt_update TYPE TABLE FOR UPDATE zi_acad_class\\Exam.

    LOOP AT lt_exams INTO DATA(ls_exam).
      DATA(lv_status_text) = COND string( WHEN ls_exam-Marks >= 35 THEN 'Pass' ELSE 'Fail' ).

      APPEND VALUE #( %tky = ls_exam-%tky
                      MarkStatus = lv_status_text
                      %control = VALUE #( MarkStatus = if_abap_behv=>mk-on ) ) TO lt_update.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zi_acad_class IN LOCAL MODE
        ENTITY Exam UPDATE FIELDS ( MarkStatus ) WITH lt_update.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
