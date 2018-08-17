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

unit djServer;

interface


uses
  djInterfaces, djHTTPConnector, djServerBase, djServerInterfaces,
  djWebComponentContextHandler, djContextHandlerCollection,
{$IFDEF DARAJA_LOGGING}
  djLogAPI, djLoggerFactory,
{$ENDIF DARAJA_LOGGING}
{$IFDEF FPC}
  fgl
{$ELSE}
  Generics.Collections
{$ENDIF};

const
  DEFAULT_BINDING_PORT = 80;
  DEFAULT_BINDING_IP = '127.0.0.1'; // instead of '0.0.0.0';

  (**
   * \mainpage Welcome to Daraja Framework!
   *
   * \section intro Introduction
   *
   * Daraja Framework is a HTTP server framework for Object Pascal.
   * It allows to compose web applications with these building blocks:
   *
   * \li a \link TdjWebComponent Web Component base class \endlink which provides HTTP method handlers (OnGet, OnPost, OnPut etc.)
   * \li a HTTP server run time environment, based on <a target="_blank" href="http://www.indyproject.org/">Internet Direct (Indy)</a>
   *
   * Copyright (C) 2016 Michael Justin
   * https://www.habarisoft.com/
   * Mail: mailto:info@habarisoft.com
   *
   * \section trademarks Trademarks
   *
   * Habari is a registered trademark of Michael Justin and is protected by the
   * laws of Germany and other countries.
   * Embarcadero, the Embarcadero Technologies logos and all other Embarcadero
   * Technologies product or service names are trademarks, servicemarks, and/or
   * registered trademarks of Embarcadero Technologies, Inc.
   * and are protected by the laws of the United States and other countries.
   * Other brands and their products are trademarks of their respective holders.
   *)

type
  (**
   * Basic server class for the Web Component framework.
   *)
  TdjServer = class(TdjServerBase)
  private
{$IFDEF DARAJA_LOGGING}
    Logger: ILogger;
{$ENDIF DARAJA_LOGGING}

    FDefaultHost: string;
    FDefaultPort: Integer;

{$IFDEF FPC}
    ConnectorMap: TFPGMap<string, IConnector>;
{$ELSE}
    ConnectorMap: TObjectDictionary<string, IConnector>;
{$ENDIF}

    ConnectorList: TdjStrings;

    ContextHandlers: IHandlerContainer;

    procedure Trace(const S: string);

    procedure StartConnectors;

    procedure StopConnectors;

  public
    (**
     * Create a TdjServer using the default host and port.
     *)
    constructor Create; overload; override;

    (**
     * Create a TdjServer, using the specified port and the default host.
     *
     * \param APort the port to be used.
     *)
    constructor Create(const APort: Integer); reintroduce; overload;

    (**
     * Create a TdjServer, using the specfied host and port.
     *
     * \param AHost the host to be used.
     * \param APort the port to be used.
     *)
    constructor Create(const AHost: string;
      const APort: Integer = DEFAULT_BINDING_PORT); reintroduce; overload;

    (**
     * Destructor.
     *)
    destructor Destroy; override;

    (**
     * Add a preconfigured connector.
     *
     * \param Connector the connector
     *)
    procedure AddConnector(const Connector: IConnector); overload;

    (**
     * Create and add a connector for a host and port.
     *
     * \param Host the connector host name
     * \param Port the connector port number
     *)
    procedure AddConnector(const Host: string; Port: Integer = DEFAULT_BINDING_PORT);
      overload;

    (**
     * Add a new context.
     *
     * \param Context the context handler.
     *)
    procedure Add(Context: TdjWebComponentContextHandler);

    (**
     * The number of connectors.
     *
     * \returns number of connectors
     *)
    function ConnectorCount: Integer;

    // ILifeCycle interface

    (**
     * Start the handler.
     *)
    procedure DoStart; override;

    (**
     * Stop the handler.
     *)
    procedure DoStop; override;

  end;

implementation

uses
{$IFDEF FPC}{$ELSE}Generics.Defaults, {$ENDIF}
  SysUtils, Classes;

{ TdjServer }

constructor TdjServer.Create;
begin
  inherited Create;

  // logging -----------------------------------------------------------------
{$IFDEF DARAJA_LOGGING}
  Logger := TdjLoggerFactory.GetLogger('dj.' + TdjServer.ClassName);
{$ENDIF DARAJA_LOGGING}

  FDefaultHost := DEFAULT_BINDING_IP;
  FDefaultPort := DEFAULT_BINDING_PORT;

