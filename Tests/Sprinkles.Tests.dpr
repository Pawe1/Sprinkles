program Sprinkles.Tests;

{$IFNDEF TESTINSIGHT}
  {$APPTYPE CONSOLE}
{$ENDIF}

{$STRONGLINKTYPES ON}

uses
  System.SysUtils,
{$IFDEF TESTINSIGHT}
  TestInsight.DUnitX,
{$ENDIF}
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit,
  DUnitX.TestFramework,
  Sprinkles.Tests.InterfacedComponent in 'Base\Sprinkles.Tests.InterfacedComponent.pas',
  Sprinkles.Tests.InterfacedDataModule in 'Base\Sprinkles.Tests.InterfacedDataModule.pas';

var
  Runner: ITestRunner;
  Results: IRunResults;
  Logger: ITestLogger;
  NUnitLogger: ITestLogger;

begin
{$IFDEF TESTINSIGHT}
  TestInsight.DUnitX.RunRegisteredTests;
  Exit;
{$ENDIF}
  try
    TDUnitX.CheckCommandLine;   // Will exit if invalid
    Runner := TDUnitX.CreateRunner;
    Runner.UseRTTI := True;   // Tell the runner to use RTTI to find Fixtures
    // Tell the runner how we will log things
    // Log to the console window
    Logger := TDUnitXConsoleLogger.Create(True);
    Runner.AddLogger(Logger);
    // Generate an NUnit compatible XML File
    NUnitLogger := TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile);
    Runner.AddLogger(NUnitLogger);
    Runner.FailsOnNoAsserts := False;   // When true, assertions must be made during tests

    // Run tests
    Results := Runner.Execute;
    if not Results.AllPassed then
      System.ExitCode := EXIT_ERRORS;

{$IFNDEF CI}
    // We don't want this happening when running under CI.
    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
    begin
      System.Write('Done. Press <Enter> key to quit.');
      System.Readln;
    end;
{$ENDIF}
  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;
end.
