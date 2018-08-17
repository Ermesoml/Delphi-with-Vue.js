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

unit djWebComponentContextHandler;

interface



uses
  djContextHandler, djWebComponentHandler, djServerContext,
  djWebComponentHolder, djWebComponent, djInterfaces,
{$IFDEF DARAJA_LOGGING}
  djLogAPI, djLoggerFactory,
{$ENDIF DARAJA_LOGGING}
  djTypes;

type
  (**
   * Context Handler for Web Components.
   *)
  TdjWebComponentContextHandler = class(TdjContextHandler)
  private
{$IFDEF DARAJA_LOGGING}
    Logger: ILogger;
{$ENDIF DARAJA_LOGGING}

    WebComponentHandler: TdjWebComponentHandler;
    AutoStartSession: Boolean;

    procedure Trace(const S: string);

  protected
    (**
     * \param Target Request target
     * \param Context HTTP server context
     * \param Request HTTP request
     * \param Response HTTP response
     *)
    procedure DoHandle(const Target: string; Context: TdjServerContext;
      Request: TdjRequest; Response: TdjResponse);

  public
    (**
     * Constructor.
     *
     * \param ContextPath the context path
     * \param Sessions enable HTTP sessions
     *)
    constructor Create(const ContextPath: string; Sessions: Boolean = False);
      overload;

    (**
     * Destructor.
     *)
    destructor Destroy; override;

    (**
     * Add a Web Component.
     *
     * \param ComponentClass WebComponent class
     * \param PathSpec path specification
     *
     * \throws EWebComponentException if the Web Component can not be added
     *)
    procedure AddWebComponent(const ComponentClass: TdjWebComponentClass;
      const PathSpec: string); overload;

    (**
     * Convenience method to add a Web Component.
     *
     * \param ComponentClass WebComponent class
     * \param PathSpec path specification
     *
     * \throws EWebComponentException if the Web Component can not be added
     *)
    procedure Add(const ComponentClass: TdjWebComponentClass; const PathSpec:
      string);

    (**
     * Add a Web Component.
     *
     * \param Holder holds information about the Web Component
     * \param PathSpec path specification
     *
     * \throws EWebComponentException if the Web Component can not be added
     *)
    procedure AddWebComponent(const Holder: TdjWebComponentHolder;
      const PathSpec: string); overload;

    // IHandler interface

    (**
     * Handle a HTTP request.
     *
     * \param Target Request target
     * \param Context HTTP server context
     * \param Request HTTP request
     * \param Response HTTP response
     * \throws EWebComponentException if an exception occurs that interferes with the component's normal operation
     *
     * \sa IHandler
     *)
    procedure Handle(Target: string; Context: TdjServerContext;
      Request: TdjRequest; Response: TdjResponse); override;

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
  Classes, SysUtils;

{ TdjWebComponentContextHandler }

constructor TdjWebComponentContextHandler.Create(const ContextPath: string;
  Sessions: Boolean);
begin
  inherited Create(ContextPath);

  // logging -----------------------------------------------------------------
{$IFDEF DARAJA_LOGGING}
  Logger := TdjLoggerFactory.GetLogger('dj.' +
    TdjWebComponentContextHandler.ClassName);
{$ENDIF DARAJA_LOGGING}

  Self.AutoStartSession := Sessions;

  WebComponentHandler := TdjWebComponentHandler.Create;

  inherited AddHandler(WebComponentHandler);

{$IFDEF LOG_CREATE}
  Trace('Created');
{$ENDIF}
end;

destructor TdjWebComponentContextHandler.Destroy;
begin
{$IFDEF LOG_DESTROY}
  Trace('Destroy');
{$ENDIF}

  inherited;
end;

procedure TdjWebComponentContextHandler.Trace(const S: string);
begin
{$IFDEF DARAJA_LOGGING}
  if Logger.IsTraceEnabled then
  begin
    Logger.Trace(S);
  end;
{$ENDIF DARAJA_LOGGING}
end;

procedure TdjWebComponentContextHandler.DoStart;
begin
  inherited;

end;

procedure TdjWebComponentContextHandler.DoStop;
begin

  inherited;
end;

procedure TdjWebComponentContextHandler.Add(
  const ComponentClass: TdjWebComponentClass; const PathSpec: string);
var
  Holder: TdjWebComponentHolder;
begin
  Holder := WebComponentHandler.FindHolder(ComponentClass);

  if Holder = nil then
  begin
    // create new holder
    Trace(Format('Add new holder for Web Component %s',
      [ComponentClass.ClassName]));
    AddWebComponent(ComponentClass, PathSpec);
  end
  else
  begin
    // add the PathSpec
    Trace(Format('Holder found for Web Component %s, add PathSpec %s',
      [ComponentClass.ClassName, PathSpec]));
    WebComponentHandler.AddWithMapping(Holder, PathSpec);
  end;
end;

procedure TdjWebComponentContextHandler.AddWebComponent(
  const ComponentClass: TdjWebComponentClass; const PathSpec: string);
var
  Holder: TdjWebComponentHolder;
begin
  Holder := TdjWebComponentHolder.Create(ComponentClass);

  try
    AddWebComponent(Holder, PathSpec);
  except
    on E: EWebComponentException do
    begin
      Holder.Free;
      raise;
    end;
  end;
end;

procedure TdjWebComponentContextHandler.AddWebComponent(
  const Holder: TdjWebComponentHolder; const PathSpec: string);
begin
  // Holder can not be reused.
  // Create a new Holder if a Web Component should handle other PathSpecs.
  if Holder.GetContext <> nil then
  begin
    raise EWebComponentException.CreateFmt(
      'Web Component %s is already installed in context %s',
      [Holder.WebComponentClass.ClassName, Holder.GetContext.GetContextPath]
      );
  end;

  // set context of Holder to propagate it to WebComponentConfig
  Holder.SetContext(Self.GetCurrentContext);

  WebComponentHandler.AddWithMapping(Holder, PathSpec);
end;

procedure TdjWebComponentContextHandler.DoHandle(const Target: string;
  Context: TdjServerContext; Request: TdjRequest; Response: TdjResponse);
begin
  Trace('Context ' + ContextPath + ' handles ' + Target);

  WebComponentHandler.Handle(Target, Context, Request, Response);
end;

procedure TdjWebComponentContextHandler.Handle(Target: string;
  Context: TdjServerContext; Request: TdjRequest; Response: TdjResponse);
begin
  if not ContextMatches(ToConnectorName(Context), Target) then
  begin
    Exit;
  end;

  if AutoStartSession then
  begin
    GetSession(Context, Request, Response, True);
  end;

  DoHandle(Target, Context, Request, Response);
end;


end.

