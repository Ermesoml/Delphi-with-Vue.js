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

unit djAbstractHandler;

interface



uses
  djInterfaces, djLifeCycle, djServerContext,
{$IFDEF DARAJA_LOGGING}
  djLogAPI, djLoggerFactory,
{$ENDIF DARAJA_LOGGING}
  djTypes;

type
  (**
   * AbstractHandler
   *)
  TdjAbstractHandler = class(TdjLifeCycle, IHandler)
  private
{$IFDEF DARAJA_LOGGING}
    Logger: ILogger;
{$ENDIF DARAJA_LOGGING}

    procedure Trace(const S: string);

  public
    (**
     * Constructor.
     *)
    constructor Create; override;

    (**
     * Start the handler.
     *)
    procedure DoStart; override;

    (**
     * Start the handler.
     *)
     procedure DoStop; override;

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
    procedure Handle(Target: string; Context: TdjServerContext; Request: TdjRequest; Response:
      TdjResponse); virtual; abstract;

  end;

implementation

{ TdjAbstractHandler }

constructor TdjAbstractHandler.Create;
begin
  inherited Create;

  // logging -----------------------------------------------------------------
{$IFDEF DARAJA_LOGGING}
  Logger := TdjLoggerFactory.GetLogger('dj.' + TdjAbstractHandler.ClassName);
{$ENDIF DARAJA_LOGGING}

{$IFDEF LOG_CREATE}
  Trace('Created');
{$ENDIF}
end;

procedure TdjAbstractHandler.Trace(const S: string);
begin
{$IFDEF DARAJA_LOGGING}
  if Logger.IsTraceEnabled then
  begin
    Logger.Trace(S);
  end;
{$ENDIF DARAJA_LOGGING}
end;

procedure TdjAbstractHandler.DoStart;
begin
  Trace('DoStart');
end;

procedure TdjAbstractHandler.DoStop;
begin
  Trace('DoStop');
end;

end.
