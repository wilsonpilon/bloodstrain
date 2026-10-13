// Bloodstrain: configuration for the upstream MSXgl build tool.
const path = require("path");

ProjName = "bloodstr"; // MSX-DOS 8.3 filename.
ProjModules = ["src/main", "src/ui/title"];
LibModules = ["system", "bios", "vdp", "draw", "print", "input", "memory"];
Machine = "2";
Target = "DOS2";
OutDir = path.join(ProjDir, "build", "obj") + path.sep;
CompileOpt = "-Iinclude -Ibuild\\generated";
CompileSkipOld = false;
DOSParseArg = false;
CheckVersion = true;
DoCompile = true;
DoMake = true;
DoPackage = true;
DoDeploy = false;
DoRun = false;
BuildVersion = false;
GenCompileDB = true;
