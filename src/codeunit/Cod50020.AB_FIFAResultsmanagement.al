codeunit 50020 "AB_FIFA Results management"
{
    procedure Refresh()
    var
        Results: Record "AB_FIFA Results";
        URL: Text;
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        ContentToken: JsonToken;
        ResultsToken: JsonToken;
        MatchToken: JsonToken;
        ResponseText: text;
        i: Integer;
    begin
        Results.DeleteAll();
        URL := 'https://api.fifa.com/api/v1/calendar/matches?idseason=254645&idcompetition=17&language=en-GB&count=100';

        if not Client.Get(URL, ResponseMessage) then
            Error(Text001_Err);
        ResponseMessage.Content().ReadAs(ResponseText);

        if not ResponseMessage.IsSuccessStatusCode() then
            error(Text002_Err, ResponseMessage.HttpStatusCode(), ResponseText);

        ContentToken.ReadFrom(ResponseText);
        ContentToken.AsObject().Get('Results', ResultsToken);
        for i := 0 to ResultsToken.AsArray().Count() - 1 do begin
            ResultsToken.AsArray().Get(i, MatchToken);
            InsertResults(MatchToken);
        end;
    end;

    local procedure InsertResults(MatchToken: JsonToken)
    var
        Results: Record "AB_FIFA Results";
        ValueToken: JsonToken;
        InStr: InStream;
    begin
        Results.init();

        MatchToken.AsObject().Get('MatchNumber', ValueToken);
        Results.MatchNo := ValueToken.AsValue().AsInteger();

        MatchToken.AsObject().SelectToken('Home.TeamName', ValueToken);
        ValueToken.AsArray().Get(0, ValueToken);
        ValueToken.AsObject().Get('Description', ValueToken);
        Results.HomeTeam := CopyStr(ValueToken.AsValue().AsText(), 1, MaxStrLen(Results.HomeTeam));

        MatchToken.AsObject().SelectToken('Away.TeamName', ValueToken);
        ValueToken.AsArray().Get(0, ValueToken);
        ValueToken.AsObject().Get('Description', ValueToken);
        Results.AwayTeam := CopyStr(ValueToken.AsValue().AsText(), 1, MaxStrLen(Results.AwayTeam));

        MatchToken.AsObject().Get('HomeTeamScore', ValueToken);
        Results.HomeTeamResult := ValueToken.AsValue().AsInteger();

        MatchToken.AsObject().Get('HomeTeamPenaltyScore', ValueToken);
        If ValueToken.AsValue().AsInteger() > 0 then //were penalties in overtime - replace TeamResult
            Results.HomeTeamResult := ValueToken.AsValue().AsInteger();

        MatchToken.AsObject().Get('AwayTeamScore', ValueToken);
        Results.AwayTeamResult := ValueToken.AsValue().AsInteger();

        MatchToken.AsObject().Get('AwayTeamPenaltyScore', ValueToken);
        If ValueToken.AsValue().AsInteger() > 0 then //were penalties in overtime - replace TeamResult
            Results.AwayTeamResult := ValueToken.AsValue().AsInteger();

        if Results.HomeTeamResult - Results.AwayTeamResult <> 0 then //not import flag if draw
            If Results.HomeTeamResult - Results.AwayTeamResult > 0 then begin //Home team Win
                MatchToken.AsObject().SelectToken('Home.PictureUrl', ValueToken);
                GetFlagStream(ValueToken.AsValue().AsText(), InStr);
                Results.Flag.ImportStream(InStr, Results.HomeTeam);
            end else begin // Away team Win
                MatchToken.AsObject().SelectToken('Away.PictureUrl', ValueToken);
                GetFlagStream(ValueToken.AsValue().AsText(), InStr);
                Results.Flag.ImportStream(InStr, Results.AwayTeam);
            end;

        MatchToken.AsObject().SelectToken('Stadium.CityName', ValueToken);
        ValueToken.AsArray().Get(0, ValueToken);
        ValueToken.AsObject().Get('Description', ValueToken);
        Results.City := CopyStr(ValueToken.AsValue().AsText(), 1, MaxStrLen(Results.City));

        MatchToken.AsObject().Get('LocalDate', ValueToken);
        Results.DateAndTime := ValueToken.AsValue().AsDateTime();

        Results.Insert();
    end;

    local procedure GetFlagStream(FlagUrl: Text; var InStr: InStream)
    var
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        ResponseText: Text;
        TextBuilder: TextBuilder;
    begin
        //Basic URL is https://api.fifa.com/api/v1/picture/flags-{format}-{size}/RUS
        TextBuilder.Append(FlagUrl);
        TextBuilder.Replace('{format}', 'fwc2018');
        TextBuilder.Replace('{size}', '1');

        if not Client.Get(TextBuilder.ToText(), ResponseMessage) then
            Error(Text001_Err);

        if not ResponseMessage.IsSuccessStatusCode() then begin
            ResponseMessage.Content().ReadAs(ResponseText);
            error(Text002_Err, ResponseMessage.HttpStatusCode(), ResponseText);
        end;

        ResponseMessage.Content().ReadAs(InStr);
    end;

    var
        Text001_Err: Label 'Service inaccessible';
        Text002_Err: Label 'The web service returned an error message:\ Status code: %1\ Description: %2';
}