{$IFDEF FPC}
  ConnectorMap := TFPGMap<string, IConnector>.Create;
{$ELSE}
  ConnectorMap := TObjectDictionary<string, IConnector>.Create;
{$ENDIF}

  ConnectorList := TdjStrings.Create;

  ContextHandlers := TdjContextHandlerCollection.Create;

  AddHandler(ContextHandlers);

{$IFDEF LOG_CREATE}
  Trace('Created');
{$ENDIF}
end;

constructor TdjServer.Create(const AHost: string;
  const APort: Integer = DEFAULT_BINDING_PORT);
begin
  Create;

  FDefaultHost := AHost;
  FDefaultPort := APort;
end;

constructor TdjServer.Create(const APort: Integer);
begin
  Create;

  FDefaultPort := APort;
end;

destructor TdjServer.Destroy;
begin
{$IFDEF LOG_DESTROY}
  Trace('Destroy');
{$ENDIF}

  if IsStarted then
  begin
    Stop;
  end;

  // RemoveHandler(ContextHandlers);

  ConnectorMap.Free;
  ConnectorList.Free;

  inherited;
end;

function TdjServer.ConnectorCount: Integer;
begin
  Result := ConnectorList.Count;
end;

procedure TdjServer.AddConnector(const Connector: IConnector);
var
  ConnectorName: string;
begin
  ConnectorName := '[' + Connector.Host + ']:' + IntToStr(Connector.Port);

  Trace('Add connector ' + ConnectorName);

  ConnectorMap.Add(ConnectorName, Connector);
  ConnectorList.Add(ConnectorName);

  if IsStarted then
  begin
    Connector.Start;
  end;
end;

procedure TdjServer.AddConnector(const Host: string; Port: Integer =
  DEFAULT_BINDING_PORT);
var
  Connector: IConnector;
begin
  Connector := TdjHTTPConnector.Create(Self.Handler);

  Connector.Host := Host;
  Connector.Port := Port;

  AddConnector(Connector);
end;

procedure TdjServer.Add(Context: TdjWebComponentContextHandler);
begin
  Trace('Add context ' + Context.ContextPath);

  ContextHandlers.AddHandler(Context);
end;

procedure TdjServer.StartConnectors;
var
  ConnectorName: string;
  Connector: IConnector;
begin
  for ConnectorName in ConnectorList do
  begin
{$IFDEF FPC}
    Connector := ConnectorMap.KeyData[ConnectorName];
{$ELSE}
    Connector := ConnectorMap[ConnectorName];
{$ENDIF}

    Connector.Start;
    Trace(Format('Connector %s started', [ConnectorName]));
  end;

  Trace('All connectors started');
end;

{$IFDEF FPC}

procedure TdjServer.StopConnectors;
var
  ConnectorName: string;
  Connector: IConnector;
  I: Integer;
begin
  for I := ConnectorList.Count - 1 downto 0 do
  begin
    ConnectorName := ConnectorList[I];
    Connector := ConnectorMap.KeyData[ConnectorName];
    Connector.Stop;
    Trace(Format('Connector %s stopped', [ConnectorName]));
  end;
  Trace('All connectors stopped');
end;

{$ELSE}

procedure TdjServer.StopConnectors;
var
  ConnectorName: string;
  Connector: IConnector;
  Keys: TdjStrings;
begin
  Keys := TdjStrings.Create(ConnectorList);

  try
    Keys.Reverse;

    for ConnectorName in Keys do
    begin
      Connector := ConnectorMap[ConnectorName];
      Connector.Stop;
      Trace(Format('Connector %s stopped', [ConnectorName]));
    end;

  finally
    Keys.Free
  end;
  Trace('All connectors stopped');
end;

{$ENDIF}

procedure TdjServer.Trace(const S: string);
begin
{$IFDEF DARAJA_LOGGING}
  if Logger.IsTraceEnabled then
  begin
    Logger.Trace(S);
  end;
{$ENDIF DARAJA_LOGGING}
end;


procedure TdjServer.DoStart;
begin
  CheckStarted;
  Trace('Starting server');

  // add default connector
  if ConnectorList.Count = 0 then
  begin
    Trace('Add default connector');
    AddConnector(FDefaultHost, FDefaultPort);
  end;

  try
    try
      // start HTTP connectors
      StartConnectors;
    except
      on E: Exception do
      begin
{$IFDEF DARAJA_LOGGING}
        Logger.Error('Could not start connectors.');
{$ENDIF DARAJA_LOGGING}
        raise;
      end;
    end;

  except
    on E: Exception do
    begin
{$IFDEF DARAJA_LOGGING}
      Logger.Error('Could not start server.');
{$ENDIF DARAJA_LOGGING}
      raise;
    end;
  end;

  inherited;
end;

procedure TdjServer.DoStop;
begin
  CheckStopped;

  StopConnectors;

  inherited;
end;

end.

