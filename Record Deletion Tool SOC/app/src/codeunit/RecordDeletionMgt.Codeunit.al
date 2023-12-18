codeunit 50500 "Record Deletion Mgt. SOC"
{
    Permissions =
    tabledata "G/L Entry" = IMD,
    tabledata "Cust. Ledger Entry" = IMD,
    tabledata "Vendor Ledger Entry" = IMD,
    tabledata "Item Ledger Entry" = IMD,
    tabledata "Sales Header" = IMD,
    tabledata "Sales Line" = IMD,
    tabledata "Purchase Header" = IMD,
    tabledata "Purchase Line" = IMD,
    tabledata "G/L Register" = IMD,
    tabledata "Item Register" = IMD,
    tabledata "Gen. Journal Line" = IMD,
    tabledata "Sales Shipment Header" = IMD,
    tabledata "Sales Shipment Line" = IMD,
    tabledata "Sales Invoice Header" = IMD,
    tabledata "Sales Invoice Line" = IMD,
    tabledata "Sales Cr.Memo Header" = IMD,
    tabledata "Sales Cr.Memo Line" = IMD,
    tabledata "Purch. Rcpt. Header" = IMD,
    tabledata "Purch. Rcpt. Line" = IMD,
    tabledata "Purch. Inv. Header" = IMD,
    tabledata "Purch. Inv. Line" = IMD,
    tabledata "Purch. Cr. Memo Hdr." = IMD,
    tabledata "Purch. Cr. Memo Line" = IMD,
    tabledata "Job Ledger Entry" = IMD,
    tabledata "Res. Ledger Entry" = IMD,
    tabledata "G/L Entry - VAT Entry Link" = IMD,
    tabledata "VAT Entry" = IMD,
    tabledata "Bank Account Ledger Entry" = IMD,
    tabledata "Phys. Inventory Ledger Entry" = IMD,
    tabledata "Issued Reminder Line" = IMD,
    tabledata "Reminder/Fin. Charge Entry" = IMD,
    tabledata "Issued Fin. Charge Memo Line" = IMD,
    tabledata "Reservation Entry" = IMD,
    tabledata "Item Application Entry" = IMD,
    tabledata "Detailed Cust. Ledg. Entry" = IMD,
    tabledata "Detailed Vendor Ledg. Entry" = IMD,
    tabledata "Change Log Entry" = IMD,
    tabledata "Job Queue Log Entry" = IMD,
    tabledata "VAT Rate Change Log Entry" = IMD,
    tabledata "Value Entry" = IMD,
    tabledata "Return Shipment Header" = IMD,
    tabledata "Return Receipt Header" = IMD,
    tabledata "Exch. Rate Adjmt. Reg." = IMD,
    tabledata "Date Compr. Register" = IMD,
    tabledata "Resource Register" = IMD,
    tabledata "Job Register" = IMD,
    tabledata "Check Ledger Entry" = IMD,
    tabledata "Bank Acc. Reconciliation Line" = IMD,
    tabledata "Bank Account Statement Line" = IMD,
    tabledata "Issued Reminder Header" = IMD,
    tabledata "Issued Fin. Charge Memo Header" = IMD,
    tabledata "No. Series Line" = IMD,
    tabledata "IC Outbox Sales Line" = IMD,
    tabledata "Dimension Set ID Filter Line" = IMD,
    tabledata "Dim. Value per Account" = IMD,
    tabledata "Gen. Jnl. Dim. Filter" = IMD,
    tabledata "Analysis by Dim. Parameters" = IMD,
    tabledata "Selected Dimension" = IMD,
    tabledata "Dimension Translation" = IMD,
    tabledata "Handled IC Inbox Jnl. Line" = IMD,
    tabledata "IC Document Dimension" = IMD,
    tabledata "Interaction Merge Data" = IMD,
    tabledata "Sales Header Archive" = IMD,
    tabledata "Sales Line Archive" = IMD,
    tabledata "Purchase Header Archive" = IMD,
    tabledata "Purchase Line Archive" = IMD,
    tabledata "Return Shipment Line" = IMD,
    tabledata "Return Receipt Line" = IMD,
    tabledata "Analysis Selected Dimension" = IMD,
    tabledata "Warehouse Receipt Header" = IMD,
    tabledata "Warehouse Receipt Line" = IMD,
    tabledata "Posted Whse. Receipt Header" = IMD,
    tabledata "Posted Whse. Receipt Line" = IMD,
    tabledata "Warehouse Shipment Header" = IMD,
    tabledata "Warehouse Shipment Line" = IMD,
    tabledata "Posted Whse. Shipment Header" = IMD,
    tabledata "Posted Whse. Shipment Line" = IMD,
    tabledata "Posted Invt. Put-away Header" = IMD,
    tabledata "Posted Invt. Put-away Line" = IMD,
    tabledata "Posted Invt. Pick Header" = IMD,
    tabledata "Posted Invt. Pick Line" = IMD;

    procedure CalcRecordsInTable(TableNoToCheck: Integer): Integer
    var
        field: Record Field;
        TableMetadata: Record "Table Metadata";
        RecordRef: RecordRef;
        NoOfRecords: Integer;
    begin

        field.SetRange(TableNo, TableNoToCheck);
        if not field.IsEmpty() then begin
            RecordRef.Open(TableNoToCheck);
            If TableMetadata.Get(TableNoToCheck) then begin
                RecordRef.LockTable();
                NoOfRecords := RecordRef.Count();
            end;
            RecordRef.Close();
            exit(NoOfRecords);
        end;
        exit(0);
    end;

    procedure CheckForErrors(var RecordDeletion: Record "Record Deletion SOC"): Text[50]
    var
        field: Record Field;
        TableMetadata: Record "Table Metadata";
        RecordRef: RecordRef;
        //AbnormalErr: Label 'Table not of Type "Normal"';
        PermissionErr: Label 'Permission Missing';
    begin
        field.SetRange(TableNo, RecordDeletion."Table ID");
        if not field.IsEmpty() then begin
            RecordRef.Open(RecordDeletion."Table ID");
            If TableMetadata.Get(RecordDeletion."Table ID") then
                if not (RecordRef.ReadPermission) then
                    exit(PermissionErr);
            // if not (TableMetadata.TableType = TableMetadata.TableType::Normal) then
            //     exit(AbnormalErr);
        end;
        RecordRef.Close();
        exit('');
    end;

    procedure CheckTableRelations()
    var
        Field: Record Field;
        Field2: Record Field;
        KeyRec: Record "Key";
        RecordDeletionRelError: Record "Record Deletion Rel. Error SOC";
        RecordDeletion: Record "Record Deletion SOC";
        TableMetadata: Record "Table Metadata";
        RecordRef: RecordRef;
        RecordRef2: RecordRef;
        FieldRef: FieldRef;
        FieldRef2: FieldRef;
        SkipCheck: Boolean;
        UpdateDialog: Dialog;
        EntryNo: Integer;
        CheckingRelationsTxt: Label 'Checking Relations Between Records!\Table: #1#######', Comment = '%1 = Table ID';
        CheckRelationsQst: Label 'Check Table Relations?';
        NotExistsTxt: Label '%1 => %2 = ''%3'' does not exist in the ''%4'' table', Comment = '%1 = RecRef Position, %2 = FieldRef Name, %3 = FieldRef Value, %4 = Record Ref Name';
    begin
        if not Confirm(CheckRelationsQst, false) then
            exit;

        UpdateDialog.Open(CheckingRelationsTxt);

        RecordDeletionRelError.DeleteAll();

        if RecordDeletion.FindSet() then
            repeat
                UpdateDialog.Update(1, Format(RecordDeletion."Table ID"));
                // Only allow "normal" tables to avoid errors, Skip TableType MicrosoftGraph and CRM etc.
                TableMetadata.SetRange(ID, RecordDeletion."Table ID");
                TableMetadata.SetRange(TableType, TableMetadata.TableType::Normal);
                if not TableMetadata.IsEmpty() then begin
                    RecordRef.Open(RecordDeletion."Table ID");
                    if RecordRef.FindSet() then
                        repeat
                            Field.SetRange(TableNo, RecordDeletion."Table ID");
                            Field.SetRange(Class, Field.Class::Normal);
                            Field.SetFilter(RelationTableNo, '<>0');
                            if Field.FindSet() then
                                repeat
                                    FieldRef := RecordRef.Field(Field."No.");
                                    if (Format(FieldRef.Value) <> '') and (Format(FieldRef.Value) <> '0') then begin
                                        RecordRef2.Open(Field.RelationTableNo);
                                        SkipCheck := false;
                                        if Field.RelationFieldNo <> 0 then
                                            FieldRef2 := RecordRef2.Field(Field.RelationFieldNo)
                                        else begin
                                            KeyRec.Get(Field.RelationTableNo, 1);  // PK
                                            Field2.SetRange(TableNo, Field.RelationTableNo);
                                            Field2.SetFilter(FieldName, CopyStr(KeyRec.Key, 1, 30));
                                            if Field2.FindFirst() then // No Match if Dual PK
                                                FieldRef2 := RecordRef2.Field(Field2."No.")
                                            else
                                                SkipCheck := true;
                                        end;
                                        if (FieldRef.Type = FieldRef2.Type) and (FieldRef.Length = FieldRef2.Length) and (not SkipCheck) then begin
                                            FieldRef2.SetRange(FieldRef.Value);
                                            if not RecordRef2.FindFirst() then begin
                                                RecordDeletionRelError.SetRange("Table ID", RecordRef.Number);
                                                if RecordDeletionRelError.FindLast() then
                                                    EntryNo := RecordDeletionRelError."Entry No." + 1
                                                else
                                                    EntryNo := 1;
                                                RecordDeletionRelError.Init();
                                                RecordDeletionRelError."Table ID" := RecordRef.Number;
                                                RecordDeletionRelError."Entry No." := EntryNo;
                                                RecordDeletionRelError."Field No." := FieldRef.Number;
                                                RecordDeletionRelError.Error := CopyStr(StrSubstNo(NotExistsTxt, Format(RecordRef.GetPosition()), Format(FieldRef2.Name), Format(FieldRef.Value), Format(RecordRef2.Name)), 1, 250);
                                                RecordDeletionRelError.Insert();
                                            end;
                                        end;
                                        RecordRef2.Close();
                                    end;
                                until Field.Next() = 0;
                        until RecordRef.Next() = 0;
                    RecordRef.Close();
                end;
            until RecordDeletion.Next() = 0;
        UpdateDialog.Close();
    end;

    procedure ClearRecordsToDelete()
    var
        RecordDeletion: Record "Record Deletion SOC";
    begin
        RecordDeletion.ModifyAll("Delete Records", false);
    end;

    procedure DeleteRecords(RunTrigger: Boolean)
    var
        RecordDeletionRelError: Record "Record Deletion Rel. Error SOC";
        RecordDeletion: Record "Record Deletion SOC";
        RecordRef: RecordRef;
        UpdateDialog: Dialog;
        DeleteRecordsQst: Label 'Delete Records with RunTrigger = false?';
        DeleteRecordsWithTriggerQst: Label 'Delete Records with RunTrigger = true?';
        DeletingRecordsTxt: Label 'Deleting Records!\Table: #1#######', Comment = '%1 = Table ID';
    begin
        if RunTrigger then begin
            if not Confirm(DeleteRecordsWithTriggerQst, false) then
                exit;
#pragma warning disable AA0005
        end else begin
            if not Confirm(DeleteRecordsQst, false) then
                exit;
        end;
#pragma warning restore AA0005

        UpdateDialog.Open(DeletingRecordsTxt);

        if RecordDeletion.FindSet() then
            repeat
                if RecordDeletion."Delete Records" then begin
                    UpdateDialog.Update(1, Format(RecordDeletion."Table ID"));
                    RecordRef.Open(RecordDeletion."Table ID");
                    RecordRef.DeleteAll(RunTrigger);
                    RecordRef.Close();
                    RecordDeletionRelError.SetRange("Table ID", RecordDeletion."Table ID");
                    RecordDeletionRelError.DeleteAll();
                end;
            until RecordDeletion.Next() = 0;

        UpdateDialog.Close();
    end;

    procedure InsertUpdateTables()
    var
        AllObjWithCaption: Record AllObjWithCaption;
        RecordDeletion: Record "Record Deletion SOC";
        TableMetadata: Record "Table Metadata";
    begin
        RecordDeletion.DeleteAll();
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Table);
        // Do not include system tables
        AllObjWithCaption.SetFilter("Object ID", '<%1&<>%2', 2000000001, 1432);
        if AllObjWithCaption.FindSet() then
            repeat
                if TableMetadata.Get(AllObjWithCaption."Object ID") then
                    if TableMetadata.TableType = TableMetadata.TableType::Normal then begin
                        RecordDeletion.Init();
                        RecordDeletion."Table ID" := AllObjWithCaption."Object ID";
                        RecordDeletion.Company := CopyStr(CompanyName, 1, MaxStrLen(RecordDeletion.Company));
                        RecordDeletion.ErrorText := CheckForErrors(RecordDeletion);
                        if RecordDeletion.Insert() then;
                    end;
            until AllObjWithCaption.Next() = 0;

    end;

    procedure SetSuggestedTable(TableID: Integer)
    var
        RecordDeletion: Record "Record Deletion SOC";
    begin
        if RecordDeletion.Get(TableID) then begin
            RecordDeletion."Delete Records" := true;
            RecordDeletion.Modify();
        end;
    end;

    procedure SuggestRecordsToDelete()
    var
        RecordDeletion: Record "Record Deletion SOC";
        AfterSuggestionDeleteCount: Integer;
        BeforeSuggestionDeleteCount: Integer;
        RecordsWereSuggestedMsg: Label '%1 records to delete were suggested.', Comment = '%1 = number of suggested records';
    begin
        RecordDeletion.SetRange("Delete Records", true);
        BeforeSuggestionDeleteCount := RecordDeletion.Count();

        SetSuggestedTable(Database::"Action Message Entry");
        SetSuggestedTable(Database::"Analysis View Budget Entry");
        SetSuggestedTable(Database::"Analysis View Entry");
        SetSuggestedTable(Database::"Analysis View");
        SetSuggestedTable(Database::"Approval Comment Line");
        SetSuggestedTable(Database::"Approval Entry");
        SetSuggestedTable(Database::"Assemble-to-Order Link");
        SetSuggestedTable(Database::"Assembly Comment Line");
        SetSuggestedTable(Database::"Assembly Header");
        SetSuggestedTable(Database::"Assembly Line");
        SetSuggestedTable(Database::"Avg. Cost Adjmt. Entry Point");
        SetSuggestedTable(Database::"Bank Acc. Reconciliation Line");
        SetSuggestedTable(Database::"Bank Acc. Reconciliation");
        SetSuggestedTable(Database::"Bank Account Ledger Entry");
        SetSuggestedTable(Database::"Bank Account Ledger Entry");
        SetSuggestedTable(Database::"Bank Account Statement Line");
        SetSuggestedTable(Database::"Bank Account Statement");
        SetSuggestedTable(Database::"Bank Stmt Multiple Match Line");
        SetSuggestedTable(Database::"Campaign Entry");
        SetSuggestedTable(Database::"Capacity Ledger Entry");
        SetSuggestedTable(Database::"Cash Flow Manual Revenue");
        SetSuggestedTable(Database::"Cash Flow Manual Expense");
        SetSuggestedTable(Database::"Cash Flow Forecast Entry");
        SetSuggestedTable(Database::"Cash Flow Worksheet Line");
        SetSuggestedTable(Database::"Certificate of Supply");
        SetSuggestedTable(Database::"Change Log Entry");
        SetSuggestedTable(Database::"Check Ledger Entry");
        SetSuggestedTable(Database::"Comment Line");
        SetSuggestedTable(Database::"Contract Change Log");
        SetSuggestedTable(Database::"Contract Gain/Loss Entry");
        SetSuggestedTable(Database::"Contract/Service Discount");
        SetSuggestedTable(Database::"Cost Budget Entry");
        SetSuggestedTable(Database::"Cost Budget Register");
        SetSuggestedTable(Database::"Cost Entry");
        SetSuggestedTable(Database::"Cost Journal Line");
        SetSuggestedTable(Database::"Cost Register");
        SetSuggestedTable(Database::"Credit Trans Re-export History");
        SetSuggestedTable(Database::"Credit Transfer Entry");
        SetSuggestedTable(Database::"Credit Transfer Register");
        SetSuggestedTable(Database::"Cust. Ledger Entry");
        SetSuggestedTable(Database::"Date Compr. Register");
        SetSuggestedTable(Database::"Detailed Cust. Ledg. Entry");
        SetSuggestedTable(Database::"Detailed Vendor Ledg. Entry");
        SetSuggestedTable(Database::"Dimension Set Entry");
        SetSuggestedTable(Database::"Dimension Set Tree Node");
        SetSuggestedTable(Database::"Direct Debit Collection Entry");
        SetSuggestedTable(Database::"Direct Debit Collection");
        // SetSuggestedTable(Database::"DO Payment Trans. Log Entry");
        SetSuggestedTable(Database::"Document Entry");
        SetSuggestedTable(Database::"Email Item");
        SetSuggestedTable(Database::"Employee Absence");
        SetSuggestedTable(Database::"Error Buffer");
        SetSuggestedTable(Database::"Exch. Rate Adjmt. Reg.");
        SetSuggestedTable(Database::"FA G/L Posting Buffer");
        SetSuggestedTable(Database::"FA Ledger Entry");
        SetSuggestedTable(Database::"FA Register");
        SetSuggestedTable(Database::"Filed Contract Line");
        SetSuggestedTable(Database::"Filed Service Contract Header");
        SetSuggestedTable(Database::"Fin. Charge Comment Line");
        SetSuggestedTable(Database::"Finance Charge Memo Header");
        SetSuggestedTable(Database::"Finance Charge Memo Line");
        SetSuggestedTable(Database::"G/L - Item Ledger Relation");
        SetSuggestedTable(Database::"G/L Budget Entry");
        SetSuggestedTable(Database::"G/L Budget Name");
        SetSuggestedTable(Database::"G/L Entry - VAT Entry Link");
        SetSuggestedTable(Database::"G/L Entry");
        SetSuggestedTable(Database::"G/L Register");
        SetSuggestedTable(Database::"Gen. Jnl. Allocation");
        SetSuggestedTable(Database::"Gen. Journal Line");
        SetSuggestedTable(Database::"Handled IC Inbox Jnl. Line");
        SetSuggestedTable(Database::"Handled IC Inbox Purch. Header");
        SetSuggestedTable(Database::"Handled IC Inbox Purch. Line");
        SetSuggestedTable(Database::"Handled IC Inbox Sales Header");
        SetSuggestedTable(Database::"Handled IC Inbox Sales Line");
        SetSuggestedTable(Database::"Handled IC Inbox Trans.");
        SetSuggestedTable(Database::"Handled IC Outbox Jnl. Line");
        SetSuggestedTable(Database::"Handled IC Outbox Purch. Hdr");
        SetSuggestedTable(Database::"Handled IC Outbox Purch. Line");
        SetSuggestedTable(Database::"Handled IC Outbox Sales Header");
        SetSuggestedTable(Database::"Handled IC Outbox Sales Line");
        SetSuggestedTable(Database::"Handled IC Outbox Trans.");
        SetSuggestedTable(Database::"IC Comment Line");
        SetSuggestedTable(Database::"IC Document Dimension");
        SetSuggestedTable(Database::"IC Inbox Jnl. Line");
        SetSuggestedTable(Database::"IC Inbox Purchase Header");
        SetSuggestedTable(Database::"IC Inbox Purchase Line");
        SetSuggestedTable(Database::"IC Inbox Sales Header");
        SetSuggestedTable(Database::"IC Inbox Sales Line");
        SetSuggestedTable(Database::"IC Inbox Transaction");
        SetSuggestedTable(Database::"IC Inbox/Outbox Jnl. Line Dim.");
        SetSuggestedTable(Database::"IC Outbox Jnl. Line");
        SetSuggestedTable(Database::"IC Outbox Purchase Header");
        SetSuggestedTable(Database::"IC Outbox Purchase Line");
        SetSuggestedTable(Database::"IC Outbox Sales Header");
        SetSuggestedTable(Database::"IC Outbox Sales Line");
        SetSuggestedTable(Database::"IC Outbox Transaction");
        SetSuggestedTable(Database::"Incoming Document");
        SetSuggestedTable(Database::"Ins. Coverage Ledger Entry");
        SetSuggestedTable(Database::"Insurance Register");
        SetSuggestedTable(Database::"Inter. Log Entry Comment Line");
        SetSuggestedTable(Database::"Interaction Log Entry");
        SetSuggestedTable(Database::"Internal Movement Header");
        SetSuggestedTable(Database::"Internal Movement Line");
