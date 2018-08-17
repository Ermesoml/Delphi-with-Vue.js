(*

    Daraja Framework
    Copyright (C) 2016  Michael Justin

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.


    You can be released from the requirements of the license by purchasing
    a commercial license. Buying such a license is mandatory as soon as you
    develop commercial activities involving the Daraja framework without
    disclosing the source code of your own applications. These activities
    include: offering paid services to customers as an ASP, shipping Daraja 
    with a closed source product.

*)

unit djAbstractConfig;

interface



uses
  djInterfaces, djInitParameters;

type
  (**
   * Generic configuration.
   *)
  TdjAbstractConfig = class(TInterfacedObject)
  protected
    (**
     * Initialization parameters.
     *)
    FParams: TdjInitParameters;

    (**
     * The context.
     *)
    FContext: IContext;

  public
    (**
     * Constructor.
     *)
    constructor Create; overload;

    (**
     * Destructor.
     *)
    destructor Destroy; override;

    (**
     * Add a configuration parameter.
     *
     * \param Key key
     * \param Value value
     *)
    procedure Add(const Key: string; const Value: string);

    (**
     * Set the context.
     *
     * \param Context the context
     *)
    procedure SetContext(const Context: IContext);

    // IConfig interface

    (**
     * Get init parameter.
     *)
    function GetInitParameter(const Key: string): string;

    (**
     * Get init parameter names.
     *)
    function GetInitParameterNames: TdjStrings;

    (**
     * Get the context.
     *)
    function GetContext: IContext;

  end;

implementation

{ TdjAbstractConfig }

constructor TdjAbstractConfig.Create;
begin
  inherited;

  FParams := TdjInitParameters.Create;
end;

destructor TdjAbstractConfig.Destroy;
begin
  FParams.Free;

  inherited;
end;

function TdjAbstractConfig.GetContext: IContext;
begin
  Result := FContext;
end;

procedure TdjAbstractConfig.Add(const Key: string; const Value: string);
begin
  {$IFDEF FPC}
  if FParams.IndexOf(Key) > -1 then
  {$ELSE}
  if FParams.ContainsKey(Key) then
  {$ENDIF}
    raise EWebComponentException.
      CreateFmt('Duplicate key %s in configuration', [Key]);

  FParams.Add(Key, Value);
end;

function TdjAbstractConfig.GetInitParameter(const Key: string): string;
begin
  {$IFDEF FPC}
  Result := FParams.KeyData[Key];
  {$ELSE}
  FParams.TryGetValue(Key, Result);
  {$ENDIF}
end;

function TdjAbstractConfig.GetInitParameterNames: TdjStrings;
var
  {$IFDEF FPC}
  I: Integer;
  {$ELSE}
  S: string;
  {$ENDIF}
begin
  Result := TdjStrings.Create;

  {$IFDEF FPC}
  for I := 0 to FParams.Count - 1 do
  begin
    Result.Add(FParams.Keys[I]);
  end;
  {$ELSE}
  for S in FParams.Keys do
  begin
    Result.Add(S);
  end;
  {$ENDIF}
end;

procedure TdjAbstractConfig.SetContext(const Context: IContext);
begin
  if not Assigned(Context) then
    raise EWebComponentException.Create('Context can not be set to nil');

  if Assigned(FContext) then
    raise EWebComponentException.Create('Context must not be changed');

  FContext := Context;
end;

end.

