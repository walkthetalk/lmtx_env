% Copyright 2005 2015 Ovidiu Gheorghies
% Licensed under the Apache License, Version 2.0.

if known _util_picture_mp:
  expandafter endinput
fi;
_util_picture_mp:=1;

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

inputonce util_log;
inputonce util_margins;

if not known boxes_n_cur:
  input boxes;
fi;

vardef FontInfo@#(expr tname, tscale)=
  attributes(@#);
  var(string) className;
  var(string) name;
  var(numeric) scale;

  @#className := "FontInfo";

  @#name := tname;
  @#scale := tscale;
enddef;

vardef FontInfoCopy@#(text fontInfo)=
  FontInfo@#(fontInfo.name, fontInfo.scale);
  @#ignoreNegativeBase := fontInfo.ignoreNegativeBase;
enddef;

vardef FontInfo_toString@#=
  save ret; string ret;
  ret := "FontInfo(" & (str @#) & "): {" & (@#name) & ", " & (decimal @#scale) & "}";
  ret
enddef;

metauml_log "()()() Creating iFont";
FontInfo.iFont(defaultfont, defaultscale);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                 %
%                         PICTURE                                 %
%                                                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

vardef PictureInfo@#(expr pleft, pright, ptop, pbottom)(text pfont)=
  attributes(@#);
  var(string) className;
  @#className := "PictureInfo";

  var(color)   borderColor;
  var(numeric) boxed;

  %% Used to set the base of a text to the natural base of the letters.
  %% If set to '1', 'y' and 'a' will have the same base line, the tail
  %% of 'y' being rendered below that line
  %%
  var(numeric) ignoreNegativeBase;

  %% If these attributes are set to -1, the height and width of the
  %% Picture object is deduced from the dimensions of the contained
  %% object (picture or text). If one of these parameters is set to
  %% a positive value, then the given value is used, regardless of the
  %% size of the contents.
  %%
  var(numeric) fixedWidth, fixedHeight;

  %% Controls how the contents of the picture is to be aligned relatively
  %% to the picture margins. Can be one of "left", "centered", and defaults to
  %% "left". The "centered" setting is useful for Picture-s whose fixedWidth
  %% is set to a given value.
  %%
  var(string) halign, valign;

  var(string) textDecoration;

  @#boxed := 0;
  @#borderColor := blue;

  @#ignoreNegativeBase := 0;

  @#fixedWidth  := -1;
  @#fixedHeight := -1;

  @#halign := "left";
  @#valign := "bottom";

  @#textDecoration := "none";

  Margins.@#(pleft, pright, ptop, pbottom);

  FontInfoCopy.@#iFont(pfont);
enddef;

vardef PictureInfoCopy@#(text src)=
  PictureInfo@#(src.left, src.right, src.top, src.bottom)(src.iFont);

  @#boxed := src.boxed;
  @#borderColor := src.borderColor;
  @#ignoreNegativeBase := src.ignoreNegativeBase;
  @#textDecoration := src.textDecoration;

  @#fixedWidth := src.fixedWidth;
  @#fixedHeight := src.fixedHeight;
  
  @#halign := src.halign;
  @#valign := src.valign;
enddef;

vardef PictureInfo_toString@#=
  save ret; string ret;
  ret := "PictureInfo(" & (str @#) & "): {" & (decimal @#left) & ", " & (decimal @#right) & ", " & (decimal @#top) & ", " & (decimal @#bottom) & "}" & " boxed: " & (decimal @#boxed);
  ret := ret & " Font: " & toString(@#iFont);
  ret
enddef;

PictureInfo.iPict(2, 2, 2, 2)(iFont);
PictureInfo.iPictNoMargins(0, 0, 0, 0)(iFont);

PictureInfoCopy.iPictBoxed(iPict);
iPictBoxed.boxed := 1;

%%
%% Contructs a Picture object by wrapping around the
%% low-level picture thePict.
%%
vardef EPicture@#(text iPict)(expr thePict) =
  ObjectEquations(@#);
  @#className := "Picture";

  var(pair)    contentShift;
  var(picture) pict;
  var(numeric) negativeBase;
  var(string)  contentAsString;
  var(picture) contentAsPicture;

  PictureInfoCopy.@#info(iPict);

  if string thePict:
    metauml_log "Picture " & (str @#) & " is a text";
    @#contentAsString := thePict;
    metauml_log @#contentAsString;
  elseif picture thePict:
    metauml_log "Picture " & (str @#) & " is a native pict";
    @#contentAsPicture := thePict;
    metauml_log @#contentAsPicture;
  else:
    metauml_log "Picture " & (str @#) & " [error]";
  fi;

enddef;

%%
%% Contructs a Picture object by wrapping around the
%% low-level picture thePict.
%%
vardef Picture@#(expr thePict) =
  EPicture@#(iPict)(thePict);
enddef;

%%
%% Lays out the Picture.
%%
vardef Picture_layout@# =
  if @#laidout = 1:
    metauml_log "Picture " & str @# & " already laid out.";
  else:
    metauml_log "Laying out " & (str @#);

    @#laidout := 1;

    if known @#contentAsPicture:
      metauml_log "Content is known to be a picture";
      @#pict = @#contentAsPicture;
    elseif known @#contentAsString:
      metauml_log "Content is known to be a string: " & @#contentAsString;
      if (substring (0,1) of @#info.iFont.name) = "\":
        @#pict = textext.d(@#info.iFont.name & " " & @#contentAsString) scaled @#info.iFont.scale;
      else:
        @#pict = @#contentAsString infont @#info.iFont.name scaled @#info.iFont.scale;
      fi;
    else:
      metauml_log "Show unknown parameter type in picture layout";
      2 = 3; % force an error
    fi;

    @#negativeBase = ypart llcorner @#pict;
    @#negativeBaseX := xpart llcorner @#pict;

    if @#info.ignoreNegativeBase = 0:
      negativeBaseAdjustement__ := 0;
    else:
      negativeBaseAdjustement__ := @#negativeBase;
    fi;

    if @#info.fixedWidth = -1:
      @#width = pictWidth(@#pict) + @#info.left + @#info.right;
    else:
      @#width = @#info.fixedWidth;
    fi;

    if @#info.fixedHeight = -1:
      @#height = pictHeight(@#pict) + @#info.top + @#info.bottom + negativeBaseAdjustement__;
    else:
      @#height = @#info.fixedHeight;
    fi;

    if @#info.halign = "left":
      xdelta__ := @#info.left - @#negativeBaseX;
    elseif @#info.halign = "center":
      xdelta__ := (@#width-pictWidth(@#pict))/2 - @#negativeBaseX;
    else:
      2 = 3; % throw exception illegal value for @#info.halign
    fi;

    if @#info.valign = "bottom":
      ydelta__ := @#info.bottom - @#negativeBase + negativeBaseAdjustement__;
    elseif @#info.valign = "center":
      ydelta__ := (@#height-pictHeight(@#pict))/2 - @#negativeBase + negativeBaseAdjustement__;
    else:
      2 = 3; % throw exception illegal value for @#info.valign
    fi;

    @#contentShift = @#sw + (xdelta__, ydelta__);
  fi;
enddef;

%%
%% Draws the Picture.
%%
vardef Picture_draw@# =
  Picture_layout@#;
  objectEnsurePositioning.@#;
  
  draw @#pict shifted @#contentShift;

  if (@#info.textDecoration = "underline"):
    save ydelta, height;
    height := pictHeight(@#pict) - @#negativeBase;

    ydelta := @#info.bottom - @#negativeBase - 0.8;

    draw @#sw + (@#info.left, ydelta) -- @#se + (-@#info.right, ydelta) withcolor black withpen pencircle scaled 0.2bp;
  fi;

  if (@#info.boxed = 1):
    draw objectBox(@#) withcolor @#info.borderColor;
  fi;
enddef;

vardef Picture_border@#=
    objectBox(@#)
enddef;

vardef aitem(text pictInfo)(text thePict)(text equation)=
  save obj;
  EPicture.obj(pictInfo)(thePict);
  equation;
  drawObject(obj);
enddef;

vardef item@#(text iPict)(text thePict)(text equation)=
  save itemName;
  string itemName;
  itemName := str @#;

  metauml_log "Creating an item with name: '" & itemName & "'";

  if itemName = "":
    metauml_log "Name is empty, creating an anonymous item!";
    aitem(iPict)(thePict)(equation);
  else:
    EPicture@#(iPict)(thePict);
    equation;
    drawObject(@#);
  fi;
enddef;

