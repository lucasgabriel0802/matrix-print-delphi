@echo off
call "C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\rsvars.bat"
set "BDSLIB=C:\Program Files (x86)\Embarcadero\Studio\18.0\lib\win32\release"
set "SRCPATH=C:\DELPHI_COMPONENT_BERLIN\MatrixPrint\Source"
set "OUTPATH=C:\DELPHI_SKILL_BERLIN\ocupacional\Dcu_MatrixPrint"

echo === 1. Compilando MatrixPrintRT.dpk ===
cd /d "C:\DELPHI_COMPONENT_BERLIN\MatrixPrint\Packages"
dcc32 -B -Q -U"%BDSLIB%;%SRCPATH%;%OUTPATH%" -I"%SRCPATH%" -R"%SRCPATH%" -N0"%OUTPATH%" -E"%OUTPATH%" -LE"%OUTPATH%" -LN"%OUTPATH%" MatrixPrintRT.dpk
if errorlevel 1 goto falha

echo === 2. Compilando MatrixPrintDT.dpk ===
dcc32 -B -Q -U"%BDSLIB%;%SRCPATH%;%OUTPATH%" -I"%SRCPATH%" -R"%SRCPATH%" -N0"%OUTPATH%" -E"%OUTPATH%" -LE"%OUTPATH%" -LN"%OUTPATH%" MatrixPrintDT.dpk
if errorlevel 1 goto falha

echo === 3. Compilando DemoMatrixPrint.dpr ===
cd /d "C:\DELPHI_COMPONENT_BERLIN\MatrixPrint\Demo"
dcc32 -B -Q -U"%BDSLIB%;%SRCPATH%;%OUTPATH%" -I"%SRCPATH%" -R"%SRCPATH%" -N0"%OUTPATH%" -E"%OUTPATH%" DemoMatrixPrint.dpr
if errorlevel 1 goto falha

echo === BUILD SUCCESSFUL ===
goto fim

:falha
echo === BUILD FAILED ===
exit /b 1

:fim
exit /b 0