#pragma warning disable AL0432
        SetSuggestedTable(Database::"Intrastat Jnl. Line");
#pragma warning restore AL0432
        SetSuggestedTable(Database::"Inventory Adjmt. Entry (Order)");
        SetSuggestedTable(Database::"Inventory Period Entry");
        SetSuggestedTable(Database::"Inventory Report Entry");
        SetSuggestedTable(Database::"Issued Fin. Charge Memo Header");
        SetSuggestedTable(Database::"Issued Fin. Charge Memo Line");
        SetSuggestedTable(Database::"Issued Reminder Header");
        SetSuggestedTable(Database::"Issued Reminder Line");
        SetSuggestedTable(Database::"Item Analysis View Budg. Entry");
        SetSuggestedTable(Database::"Item Analysis View Entry");
        SetSuggestedTable(Database::"Item Analysis View");
        SetSuggestedTable(Database::"Item Application Entry History");
        SetSuggestedTable(Database::"Item Application Entry");
        SetSuggestedTable(Database::"Item Budget Entry");
        SetSuggestedTable(Database::"Item Charge Assignment (Purch)");
        SetSuggestedTable(Database::"Item Charge Assignment (Sales)");
        SetSuggestedTable(Database::"Item Entry Relation");
        SetSuggestedTable(Database::"Item Journal Line");
        SetSuggestedTable(Database::"Item Ledger Entry");
        SetSuggestedTable(Database::"Item Register");
        SetSuggestedTable(Database::"Item Tracking Comment");
        SetSuggestedTable(Database::"Job Entry No.");
        // SetSuggestedTable(Database::"Job G/L Account Price");
        // SetSuggestedTable(Database::"Job Item Price");
        SetSuggestedTable(Database::"Job Journal Line");
        SetSuggestedTable(Database::"Job Ledger Entry");
        SetSuggestedTable(Database::"Job Planning Line Invoice");
        SetSuggestedTable(Database::"Job Planning Line");
        SetSuggestedTable(Database::"Job Queue Log Entry");
        SetSuggestedTable(Database::"Job Register");
        // SetSuggestedTable(Database::"Job Resource Price");
        SetSuggestedTable(Database::"Job Task Dimension");
        SetSuggestedTable(Database::"Job Task");
        SetSuggestedTable(Database::"Job Task");
        SetSuggestedTable(Database::"Job Usage Link");
        SetSuggestedTable(Database::"Job WIP Entry");
        SetSuggestedTable(Database::"Job WIP G/L Entry");
        SetSuggestedTable(Database::"Job WIP Total");
        SetSuggestedTable(Database::"Job WIP Warning");
        SetSuggestedTable(Database::"Loaner Entry");
        SetSuggestedTable(Database::"Lot No. Information");
        SetSuggestedTable(Database::"Maintenance Ledger Entry");
        SetSuggestedTable(Database::"Maintenance Registration");
        SetSuggestedTable(Database::"Opportunity Entry");
        SetSuggestedTable(Database::"Order Promising Line");
        SetSuggestedTable(Database::"Order Tracking Entry");
        // SetSuggestedTable(Database::"Overdue Notification Entry");
        SetSuggestedTable(Database::"Payable Vendor Ledger Entry");
        SetSuggestedTable(Database::"Payment Application Proposal");
        SetSuggestedTable(Database::"Payment Export Data");
        SetSuggestedTable(Database::"Payment Jnl. Export Error Text");
        SetSuggestedTable(Database::"Payment Matching Details");
        SetSuggestedTable(Database::"Phys. Inventory Ledger Entry");
        SetSuggestedTable(Database::"Planning Assignment");
        SetSuggestedTable(Database::"Planning Component");
        SetSuggestedTable(Database::"Planning Error Log");
        SetSuggestedTable(Database::"Planning Routing Line");
        SetSuggestedTable(Database::"Post Value Entry to G/L");
        SetSuggestedTable(Database::"Posted Approval Comment Line");
        SetSuggestedTable(Database::"Posted Approval Entry");
        SetSuggestedTable(Database::"Posted Assemble-to-Order Link");
        SetSuggestedTable(Database::"Posted Assembly Header");
        SetSuggestedTable(Database::"Posted Assembly Line");
        SetSuggestedTable(Database::"Posted Invt. Pick Header");
        SetSuggestedTable(Database::"Posted Invt. Pick Line");
        SetSuggestedTable(Database::"Posted Invt. Put-away Header");
        SetSuggestedTable(Database::"Posted Invt. Put-away Line");
        SetSuggestedTable(Database::"Posted Payment Recon. Hdr");
        SetSuggestedTable(Database::"Posted Payment Recon. Line");
        SetSuggestedTable(Database::"Posted Whse. Receipt Header");
        SetSuggestedTable(Database::"Posted Whse. Receipt Line");
        SetSuggestedTable(Database::"Posted Whse. Shipment Header");
        SetSuggestedTable(Database::"Posted Whse. Shipment Line");
        // SetSuggestedTable(Database::"Posting Exch. Field");
        // SetSuggestedTable(Database::"Posting Exch.");
        SetSuggestedTable(Database::"Prod. Order Capacity Need");
        SetSuggestedTable(Database::"Prod. Order Comment Line");
        SetSuggestedTable(Database::"Prod. Order Comp. Cmt Line");
        SetSuggestedTable(Database::"Prod. Order Component");
        SetSuggestedTable(Database::"Prod. Order Line");
        SetSuggestedTable(Database::"Prod. Order Routing Line");
        SetSuggestedTable(Database::"Prod. Order Routing Personnel");
        SetSuggestedTable(Database::"Prod. Order Routing Tool");
        SetSuggestedTable(Database::"Prod. Order Rtng Comment Line");
        SetSuggestedTable(Database::"Prod. Order Rtng Qlty Meas.");
        SetSuggestedTable(Database::"Production Forecast Entry");
        SetSuggestedTable(Database::"Production Order");
        SetSuggestedTable(Database::"Purch. Comment Line Archive");
        SetSuggestedTable(Database::"Purch. Comment Line");
        SetSuggestedTable(Database::"Purch. Cr. Memo Hdr.");
        SetSuggestedTable(Database::"Purch. Cr. Memo Line");
        SetSuggestedTable(Database::"Purch. Inv. Header");
        SetSuggestedTable(Database::"Purch. Inv. Line");
        SetSuggestedTable(Database::"Purch. Rcpt. Header");
        SetSuggestedTable(Database::"Purch. Rcpt. Line");
        SetSuggestedTable(Database::"Purchase Header Archive");
        SetSuggestedTable(Database::"Purchase Header");
        SetSuggestedTable(Database::"Purchase Line Archive");
        SetSuggestedTable(Database::"Purchase Line");
        SetSuggestedTable(Database::"Registered Invt. Movement Hdr.");
        SetSuggestedTable(Database::"Registered Invt. Movement Line");
        SetSuggestedTable(Database::"Registered Whse. Activity Hdr.");
        SetSuggestedTable(Database::"Registered Whse. Activity Line");
        SetSuggestedTable(Database::"Reminder Comment Line");
        SetSuggestedTable(Database::"Reminder Header");
        SetSuggestedTable(Database::"Reminder Line");
        SetSuggestedTable(Database::"Reminder/Fin. Charge Entry");
        SetSuggestedTable(Database::"Requisition Line");
        SetSuggestedTable(Database::"Res. Capacity Entry");
        SetSuggestedTable(Database::"Res. Journal Line");
        SetSuggestedTable(Database::"Res. Ledger Entry");
        SetSuggestedTable(Database::"Reservation Entry");
        SetSuggestedTable(Database::"Resource Register");
        SetSuggestedTable(Database::"Return Receipt Header");
        SetSuggestedTable(Database::"Return Receipt Line");
        SetSuggestedTable(Database::"Return Shipment Header");
        SetSuggestedTable(Database::"Return Shipment Line");
        SetSuggestedTable(Database::"Returns-Related Document");
        SetSuggestedTable(Database::"Reversal Entry");
        SetSuggestedTable(Database::"Rounding Residual Buffer");
        SetSuggestedTable(Database::"Sales Comment Line Archive");
        SetSuggestedTable(Database::"Sales Comment Line");
        SetSuggestedTable(Database::"Sales Cr.Memo Header");
        SetSuggestedTable(Database::"Sales Cr.Memo Line");
        SetSuggestedTable(Database::"Sales Header Archive");
        SetSuggestedTable(Database::"Sales Header");
        SetSuggestedTable(Database::"Sales Invoice Header");
        SetSuggestedTable(Database::"Sales Invoice Line");
        SetSuggestedTable(Database::"Sales Line Archive");
        SetSuggestedTable(Database::"Sales Line");
        SetSuggestedTable(Database::"Sales Planning Line");
        SetSuggestedTable(Database::"Sales Shipment Header");
        SetSuggestedTable(Database::"Sales Shipment Line");
        SetSuggestedTable(Database::"Segment Criteria Line");
        SetSuggestedTable(Database::"Segment Header");
        SetSuggestedTable(Database::"Segment History");
        SetSuggestedTable(Database::"Segment Interaction Language");
        SetSuggestedTable(Database::"Segment Line");
        SetSuggestedTable(Database::"Serial No. Information");
        SetSuggestedTable(Database::"Service Comment Line");
        SetSuggestedTable(Database::"Service Contract Header");
        SetSuggestedTable(Database::"Service Contract Line");
        SetSuggestedTable(Database::"Service Cr.Memo Header");
        SetSuggestedTable(Database::"Service Cr.Memo Line");
        SetSuggestedTable(Database::"Service Document Log");
        SetSuggestedTable(Database::"Service Document Register");
        // SetSuggestedTable(Database::"Service E-Mail Queue");
        SetSuggestedTable(Database::"Service Header");
        SetSuggestedTable(Database::"Service Invoice Header");
        SetSuggestedTable(Database::"Service Invoice Line");
        SetSuggestedTable(Database::"Service Item Component");
        SetSuggestedTable(Database::"Service Item Line");
        SetSuggestedTable(Database::"Service Item Log");
        SetSuggestedTable(Database::"Service Item");
        SetSuggestedTable(Database::"Service Ledger Entry");
        SetSuggestedTable(Database::"Service Line Price Adjmt.");
        SetSuggestedTable(Database::"Service Line");
        SetSuggestedTable(Database::"Service Order Allocation");
        SetSuggestedTable(Database::"Service Register");
        SetSuggestedTable(Database::"Service Shipment Header");
        SetSuggestedTable(Database::"Service Shipment Item Line");
        SetSuggestedTable(Database::"Service Shipment Line");
        SetSuggestedTable(Database::"Time Sheet Cmt. Line Archive");
        SetSuggestedTable(Database::"Time Sheet Comment Line");
        SetSuggestedTable(Database::"Time Sheet Detail Archive");
        SetSuggestedTable(Database::"Time Sheet Detail");
        SetSuggestedTable(Database::"Time Sheet Header Archive");
        SetSuggestedTable(Database::"Time Sheet Header");
        SetSuggestedTable(Database::"Time Sheet Line Archive");
        SetSuggestedTable(Database::"Time Sheet Line");
        SetSuggestedTable(Database::"Time Sheet Posting Entry");
        SetSuggestedTable(Database::"To-do");
        SetSuggestedTable(Database::"Tracking Specification");
        SetSuggestedTable(Database::"Transfer Header");
        SetSuggestedTable(Database::"Transfer Line");
        SetSuggestedTable(Database::"Transfer Receipt Header");
        SetSuggestedTable(Database::"Transfer Receipt Line");
        SetSuggestedTable(Database::"Transfer Shipment Header");
        SetSuggestedTable(Database::"Transfer Shipment Line");
        SetSuggestedTable(Database::"Unplanned Demand");
        SetSuggestedTable(Database::"Untracked Planning Element");
        SetSuggestedTable(Database::"Value Entry Relation");
        SetSuggestedTable(Database::"Value Entry");
        SetSuggestedTable(Database::"VAT Entry");
        SetSuggestedTable(Database::"VAT Rate Change Log Entry");
        SetSuggestedTable(Database::"VAT Report Header");
        SetSuggestedTable(Database::"VAT Report Line");
        SetSuggestedTable(Database::"VAT Report Line Relation");
        SetSuggestedTable(Database::"VAT Report Error Log");
        SetSuggestedTable(Database::"Vendor Ledger Entry");
        SetSuggestedTable(Database::"Warehouse Activity Header");
        SetSuggestedTable(Database::"Warehouse Activity Line");
        SetSuggestedTable(Database::"Warehouse Entry");
        SetSuggestedTable(Database::"Warehouse Journal Line");
        SetSuggestedTable(Database::"Warehouse Receipt Header");
        SetSuggestedTable(Database::"Warehouse Receipt Line");
        SetSuggestedTable(Database::"Warehouse Register");
        SetSuggestedTable(Database::"Warehouse Request");
        SetSuggestedTable(Database::"Warehouse Shipment Header");
        SetSuggestedTable(Database::"Warehouse Shipment Line");
        SetSuggestedTable(Database::"Warranty Ledger Entry");
        SetSuggestedTable(Database::"Whse. Internal Pick Header");
        SetSuggestedTable(Database::"Whse. Internal Pick Line");
        SetSuggestedTable(Database::"Whse. Internal Put-away Header");
        SetSuggestedTable(Database::"Whse. Internal Put-away Line");
        SetSuggestedTable(Database::"Whse. Item Entry Relation");
        SetSuggestedTable(Database::"Whse. Item Tracking Line");
        SetSuggestedTable(Database::"Whse. Pick Request");
        SetSuggestedTable(Database::"Whse. Put-away Request");
        SetSuggestedTable(Database::"Whse. Worksheet Line");
        SetSuggestedTable(Database::Attachment);
        SetSuggestedTable(Database::Attendee);
        SetSuggestedTable(Database::Job);
        SetSuggestedTable(Database::Opportunity);

        RecordDeletion.SetRange("Delete Records", true);
        AfterSuggestionDeleteCount := RecordDeletion.Count();
        Message(RecordsWereSuggestedMsg, AfterSuggestionDeleteCount - BeforeSuggestionDeleteCount);
    end;

    procedure SuggestUnlicensedPartnerOrCustomRecordsToDelete()
    var
        RecordDeletion: Record "Record Deletion SOC";
        RecsSuggestedCount: Integer;
        RecordsSuggestedMsg: Label '%1 unlicensed partner or custom records were suggested.', Comment = '%1 number of unlicensed records';
    begin
        RecordDeletion.SetFilter("Table ID", '> %1', 49999);
        if RecordDeletion.FindSet(false) then
            repeat
                if not IsRecordStandardTable(RecordDeletion."Table ID") then
                    if not IsRecordInLicense(RecordDeletion."Table ID") then begin
                        SetSuggestedTable(RecordDeletion."Table ID");
                        RecsSuggestedCount += 1;
                    end;
            until RecordDeletion.Next() = 0;

        Message(RecordsSuggestedMsg, RecsSuggestedCount);
    end;

    procedure ViewRecords(RecordDeletion: Record "Record Deletion SOC")
    begin
        Hyperlink(GetUrl(ClientType::Current, CompanyName, ObjectType::Table, RecordDeletion."Table ID"));
    end;

    local procedure IsRecordInLicense(TableID: Integer): Boolean
    var
        LicensePermission: Record "License Permission";
    begin
        // LicensePermission.Get(LicensePermission."Object Type"::Table, TableID);
        LicensePermission.Get(LicensePermission."Object Type"::tabledata, TableID);
        if (LicensePermission."Read Permission" = LicensePermission."Read Permission"::" ") and
            (LicensePermission."Insert Permission" = LicensePermission."Insert Permission"::" ") and
            (LicensePermission."Modify Permission" = LicensePermission."Modify Permission"::" ") and
            (LicensePermission."Delete Permission" = LicensePermission."Delete Permission"::" ") and
            (LicensePermission."Execute Permission" = LicensePermission."Execute Permission"::" ")
        then
            exit(false)
        else
            exit(true);
    end;

    local procedure IsRecordStandardTable(TableID: Integer): Boolean
    begin
        case true of
            //5005270 - 5005363
            // 5005363 = "Phys. Invt. Diff. List Buffer"
            // (TableID >= Database::"Delivery Reminder Header") and (TableID <= Database::"Phys. Invt. Diff. List Buffer"):
            (TableID >= 5005270) and (TableID <= 5005363):
                exit(true);
            //99000750 - 99008535
            // 99000750 = Workshift
            (TableID >= 99000750) and (TableID <= 99008535):
                exit(true);
            // Microsoft Localizations
            (TableID >= 100000) and (TableID <= 999999):
                exit(true);
        end;
        exit(false);
    end;



}