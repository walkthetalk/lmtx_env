% Copyright 2005 2015 Ovidiu Gheorghies
% Licensed under the Apache License, Version 2.0.

if known _metauml_usecase_mp:
  expandafter endinput
fi;
_metauml_usecase_mp:=1;

% Sadly, this copy of the macro is needed to prevent multiple file loads being shown by MetaPost.
% The guard values (such as _metauml_mp) do ensure that the file isn't loaded multiple times, 
% but this macro makes sure that MetaPost won't try to load the file and display a message for that.
def inputonce text libraryFile=
	if not known scantokens ("_" & str libraryFile & "_mp"):
		%includeonce% show "Loading " & str libraryFile;
		scantokens ("input " & str libraryFile);
	else:
		%includeonce% show str libraryFile & " already loaded.";
	fi;
enddef;

inputonce metauml_defaults;
inputonce util_log;

vardef ActorInfo@#=
  FontInfo.@#iFont(metauml_defaultFont, defaultscale);
  @#iFont.ignoreNegativeBase := 1;

  PictureInfo.@#iName  (2, 2, 2, 2)(@#iFont);
  PictureStackInfo.@#iNameStack (1pt, 1pt, 1pt, 1pt)(9)(@#iName);

  @#iNameStack.iPict.ignoreNegativeBase := 1;

  HumanInfo.@#iHuman(25, 35, .3, .35, .5, 1, 1);
enddef;

vardef ActorInfoCopy@#(text src)=
  metauml_log "ActorInfoCopy: Copying actor info";

  PictureStackInfoCopy.@#iNameStack (src.iNameStack);

  HumanInfoCopy.@#iHuman(src.iHuman);
enddef;

ActorInfo.iActor;

vardef Actor@#(text contents)=
  EActor.@#(iActor)(contents);
enddef;

vardef EActor@#(text _info)(text contents)=
  ObjectEquations(@#);
  @#className := "Actor";

  ActorInfoCopy.@#info(_info);

  numeric @#nLines; @#nLines := 0;
  string @#lines[];
  for l=contents:
    @#lines[@#nLines] := l;
    @#nLines := @#nLines + 1;
  endfor;
  EHuman.@#human(@#info.iHuman);
  EPictureStack.@#nameStack(@#info.iNameStack)(scantokens listArray(@#lines)(@#nLines))("vcenterbase");
enddef;

vardef Actor_setDebugMode@#=
  @#.nameStack.info.boxed := 1;
enddef;

vardef Actor_layout@#=
  if @#laidout = 1:
    metauml_log "Actor " & (str @#) & " has already been layed out";
  else:
    @#laidout := 1;
    metauml_log "Actor layout: " & (str @#);
    Human_layout.@#human;
    PictureStack_layout.@#nameStack;

    @#width = max(@#nameStack.width)(@#human.width);
    @#height = @#nameStack.height + @#human.height;

    @#n = @#human.n;
    @#nameStack.n=@#human.s;
    @#s = @#nameStack.s;
  fi;
enddef;

vardef Actor_draw@#=
  Actor_layout.@#;

  objectEnsurePositioning.@#;

  drawObjects(@#nameStack, @#human);
enddef;

vardef Actor_border@#=
  objectBox(@#);
enddef;

vardef UsecaseInfo@#=
  attributes(@#);
  var(color)   foreColor, borderColor;

  FontInfo.@#iFont(metauml_defaultFont, defaultscale);
  @#iFont.ignoreNegativeBase := 1;

  PictureInfo.@#iName  (2, 2, 2, 2)(@#iFont);
  PictureStackInfo.@#iNameStack (0, 0, 0, 0)(9)(@#iName);

  @#iNameStack.iPict.ignoreNegativeBase := 1;

  Margins.@#(2,2,2,2);

  @#hFatRatio := .1;
  @#vFatRatio := .15;

  ShadeInfo.@#iShade;
  @#foreColor := .9white;
  @#borderColor := black;
enddef;

vardef UsecaseInfoCopy@#(text src)=
  metauml_log "UsecaseInfoCopy: Copying usecase info";
  attributes(@#);
  var(color)   foreColor, borderColor;

  PictureStackInfoCopy.@#iNameStack (src.iNameStack);
  MarginsCopy.@#(src);
  @#hFatRatio := src.hFatRatio;
  @#vFatRatio := src.vFatRatio;

  ShadeInfoCopy.@#iShade(src.iShade);
  @#foreColor := src.foreColor;
  @#borderColor := src.borderColor;
enddef;

UsecaseInfo.iUsecase;

vardef Usecase@#(text contents)=
  EUsecase.@#(iUsecase)(contents);
enddef;

vardef EUsecase@#(text _info)(text contents)=
  ObjectEquations(@#);
  @#className := "Usecase";

  UsecaseInfoCopy.@#info(_info);

  attributes(@#);
  var(numeric) nLines;
  @#nLines := 0;

  string @#lines[];
  for l=contents:
    @#lines[@#nLines] := l;
    @#nLines := @#nLines + 1;
  endfor;
enddef;

vardef Usecase_layout@#=
  if @#laidout = 1:
    metauml_log "Usecase " & (str @#) & " has already been layed out";
  else:
    @#laidout := 1;

    EPictureStack.@#nameStack(@#info.iNameStack)(scantokens listArray(@#lines)(@#nLines))("vcenterbase");
    PictureStack_layout.@#nameStack;

    numeric @#vFat, @#hFat;

    @#hFat = 0;
    @#vFat = 10;

    @#width = @#nameStack.width + @#info.left + @#info.right + 2 * @#hFat;
    @#height = @#nameStack.height + @#info.top + @#info.bottom + 2 * @#vFat;

    metauml_log "UC w,h";
    metauml_log @#hFat;
    metauml_log @#vFat;
    metauml_log @#nameStack.width;
    metauml_log @#nameStack.height;
    metauml_log @#width;
    metauml_log @#height;

    @#c = @#nameStack.c;
  fi;
enddef;

vardef Usecase_draw@#=
  Usecase_layout@#;

  pair @#urt, @#lrt, @#ulft, @#llft;

  @#urt = @#nameStack.ne;
  @#lrt = @#nameStack.se;
  @#ulft = @#nameStack.nw;
  @#llft = @#nameStack.sw;

  objectEnsurePositioning.@#;

  path @#border;
  %@#border := @#w .. @#ulft .. @#n .. @#urt .. @#e .. @#lrt .. @#s .. @#llft .. cycle;
  @#border := @#w .. @#n .. @#e .. @#s .. cycle;

  drawObjectShade(@#);

  fill Usecase_border.@# withcolor @#info.foreColor;
  draw Usecase_border.@# withcolor @#info.borderColor;

  drawObject(@#nameStack);
enddef;

vardef Usecase_border@#=
  @#border
enddef;
