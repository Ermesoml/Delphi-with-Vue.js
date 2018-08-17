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

unit djAbstractConnector;

interface



uses
  djServerInterfaces, djInterfaces, djLifeCycle
{$IFDEF DARAJA_LOGGING}
  ,djLogAPI, djLoggerFactory
{$ENDIF DARAJA_LOGGING}
  ;

type
  (**
   * Abstract connector.
   *
   *)
  TdjAbstractConnector = class(TdjLifeCycle, IConnector)
  private
{$IFDEF DARAJA_LOGGING}
    Logger: ILogger;
{$ENDIF DARAJA_LOGGING}

    FPort: Integer;
    FHost: string;

    procedure Trace(const S: string);

    procedure SetPort(Value: Integer);
    procedure SetHost(const Value: string);
    function GetPort: Integer;
    function GetHost: string;

  protected
    (**
     * Handler for incoming requests.
     *)
    Handler: IHandler;

  public
    (**
     * Create a connector.
     *
     * The handler is a required argument. The connector will
     * call the "Handle" method for incoming requests.
     *
     * \param Handler the request handler
     *)
    constructor Create(const Handler: IHandler); reintroduce;

    (**
     * Destructor.
     *)
    destructor Destroy; override;

    (**
     * Start the handler.
     *)
    procedure DoStart; override;

    (**
     * Stop the handler.
     *)
    procedure DoStop; override;

    // properties

    property Host: string read GetHost write SetHost;
    property Port: Integer read GetPort write SetPort;
  end;

implementation

uses
  SysUtils, Classes;

{ TdjAbstractConnector }

constructor TdjAbstractConnector.Create(const Handler: IHandler);
begin
  inherited Create;

  Assert(Assigned(Handler), 'No handler assigned');

  // logging -----------------------------------------------------------------
{$IFDEF DARAJA_LOGGING}
  Logger := TdjLoggerFactory.GetLogger('dj.' + TdjAbstractConnector.ClassName);
{$ENDIF DARAJA_LOGGING}

  Trace('Configuring');

  Self.Handler := Handler;

  {$IFDEF LOG_CREATE}Trace('Created');{$ENDIF}
end;

destructor TdjAbstractConnector.Destroy;
begin
  {$IFDEF LOG_DESTROY}Trace('Destroy');{$ENDIF}

  if IsStarted then
  begin
    Stop;
  end;

  inherited;
end;

procedure TdjAbstractConnector.Trace(const S: string);
begin
{$IFDEF DARAJA_LOGGING}
  if Logger.IsTraceEnabled then
  begin
    Logger.Trace(S);
  end;
{$ENDIF DARAJA_LOGGING}
end;

procedure TdjAbstractConnector.DoStart;
begin
  // Trace('Starting connector');
end;

procedure TdjAbstractConnector.DoStop;
begin
  // Trace('Stopping connector');
end;

procedure TdjAbstractConnector.SetHost(const Value: string);
begin
  FHost := Value;
end;

procedure TdjAbstractConnector.SetPort(Value: Integer);
begin
  FPort := Value;
end;

function TdjAbstractConnector.GetHost: string;
begin
  Result := FHost;
end;

function TdjAbstractConnector.GetPort: Integer;
begin
  Result := FPort;
end;

end.

