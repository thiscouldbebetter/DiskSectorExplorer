set fasmPath=[wherever fasm.exe is]
set qemuPath=[wherever qemu.exe is]
for %%* in (.) do (set programName=%%~n*)
call ..\_Build\BuildEnvironmentSetup-FasmQemu.bat
%fasmPath%\fasm.exe %programName%.asm %programName%.img
%qemuPath%\qemu.exe -boot a -fda %programName%.img -hda G:
pause
