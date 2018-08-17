unit DBCadastros;

interface

uses
  SysUtils;

type  
  RecCadastros = record
    cadastro_id: Integer;
    nome: string;
  end;
  TArrayOfRecCadastros = array of RecCadastros;

  TDBCadastros = class
  public
    function BuscarCadastros: TArrayOfRecCadastros;
  end;

implementation

{ TDBCadastros }


{ TDBCadastros }

function TDBCadastros.BuscarCadastros: TArrayOfRecCadastros;
var
  i: Integer;
begin
  // Simulando a busca de determinado array de dados no banco de dados;
  SetLength(Result, 15);
  for i := 0 to 15 do begin
    Result[i].cadastro_id := i + 1;
    Result[i].nome := 'CADASTRO ' + IntToStr(Result[i].cadastro_id)
  end;
end;

end.
