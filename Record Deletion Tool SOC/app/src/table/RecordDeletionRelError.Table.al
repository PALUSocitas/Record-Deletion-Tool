table 50501 "Record Deletion Rel. Error SOC"
{
    DataClassification = CustomerContent;
    DrillDownPageId = "Record Deletion Rel. Error SOC";
    LookupPageId = "Record Deletion Rel. Error SOC";
    fields
    {
        field(1; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(2; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(10; "Field No."; Integer)
        {
            Caption = 'Field No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11; "Field Name"; Text[30])
        {
            CalcFormula = Lookup(Field.FieldName where(TableNo = field("Table ID"), "No." = field("Field No.")));
            Caption = 'Field Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(20; "Error"; Text[250])
        {
            Caption = 'Error';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Table ID", "Entry No.")
        {
            Clustered = true;
        }
    }

}