{
 * The contents of this file are subject to the InterBase Public License
 * Version 1.0 (the "License"); you may not use this file except in
 * compliance with the License.
 * 
 * You may obtain a copy of the License at http://www.Inprise.com/IPL.html.
 * 
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
 * the License for the specific language governing rights and limitations
 * under the License.  The Original Code was created by Inprise
 * Corporation and its predecessors.
 * 
 * Portions created by Inprise Corporation are Copyright (C) Inprise
 * Corporation. All Rights Reserved.
 * 
 * Contributor(s): ______________________________________.
}

{****************************************************************
*
*  f r m u D B C o n n e c t
*
****************************************************************
*  Author: The Client Server Factory Inc.
*  Date:   March 1, 1999
*
*  Description:  This unit provides an interface for attaching to
*                a database
*
*****************************************************************
* Revisions:
*
*****************************************************************}
unit frmuDBConnect;

interface

uses
  Windows, SysUtils, Forms, ExtCtrls, StdCtrls, Classes, Controls,
  zluibcClasses, IB, Messages, frmuDlgClass;

type
  TfrmDBConnect = class(TDialog)
    lblDatabaseName: TLabel;
    bvlLine1: TBevel;
    lblUsername: TLabel;
    lblPassword: TLabel;
    lblRole: TLabel;
    Label1: TLabel;
    cbDialect: TComboBox;
    btnConnect: TButton;
    btnCancel: TButton;
    edtRole: TEdit;
    edtPassword: TEdit;
    edtUsername: TEdit;
    stxDatabaseName: TStaticText;
    cbCaseSensitive: TCheckBox;
    cbCharacterSet: TComboBox;
    Label2: TLabel;
    function FormHelp(Command: Word; Data: Integer; var CallHelp: Boolean): Boolean;
    procedure btnCancelClick(Sender: TObject);
    procedure btnConnectClick(Sender: TObject);
    procedure edtRoleChange(Sender: TObject);
  private
    { Private declarations }
    function VerifyInputData(): boolean;
  public
    { Public declarations }
  end;

function DBConnect(var CurrSelDatabase: TibcDatabaseNode; const CurrSelServer: TibcServerNode; const SilentConnect: boolean): boolean;

implementation

uses
  IBServices, frmuMessage, zluGlobal, zluContextHelp;

{$R *.DFM}

{****************************************************************
*
*  D B C o n n e c t ( )
*
****************************************************************
*  Author: The Client Server Factory Inc.
*  Date:   March 1, 1999
*
*  Input:  CurrSelDatabase - The specified database
*          CurrSelServer   - The specified server
*          SilentConnect   - Indicates whether or not to prompt
*                            the user for login information or
*                            to use the default login information.
*
*  Return: Boolean - Indicates the success/failure of the operation
*
*  Description:  Connects to the specified database of the
*                specified server.  If SilentConnect is false the
*                user is prompted for login information.
*
*****************************************************************
* Revisions:
*
*****************************************************************}
function DBConnect(var CurrSelDatabase: TibcDatabaseNode;
  const CurrSelServer: TibcServerNode;
  const SilentConnect: boolean): boolean;
var
  frmDBConnect: TfrmDBConnect;
  attachDialect: integer;
  //Kris 13-Aug-2000 start
  attachCharSet: string;
  //Kris 13-Aug-2000 end
