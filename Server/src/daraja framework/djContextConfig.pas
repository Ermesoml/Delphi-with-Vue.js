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

unit djContextConfig;

interface



uses
  djInterfaces, djAbstractConfig;

type
  (**
   * Context configuration.
   *
   *)
  TdjContextConfig = class(TdjAbstractConfig, IContextConfig)
  public
    (**
     * "Copy" constructor.
     *)
    constructor Create(const Config: IContextConfig); overload;
  end;

implementation

{ TdjContextConfig }

constructor TdjContextConfig.Create(const Config: IContextConfig);
var
  L: TdjStrings;
  S: string;
begin
  Create;

  Assert(Config <> nil, 'Config is nil');

  // copy from IConfig argument to self:

  // Params:
  L := Config.GetInitParameterNames;
  for S in L do
  begin
    FParams.Add(S, Config.GetInitParameter(S));
  end;
  L.Free;
end;

end.

