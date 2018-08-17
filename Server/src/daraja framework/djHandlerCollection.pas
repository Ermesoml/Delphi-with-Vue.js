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

unit djHandlerCollection;

interface


uses
  djInterfaces, djAbstractHandlerContainer, djServerContext,
  {$IFDEF DARAJA_LOGGING}djLogAPI, djLoggerFactory,{$ENDIF DARAJA_LOGGING}
  djTypes;

type
  (**
   * A collection of handlers.
   * For each request, all handler are called, regardless of
   * the response status or exceptions.
   *)
   TdjHandlerCollection = class(TdjAbstractHandlerContainer)
   private
    {$IFDEF DARAJA_LOGGING}
    Logger: ILogger;
    {$ENDIF DARAJA_LOGGING}

    procedure Trace(const S: string);

   protected
     (**
      * The handler collection.
      *)
     FHandlers: TdjHandlers;

   public
    (**
     * Create a TdjHandlerCollection.
     *)
    constructor Create; override;

    (**
     * Destructor.
     *)
    destructor Destroy; override;

    // IHandler interface

    (**
     * Handle a HTTP request.
     *
     * \param Target Request target
     * \param Context HTTP server context
     * \param Request HTTP request
     * \param Response HTTP response
     *
     * \sa IHandler
     *)
    procedure Handle(Target: string; Context: TdjServerContext;
      Request: TdjRequest; Response: TdjResponse); override;

    // Lifecycle

    (**
     * Start the handler.
     *)
    procedure DoStart; override;

    (**
     * Start the handler.
     *)
    procedure DoStop; override;

    // IHandlerContainer

    (**
     * Add a handler.
     * \param Handler the handler to be added.
     *)
    procedure AddHandler(const Handler: IHandler); override;

    (**
     * Remove a handler.
     * \param Handler the handler to be removed.
     *)
    procedure RemoveHandler(const Handler: IHandler); override;

  end;

implementation

uses
  SysUtils;

{ TdjHandlerCollection }

constructor TdjHandlerCollection.Create;
begin
  inherited;

// logging -----------------------------------------------------------------
  {$IFDEF DARAJA_LOGGING}
  Logger := TdjLoggerFactory.GetLogger('dj.' + TdjHandlerCollection.ClassName);
  {$ENDIF DARAJA_LOGGING}

  FHandlers := TdjHandlers.Create;
end;

destructor TdjHandlerCollection.Destroy;
begin
  {$IFDEF LOG_DESTROY}
  Trace('Destroy');
  {$ENDIF}

  FHandlers.Free;

  inherited;
end;

procedure TdjHandlerCollection.AddHandler(const Handler: IHandler);
begin
  // Trace(Name + ' AddHandler');

  FHandlers.Add(Handler);

  if Started then
  begin
    Handler.Start;
  end;
end;

procedure TdjHandlerCollection.RemoveHandler(const Handler: IHandler);
begin
  // Trace('RemoveHandler');

  if Handler.IsStarted then
  begin
    Handler.Stop;
  end;

  FHandlers.Remove(Handler);
end;

procedure TdjHandlerCollection.Trace(const S: string);
begin
{$IFDEF DARAJA_LOGGING}
  if Logger.IsTraceEnabled then
  begin
    Logger.Trace(S);
  end;
{$ENDIF DARAJA_LOGGING}
end;

procedure TdjHandlerCollection.DoStart;
var
  H: IHandler;
begin
  // Trace('Start ' + FName);

  for H in FHandlers do
  begin
    try
      H.Start;
    except
      on E: Exception do
      begin
        {$IFDEF DARAJA_LOGGING}
        Logger.Error(E.Message);
        {$ENDIF DARAJA_LOGGING}
      end;
    end;
  end;

  inherited;
end;

procedure TdjHandlerCollection.DoStop;
var
  H: IHandler;
begin
  // Trace('Stop ' + FName);

  try
    inherited DoStop;
  except
    on E: Exception do
    begin
      {$IFDEF DARAJA_LOGGING}
      Logger.Error(E.Message);
      {$ENDIF DARAJA_LOGGING}
    end;
  end;

  for H in FHandlers do
  begin
    try
      H.Stop;
    except
      on E: Exception do
      begin
        {$IFDEF DARAJA_LOGGING}
        Logger.Error(E.Message);
        {$ENDIF DARAJA_LOGGING}
      end;
    end;
  end;
end;

// handler -------------------------------------------------------------------

procedure TdjHandlerCollection.Handle(Target: string; Context: TdjServerContext;
  Request: TdjRequest; Response: TdjResponse);
var
  H: IHandler;
begin
  Trace('Handle ' + Target);
  if IsStarted then
  begin
    for H in FHandlers do
    begin
      try
        H.Handle(Target, Context, Request, Response);
      except
        on E: Exception do
        begin
          {$IFDEF DARAJA_LOGGING}
          Logger.Error(E.Message);
          {$ENDIF DARAJA_LOGGING}
        end;
      end;
    end;
  end;
end;

(*
procedure TdjHandlerCollection.LogHierarchy;
var
  H: IHandler;
  C: IHandlerContainer;
begin
{$IFDEF DARAJA_LOGGING}
  Logger.Info(Format(ClassName + ' with %d handlers', [FHandlers.Count]));

  for H in FHandlers do
  begin
    if Supports(H, IHandlerContainer, C) then
    begin
      Logger.Info(ClassName + ' - contains a IHandlerContainer: ');
      C.LogHierarchy;
    end else begin
      Logger.Info(ClassName + ' - contains a IHandler');
    end;
  end;

{$ENDIF DARAJA_LOGGING}
end;
*)

end.