begin
  frmDBConnect := nil;
  CurrSelDatabase.UserName := CurrSelServer.UserName;
  CurrSelDatabase.Password := CurrSelServer.Password;

  // check if a SilentConnect is specified
  if not SilentConnect then
  begin
    try
      frmDBConnect:= TfrmDBConnect.Create(Application);

      frmDBConnect.stxDatabaseName.Caption := CurrSelDatabase.NodeName;
      frmDBConnect.edtUsername.Text := CurrSelDatabase.UserName;
      frmDBConnect.edtRole.Text := CurrSelDatabase.Role;
      frmDBConnect.cbDialect.ItemIndex := 2; // default to dialect 3
      // Kris 12-Aug-2000 start
      with frmDBConnect.cbCharacterSet do
      begin
        // This is temporary, list of vailable character sets is set in IBX
        // and in another place in IBConsole, it should be provided by IBX
        Items.Add('None');
        Items.Add('ASCII');
        Items.Add('BIG_5');
        Items.Add('CYRL');
        Items.Add('DOS437');
        Items.Add('DOS850');
        Items.Add('DOS852');
        Items.Add('DOS857');
        Items.Add('DOS860');
        Items.Add('DOS861');
        Items.Add('DOS863');
        Items.Add('DOS865');
        Items.Add('EUCJ_0208');
        Items.Add('GB_2312');
        Items.Add('ISO8859_1');
        Items.Add('KSC_5601');
        Items.Add('NEXT');
        Items.Add('OCTETS');
        Items.Add('SJIS_0208');
        Items.Add('UNICODE_FSS');
        Items.Add('WIN1250');
        Items.Add('WIN1251');
        Items.Add('WIN1252');
        Items.Add('WIN1253');
        Items.Add('WIN1254');
        ItemIndex := 0;
      end;
      // Kris 12-Aug-2000 end
      frmDBConnect.ShowModal;
      // Kris 12-Aug-2000 end
      if frmDBConnect.ModalResult = mrOK then
      begin
        // set username, password and role
        CurrSelDatabase.UserName := frmDBConnect.edtUsername.Text;
        CurrSelDatabase.Password := frmDBConnect.edtPassword.Text;
        if frmDBConnect.cbCaseSensitive.Checked then
        begin
          CurrSelDatabase.Role := frmDBConnect.edtRole.Text;
          attachDialect := 3;
        end else
        begin
          CurrSelDatabase.Role := frmDBConnect.edtRole.Text;
          attachDialect := 1;
        end;
        CurrSelDatabase.Database.SQLDialect := frmDBConnect.cbDialect.ItemIndex+1;
        // Kris 12-Aug-2000 start
        attachCharSet := frmDBConnect.cbCharacterSet.Text;
        // Kris 12-Aug-2000 end
      end
      else
      begin
        result := false;
        Exit;
      end;
    finally
      // deallocate memory
      frmDBConnect.Free;
    end;
  end
  else
    if CurrSelDatabase.CaseSensitiveRole then
      attachDialect := 3
    else
      attachDialect := 1;

  // if a silent connect was specified or the proper login information was supplied
  try
    Screen.Cursor := crHourGlass;
    // check if the database isn't already connected
    if (not Assigned(CurrSelDatabase.Database)) or
       (not CurrSelDatabase.Database.Connected) then
    begin
      // check if a database file has been specified
      if CurrSelDatabase.DatabaseFiles.Count > 0 then
      begin
        // construct UNC path to database file
        case CurrSelServer.Server.Protocol of
          TCP: CurrSelDatabase.Database.DatabaseName := Format('%s:%s',[CurrSelServer.ServerName,CurrSelDatabase.DatabaseFiles.Strings[0]]);
          NamedPipe: CurrSelDatabase.Database.DatabaseName := Format('\\%s\%s',[CurrSelServer.ServerName,CurrSelDatabase.DatabaseFiles.Strings[0]]);
          SPX: CurrSelDatabase.Database.DatabaseName := Format('%s@%s',[CurrSelServer.ServerName,CurrSelDatabase.DatabaseFiles.Strings[0]]);
          Local:  CurrSelDatabase.Database.DatabaseName := CurrSelDatabase.DatabaseFiles.Strings[0];
        end;
      end;
      // clear database parameters and submit login details
      CurrSelDatabase.Database.Params.Clear;
      CurrSelDatabase.Database.Params.Add(Format('isc_dpb_user_name=%s',[CurrSelDatabase.UserName]));
      CurrSelDatabase.Database.Params.Add(Format('isc_dpb_password=%s',[CurrSelDatabase.Password]));
      if attachDialect = 3 then
        CurrSelDatabase.Database.Params.Add(Format('isc_dpb_sql_role_name="%s"',[CurrSelDatabase.Role]))
      else
        CurrSelDatabase.Database.Params.Add(Format('isc_dpb_sql_role_name=%s',[CurrSelDatabase.Role]));
      CurrSelDatabase.Database.Params.Add(Format('isc_dpb_SQL_dialect=%d',[attachDialect]));
      // Kris 12-Aug-2000 start
      if (attachCharSet <> '') and (attachCharSet <> 'None') then
        CurrSelDatabase.Database.Params.Add('isc_dpb_lc_ctype=' + attachCharSet);
      // Kris 12-Aug-2000 end

      // attempt to connect to the database
      CurrSelDatabase.Database.Connected := true;
      Application.ProcessMessages;

      // Check to see if the database dialect matches, the client dialect
      with CurrSelDatabase.Database do begin
        if not SilentConnect then begin
          //Kris 15-Aug-2000 start
          //old code
          //if DBSQLDialect <> SQLDialect then
          //  DisplayMsg (WAR_DIALECT_MISMATCH,
          //  Format ('Database dialect (%d) does not match client dialect (%d).',[DBSQLDialect, SQLDialect]));
          if DBSQLDialect < SQLDialect then
            DisplayMsg (WAR_DIALECT_MISMATCH,
            Format ('Database dialect (%d) lesser than client dialect (%d).',[DBSQLDialect, SQLDialect]));
          //Kris 15-Aug-2000 end
        end else
          SQLDialect := DBSqlDialect;
        // Kris 14-Aug-2000 start
        gAppSettings[DEFAULT_DIALECT].Setting := SQLDialect;
        gAppSettings[CHARACTER_SET].Setting := attachCharSet;
        // Kris 14-Aug-2000 end
      end;

    end;
      result := true;
      Screen.Cursor := crDefault;
  except                               // if an exception occurs then trap it
    on E:EIBError do                   // and show error message
    begin
      DisplayMsg(ERR_DB_CONNECT,E.Message);
      result := false;
      Screen.Cursor := crDefault;
{ TODO: This was removed to remove a crash when connecting to a non-existent db }
//      CurrSelDatabase := nil;
    end;
  end;
