permissionset 50500 "RecDelPermissionsSOC"
{
    Assignable = true;
    Caption = 'Record Del. SOC Permissions', MaxLength = 30;
    Permissions =
        table "Record Deletion SOC" = X,
        tabledata "Record Deletion SOC" = RMID,
        table "Record Deletion Rel. Error SOC" = X,
        tabledata "Record Deletion Rel. Error SOC" = RMID,
        codeunit "Record Deletion Mgt. SOC" = X,
        page "Record Deletion SOC" = X,
        page "Record Deletion Rel. Error SOC" = X;
}
