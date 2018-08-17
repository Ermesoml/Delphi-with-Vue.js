program DarajaServer;

uses
  Vcl.Forms,
  Main in 'main\Main.pas' {FrDarajaServer},
  ServicoCadastrosWeb in 'services\ServicoCadastrosWeb.pas',
  DBCadastros in 'DB\DBCadastros.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrDarajaServer, FrDarajaServer);
  Application.Run;
end.