end;

function TfrmDBConnect.FormHelp(Command: Word; Data: Integer;
  var CallHelp: Boolean): Boolean;
begin
  CallHelp := False;
  // call WinHelp and show Database Connect topic
  Result := WinHelp(WindowHandle,CONTEXT_HELP_FILE,HELP_CONTEXT,DATABASE_CONNECT);
end;

procedure TfrmDBConnect.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmDBConnect.btnConnectClick(Sender: TObject);
begin
  if VerifyInputData() then
    ModalResult := mrOK;
end;

{****************************************************************
*
*  V e r i f y I n p u t D a t a ( )
*
****************************************************************
*  Author: The Client Server Factory Inc.
*  Date:   March 1, 1999
*
*  Input:  None
*
*  Return: Boolean - Indicates the success/failure of the operation
*
*  Description:  Performs some basic validation on data entered by
*                the user
*
*****************************************************************
* Revisions:
*
*****************************************************************}
function TfrmDBConnect.VerifyInputData(): boolean;
begin
  result := true;

  // if username was not specified
  if (edtUsername.Text = '') or (edtUsername.Text = ' ') then
  begin
    DisplayMsg(ERR_USERNAME,'');       // show error message
    edtUsername.SetFocus;              // give focus to control
    result := false;
    Exit;
  end;

  // if password was not specified
  if (edtPassword.Text = '') or (edtPassword.Text = ' ') then
  begin
    DisplayMsg(ERR_PASSWORD,'');       // show error message
    edtPassword.SetFocus;              // give focus to control
    result := false;
    Exit;
  end;
end;

procedure TfrmDBConnect.edtRoleChange(Sender: TObject);
begin
  inherited;
  cbCaseSensitive.Enabled := (edtRole.GetTextLen > 0);
end;

end.
