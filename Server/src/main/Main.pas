unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, djServer, IniFiles, djWebAppContext;

type
  TFrDarajaServer = class(TForm)
    lbPortaConfigurada: TLabel;
    btConectar: TBitBtn;
    stStatusConexao: TStaticText;
    btAlterarPorta: TButton;
    ePorta: TEdit;
    procedure btConectarClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    Server: TdjServer;
    procedure AtualizarStatusConexao();
    function BuscarPorta: Integer;
    function NovoServidor: TdjServer;
  public
    { Public declarations }
  end;

var
  FrDarajaServer: TFrDarajaServer;

const
  porta_padrao = 9000;

implementation

{$R *.dfm}

uses ServicoCadastrosWeb;

{ TFrDarajaServer }

procedure TFrDarajaServer.AtualizarStatusConexao;
begin
  if not Server.Started then begin
    btConectar.Caption := 'Conectar';

    stStatusConexao.Color := clMaroon;
    stStatusConexao.Caption := 'Não conectado';
  end
  else begin
    btConectar.Caption := 'Fechar conexão';

    stStatusConexao.Color := clGreen;
    stStatusConexao.Caption := 'Conectado';
  end;  
end;

procedure TFrDarajaServer.btConectarClick(Sender: TObject);
begin
  if not Server.Started then
     Server.Start
  else
    Server.Stop;

  AtualizarStatusConexao;
end;

function TFrDarajaServer.BuscarPorta: Integer;
var
  caminho_arquivo: string;
  arquivo_config: TIniFile;
begin
  Result := porta_padrao;
  caminho_arquivo := GetCurrentDir + '/configuracoes.ini';

  if not FileExists(caminho_arquivo) then begin
    arquivo_config := TIniFile.Create(caminho_arquivo);
    arquivo_config.WriteString('configuracoes', 'porta', IntToStr(porta_padrao));

    arquivo_config.Free;
  end
  else begin
    arquivo_config := TIniFile.Create(caminho_arquivo);
    Result := StrToInt(arquivo_config.ReadString('configuracoes', 'porta', IntToStr(porta_padrao)));

    if Result = 0 then begin
      ShowMessage('Não foi possível validar a porta contida no arquivo de configurações!' + #13#10 + 'A porta 9000 será utilizada como padrão.');
      arquivo_config.WriteString('configuracoes', 'porta', IntToStr(porta_padrao));
      Result := porta_padrao;
    end;

    arquivo_config.Free;
  end;
end;

procedure TFrDarajaServer.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(Server) then
    Server.Stop;

  Server.Free;
end;

procedure TFrDarajaServer.FormCreate(Sender: TObject);
begin
  Server := NovoServidor;
end;

procedure TFrDarajaServer.FormShow(Sender: TObject);
begin
  if Assigned(Server) then
    Server.Start;

  AtualizarStatusConexao
end;

function TFrDarajaServer.NovoServidor: TdjServer;
var     
  porta: Integer;
  contexto: TdjWebAppContext;
begin
  // Buscando a porta do arquivo INI
  porta := BuscarPorta;
  // Exibindo qual porta está configurada
  ePorta.Text := IntToStr(porta);

  {
    Criando o servidor.
    O primeiro parâmetro diz que são aceitos ip's de quaisquer faixas.
    O segundo informa a porta a ser utilizada no servidor.
  }
  Result := TdjServer.Create('0.0.0.0', porta);

  // Se selecionada a porta 80, habilitando também o bind na porta 443 para habilitar o HTTPS.
  if (porta = 80) then begin
    Result.AddConnector('0.0.0.0', 443);
    Result.AddConnector('0.0.0.0', porta);
  end;

  {
    Criando o contexto raiz.
    Para explicar o que é um contexto, usarei um exemplo:
    - exemplo.com.br/         = Contexto raiz;
    - exemplo.com.br/vendas   = Contexto vendas;

    Com o exemplo acima, todas as requisições que irão para /vendas/... serão respondidas pelo contexto vendas, caso nenhum contexto seja encontrato o componente irá para o raiz.
  }
  contexto := TdjWebAppContext.Create('', True);
  contexto.Add(TServicoCadastrosWeb, '/cadastros');
  
  Result.Add(contexto);
end;

end.
