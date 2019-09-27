page 50020 "AB_FIFA Results List"
{
    PageType = List;
    SourceTable = "AB_FIFA Results";
    Caption = 'Fifa Results';
    Editable = false;
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(MathNo; MathNo)
                {
                    ApplicationArea = All;
                }

                field(HomeTeam; HomeTeam)
                {
                    ApplicationArea = All;
                }
                field(HomeTeamResult; HomeTeamResult)
                {
                    ApplicationArea = All;
                }
                field(AwayTeam; AwayTeam)
                {
                    ApplicationArea = All;
                }
                field(AwayTeamResult; AwayTeamResult)
                {
                    ApplicationArea = All;
                }
                field(City; City)
                {
                    ApplicationArea = All;
                }
                field(DateAndTime; DateAndTime)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(RefreshResults)
            {
                Caption = 'Refresh Results';
                Promoted = true;
                PromotedCategory = Process;
                Image = RefreshLines;
                ApplicationArea = All;
                trigger OnAction();
                begin
                    RefreshResults();
                    CurrPage.Update();
                    if FindFirst() then;
                end;
            }
        }
    }
}
