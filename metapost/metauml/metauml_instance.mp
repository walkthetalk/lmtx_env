% Copyright 2005 2015 Radu-George Radulescu
% Licensed under the Apache License, Version 2.0.

if known _metauml_instance_mp:
  expandafter endinput
fi;
_metauml_instance_mp:=1;

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

inputonce util_picture;
inputonce util_picture_stack;
inputonce util_shade;

vardef InstanceInfo@#=
  attributes(@#);
  var(color)   foreColor, borderColor;

  FontInfo.@#nameFont(metauml_defaultFont, defaultscale);

  FontInfo.@#attributeFont(metauml_defaultFont, defaultscale);

  ShadeInfo.@#iShade;

  @#foreColor := .9white;
  @#borderColor := black;

  PictureInfo.@#iName      (2, 2, 1, 3)(@#nameFont);

  PictureInfo.@#iAttribute (2, 2, 1.25, 0)(@#attributeFont);

  PictureStackInfo.@#iAttributeStack (2, 2, 2.5, 2)(10.5)(@#iAttribute); % 8.5
  @#iAttributeStack.iPict.bottom := 2;

  @#iName.ignoreNegativeBase := 1;
  @#iAttributeStack.iPict.ignoreNegativeBase := 1;
enddef;

vardef InstanceInfoCopy@#(text src)=
  metauml_log "InstanceInfoCopy: Copying Instance";

  attributes(@#);
  var(color)   foreColor, borderColor;

  FontInfoCopy.@#nameFont(src.nameFont);

  FontInfoCopy.@#attributeFont(src.attributeFont);

  ShadeInfoCopy.@#iShade(src.iShade);

  @#foreColor := src.foreColor;
  @#borderColor := src.borderColor;

  PictureInfoCopy.@#iName      (src.iName);

  PictureInfoCopy.@#iAttribute (src.iAttribute);
  PictureStackInfoCopy.@#iAttributeStack (src.iAttributeStack);

enddef;

InstanceInfo.iInstance;

%
% Instance
%
vardef defInstance@#(expr pname) =
  ObjectEquations(@#);
  @#className := "Instance";

  string @#name;
  @#name = pname;

  string @#attributes[];
  numeric @#nAttrs;
  @#nAttrs   := 0;
enddef;

vardef Instance_addAttribute@#(expr pcontent) =

  @#.attributes[@#.nAttrs] := pcontent;
  @#.nAttrs := @#.nAttrs + 1;

enddef;

vardef EInstance@#(text _info)(expr name)(text attributes)=
  metauml_log "EInstance begin";
  defInstance@#(name);

  metauml_log "Copying Instance info";
  InstanceInfoCopy.@#info(_info);

  for a = attributes:
    metauml_log "Adding attribute ", a;
    Instance_addAttribute@#(a);
  endfor;
enddef;

vardef Instance@#(expr name)(text attributes)=
  EInstance@#(iInstance)(name)(attributes);
enddef;

vardef Instance_border@#=
  objectBox(@#)
enddef;

vardef Instance_layout@# =
  if @#laidout = 1:
    metauml_log "Instance " & (str @#) & " has already been layed out";
  else:
    @#laidout := 1;
    metauml_log "Instance layout: " & (str @#);

    @#maxFeatureWidth := 0;

    EPicture.@#namePict(@#info.iName)(@#name);
    EPictureStack.@#attributeStack(@#info.iAttributeStack)
       (scantokens listArray(@#attributes)(@#nAttrs))("vleftbase");

    layoutObjects(@#namePict, @#attributeStack);

    @#maxFeatureWidth := lmax(@#namePict.width, @#attributeStack.width) + 1;

    @#namePict.midx = @#midx;

    @#namePict.top = @#top - 1;
    @#attributeStack.top = @#namePict.bottom - 1;

    @#attributeStack.left = @#left;

    @#width = @#maxFeatureWidth;
    @#bottom = @#attributeStack.bottom;

    metauml_log "Layout done...";
  fi;
enddef;

vardef Instance_drawFeatures@#=
  metauml_log "Drawing name";
  drawObject(@#namePict);
  metauml_log "Underlining name";
  pair A, B;
  A := @#namePict.se + (-@#namePict.info.left, @#namePict.info.bottom-1);
  B := @#namePict.sw + (@#namePict.info.right, @#namePict.info.bottom-1);
  draw A--B;
  metauml_log "Drawing attribute stack";
  drawObject(@#attributeStack);

enddef;

vardef Instance_paintSkin@# =
  metauml_log "Painting Instance skin...";

 drawObjectShade(@#);

 fill Instance_border.@# withcolor @#info.foreColor;
 draw Instance_border.@# withcolor @#info.borderColor;

 draw (xpart @#nw, @#attributeStack.top)--(xpart @#se, @#attributeStack.top) withcolor @#info.borderColor;
enddef;

vardef Instance_draw@#=
  metauml_log "draw Instance begin...";
  Instance_layout.@#;
  objectEnsurePositioning.@#;
  Instance_paintSkin.@#;
  Instance_drawFeatures.@#;
enddef;

vardef Instance_setDebugMode@#=
  @#.info.iName.boxed := 1;
  @#.info.iAttributeStack.boxed := 1;
  @#.info.iAttributeStack.iPict.boxed := 1;
enddef;
