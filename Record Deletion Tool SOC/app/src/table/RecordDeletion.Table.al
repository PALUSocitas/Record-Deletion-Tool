table 50500 "Record Deletion SOC"
{
    DataClassification = CustomerContent;
    Permissions = tabledata "Table Metadata" = r;

    fields
    {
        field(1; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(10; "Table Name"; Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Name" where("Object Type" = const(Table), "Object ID" = field("Table ID")));
            Caption = 'Table Name';
            Editable = false;
            FieldClass = FlowField;
        }

        field(20; "No. of Records"; Integer)

        {
            Caption = 'No. of Records';
            Editable = false;
            //CalcFormula = lookup ("Table Information Cache"."No. of Records" where("Company Name" = field(Company), "Table No." = field("Table ID")));
            //CalcFormula = lookup ("Table Information"."No. of Records" where("Company Name" = field(Company), "Table No." = field("Table ID")));
        }
        field(21; "No. of Table Relation Errors"; Integer)
        {
            CalcFormula = Count("Record Deletion Rel. Error SOC" where("Table ID" = field("Table ID")));
            Caption = 'No. of Table Relation Errors';
            Editable = false;
            FieldClass = FlowField;
        }
        field(30; "Delete Records"; Boolean)
        {
            Caption = 'Delete Records';
            DataClassification = CustomerContent;
        }
        field(40; Company; Text[30])
        {
            Caption = 'Company';
            DataClassification = CustomerContent;
        }
        field(50; ErrorText; Text[50])
        {
            Caption = 'Error Text';
            Editable = false;
        }


    }

    keys
    {
        key(PK; "Table ID")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        Company := CopyStr(CompanyName, 1, MaxStrLen(Company));
    end;

}