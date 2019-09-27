table 50020 "AB_FIFA Results"
{

    fields
    {
        field(1; MathNo; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Match No.';

        }
        field(2; HomeTeam; text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Home Team';
        }
        field(3; AwayTeam; text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Away Team';
        }
        field(4; HomeTeamResult; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Home Team Result';
        }
        field(5; AwayTeamResult; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Away Team Result';
        }
        field(6; City; text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'City';
        }
        field(7; DateAndTime; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Match Date and Time';
        }
        field(8; Flag; MediaSet)
        {
            DataClassification = CustomerContent;
            Caption = 'Home Team Flag';
        }
    }
    fieldgroups
    {
        fieldgroup(Brick; "Flag", MathNo, "HomeTeam", HomeTeamResult, AwayTeam, AwayTeamResult)
        {
        }
    }

    procedure RefreshResults();
    var
        RefreshResults: Codeunit "AB_FIFA Results management";
    begin
        RefreshResults.Refresh();
    end;

}
