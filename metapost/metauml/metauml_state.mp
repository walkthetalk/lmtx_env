% Copyright 2005 2015 Ovidiu Gheorghies
% Licensed under the Apache License, Version 2.0.

if known _metauml_state_mp:
  expandafter endinput
fi;
_metauml_state_mp:=1;

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

vardef StateInfo@#=
  attributes(@#);
  var(color)   foreColor, borderColor;
  var(numeric) round;

  FontInfo.@#iFont(metauml_defaultFont, defaultscale);
  @#iFont.ignoreNegativeBase := 1;

  PictureInfo.@#iText  (2, 2, 2, 2)(@#iFont);
  PictureStackInfo.@#iStack (2, 2, 2, 2)(9)(@#iText);

  @#iStack.iPict.ignoreNegativeBase := 1;

  Margins.@#(2,2,0,6);
  
  GroupInfo.@#iGroupSubstates(2, 2, 4, 2);
  
  @#round := 5;
  @#drawNameLine := 0;

  ShadeInfo.@#iShade;
  @#foreColor := .9white;
  @#borderColor := black;
enddef;

vardef StateInfoCopy@#(text src)=
  metauml_log "StateInfoCopy: Copying state info";
  attributes(@#);
  var(color)   foreColor, borderColor;
  var(numeric) round;

  PictureStackInfoCopy.@#iStack (src.iStack);
  MarginsCopy.@#(src);
  @#round := src.round;
  @#drawNameLine := src.drawNameLine;

  GroupInfoCopy.@#iGroupSubstates(src.iGroupSubstates);
  
  ShadeInfoCopy.@#iShade(src.iShade);
  @#foreColor := src.foreColor;
  @#borderColor := src.borderColor;
enddef;

StateInfo.iState;

vardef State@#(text contents)(text _substates)=
  EState.@#(iState)(contents)(_substates);
enddef;

vardef EState@#(text _info)(text contents)(text _substates)=
  ObjectEquations(@#);
  @#className := "State";

  StateInfoCopy.@#info(_info);

  numeric @#nLines; @#nLines := 0;
  string @#lines[];

  numeric @#nInternalTransitions; @#nInternalTransitions := 0;
  string @#internalTransitions[];

  for l=contents:
    @#lines[@#nLines] := l;
    @#nLines := @#nLines + 1;
  endfor;

  EGroup.@#substates(@#info.iGroupSubstates)(_substates);
  %@#substates.info.boxed := 1;

  EPictureStack.@#stack(@#info.iStack)(scantokens listArray(@#lines)(@#nLines))("vcenterbase");
enddef;

vardef stateTransitions@#(text transitions)=
  State_internalTransitions@#(transitions);
enddef;

vardef State_internalTransitions@#(text transitions)=
  for transition=transitions:
    @#internalTransitions[@#nInternalTransitions] := transition;
    @#nInternalTransitions := @#nInternalTransitions + 1;
  endfor;
enddef;

vardef State_layout@#=
  if @#laidout = 1:
    metauml_log "State '" & (str @#) & "' has already been layed out";
  else:
    @#laidout := 1;
    metauml_log "State layout: '" & (str @#) & "'";

    EPictureStack.@#internalTransitionsStack(@#info.iStack)
       (scantokens listArray(@#internalTransitions)(@#nInternalTransitions))("vleftbase");

    metauml_log "State name layout '" & (str @#) & "'...";
    PictureStack_layout.@#stack;
    metauml_log "Internal transitions layout '" & (str @#) & "'...";
    PictureStack_layout.@#internalTransitionsStack;
    metauml_log "Substates layout '" & (str @#) & "'...";
    Group_layout.@#substates;

    metauml_log "All elements in state '" & (str @#) & "' successfully layed out, integrating...";

%    @#internalTransitionsStack.info.boxed := 1;

    @#contentWidth = lmax(@#stack.width, @#internalTransitionsStack.width, @#substates.width);

    @#width = @#contentWidth + @#info.left + @#info.right + 2 * @#info.round;
    @#height = @#stack.height + @#info.top + @#info.bottom +
               @#internalTransitionsStack.height + @#substates.height;

    @#stack.n = @#n + (0, -@#info.top);
    @#substates.n = @#stack.s;

    @#internalTransitionsStack.sw = @#sw + (@#info.round, @#info.round);

    attributes(@#);
    var(pair) urt, lrt, ulft, llft;
    var(pair) urta, lrta, ulfta, llfta;
    var(pair) urtb, lrtb, ulftb, llftb;

    @#urta := @#ne - (@#info.round, 0);
    @#urtb := @#ne - (0, @#info.round);

    @#lrta := @#se + (0, @#info.round);
    @#lrtb := @#se - (@#info.round, 0);

    @#ulfta := @#nw - (0, @#info.round);
    @#ulftb := @#nw + (@#info.round, 0);

    @#llfta := @#sw + (@#info.round, 0);
    @#llftb := @#sw + (0, @#info.round);

    @#urt := @#ne - (@#info.round, @#info.round) + @#info.round * (sind(45),cosd(45));
    @#lrt := @#se + (-@#info.round, @#info.round) + @#info.round * (sind(135),cosd(135));
    @#llft := @#sw + (@#info.round, @#info.round) + @#info.round * (sind(225),cosd(225));
    @#ulft := @#nw + (@#info.round, -@#info.round) + @#info.round * (sind(315),cosd(315));

    var(pair) nameLineLeft, nameLineRight;
    ypart @#nameLineLeft = ypart @#nameLineRight = @#stack.bottom;
    xpart @#nameLineLeft = xpart @#nw;
    xpart @#nameLineRight = xpart @#ne;

    metauml_log "State layout for " & (str @#) & " ended.";
  fi;
enddef;

vardef State_draw@#=
  State_layout.@#;
  objectEnsurePositioning.@#;

  attributes(@#);
  var(path) border;

  @#border := @#urta .. @#urt .. @#urtb -- %
              @#lrta .. @#lrt .. @#lrtb -- %
              @#llfta .. @#llft .. @#llftb -- %
          @#ulfta .. @#ulft .. @#ulftb -- cycle;

  %fill @#border shifted (@#info.shade, -@#info.shade) withcolor .7white;
   drawObjectShade(@#);

   fill @#border withcolor @#info.foreColor;
   draw @#border withcolor @#info.borderColor;


  drawObject(@#internalTransitionsStack);
  drawObject(@#stack);
  drawObject(@#substates);

  if @#info.drawNameLine = 1:
    draw @#nameLineLeft -- @#nameLineRight;
  fi;
enddef;

vardef State_border@#=
  @#border
enddef;

