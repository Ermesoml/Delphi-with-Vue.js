unit ServicoCadastrosWeb;
interface

uses djWebComponent, djTypes, JSON;

type
  TServicoCadastrosWeb = class(TdjWebComponent)
  public
    procedure OnGet(Request: TdjRequest; Response: TdjResponse); override;
  end;

implementation

uses SysUtils, Classes, DBCadastros;

procedure TServicoCadastrosWeb.OnGet(Request: TdjRequest; Response: TdjResponse);
var
  i: Integer;
  JSONCadastro: TJSONObject;
  JSONArrayCadastros: TJSONArray;
  cadastros: TArrayOfRecCadastros;
  dbCadastros: TDBCadastros;
begin
  dbCadastros := TDBCadastros.Create;
  cadastros := dbCadastros.BuscarCadastros;  

  JSONArrayCadastros := TJSONArray.Create;
  for i := Low(cadastros) to High(cadastros) do begin
    JSONCadastro := TJSONObject.Create;

    JSONCadastro.AddPair('cadastro_id', IntToStr(cadastros[i].cadastro_id));
    JSONCadastro.AddPair('nome', cadastros[i].nome);

    JSONArrayCadastros.Add(JSONCadastro); 
  end;
  
  Response.ContentText := JSONArrayCadastros.ToString;
  Response.ContentType := 'application/json';
  // É necessário liberar somente o JSONArrayCadastros, uma vez que o JSONCadastro já pertence ao mesmo e liberando um irá também liberar o outro.
  JSONArrayCadastros.Free;
end;

end.
