page 50501 "Record Deletion Rel. Error SOC"
{

    ApplicationArea = All;
    Caption = 'Record Deletion SOC Rel. Error';
    PageType = List;
    SourceTable = "Record Deletion Rel. Error SOC";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {

                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Entry No.';
                }
                field("Error"; Rec.Error)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the error text if an error occured';
                }
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Field Name';
                }
                field("Field No."; Rec."Field No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Field No.';
                }
                field("Table ID"; Rec."Table ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Table ID';
                }
            }
        }
    }

}
