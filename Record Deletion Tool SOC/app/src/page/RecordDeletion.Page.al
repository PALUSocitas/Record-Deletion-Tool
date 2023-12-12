page 50500 "Record Deletion SOC"
{

    ApplicationArea = All;
    Caption = 'Record Deletion SOC';
    PageType = List;
    SourceTable = "Record Deletion SOC";
    UsageCategory = Lists;
    //Permissions = tabledata 1432 = rimd;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Table ID"; Rec."Table ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table ID field.';
                }
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table Name field.';
                }
                field(NoOfRecords; RecordDeletionMgt.CalcRecordsInTable(Rec."Table ID"))
                {
                    ApplicationArea = All;
                    Caption = 'No. of Records';
                    ToolTip = 'Specifies the value of the CalcRecordsInTable(Rec.Table ID) field.';

                }
                field("No. of Table Relation Errors"; Rec."No. of Table Relation Errors")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. of Table Relation Errors field.';
                }
                field("Delete Records"; Rec."Delete Records")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delete Records field.';
                }
                // field(Company; Company)
                // {
                //     ApplicationArea = All;
                // }
            }
        }
    }
    actions
    {
        area(Navigation)
        {

        }
        area(Processing)
        {
            action(InsertUpdateTables)
            {
                ApplicationArea = All;
                Caption = 'Insert/Update Tables';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Executes the InsertUpdateTables action.';
                trigger OnAction()
                begin
                    RecordDeletionMgt.InsertUpdateTables();
                end;
            }
            action(SuggestsRecords)
            {
                ApplicationArea = All;
                Caption = 'Suggest Records to Delete';
                Image = Suggest;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Executes the SuggestsRecords action.';
                trigger OnAction()
                begin
                    RecordDeletionMgt.SuggestRecordsToDelete();
                end;
            }
            action(SuggestsUnlicensedPartnerOrCustomRecords)
            {
                ApplicationArea = All;
                Caption = 'Suggest Unlicensed Partner or Custom Records to Delete';
                Image = Suggest;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Executes the SuggestsUnlicensedPartnerOrCustomRecords action.';
                trigger OnAction()
                begin
                    RecordDeletionMgt.SuggestUnlicensedPartnerOrCustomRecordsToDelete();
                end;
            }
            action(ClearRecords)
            {
                ApplicationArea = All;
                Caption = 'Clear Records to Delete';
                Image = Delete;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Executes the ClearRecords action.';
                trigger OnAction()
                begin
                    RecordDeletionMgt.ClearRecordsToDelete();
                end;
            }
            action(DeleteRecords)
            {
                ApplicationArea = All;
                Caption = 'Delete Records (no trigger!)';
                Image = Delete;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Executes the DeleteRecords action.';
                trigger OnAction()
                begin
                    RecordDeletionMgt.DeleteRecords(false);
                end;
            }
            action(DeleteRecordsWithTrigger)
            {
                ApplicationArea = All;
                Caption = 'Delete Records (with trigger!)';
                Image = Delete;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Executes the DeleteRecordsWithTrigger action.';
                trigger OnAction()
                begin
                    RecordDeletionMgt.DeleteRecords(true);
                end;
            }
            action(CheckTableRelations)
            {
                ApplicationArea = All;
                Caption = 'Check Table Relations';
                Image = Relationship;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Executes the CheckTableRelations action.';
                trigger OnAction()
                begin
                    RecordDeletionMgt.CheckTableRelations();
                end;
            }
            action(ViewRecords)
            {
                ApplicationArea = All;
                Caption = 'View Records';
                Image = Table;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Executes the ViewRecords action.';
                trigger OnAction()
                begin
                    RecordDeletionMgt.ViewRecords(Rec);
                end;
            }
        }

    }
    var
        RecordDeletionMgt: Codeunit "Record Deletion Mgt. SOC";

}
