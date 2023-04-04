% Copyright 2005 2015 Ovidiu Gheorghies
% Licensed under the Apache License, Version 2.0.

if known _util_object_mp:
  expandafter endinput
fi;
_util_object_mp:=1;

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

inputonce util_infrastructure;
inputonce util_log;

def ObjectEquations(suffix $)=
  attributes($);
  var(pair) n, ne, e, se, s, sw, w, nw, c;
  var(pair) dim;
  var(numeric) width, height;

  var(numeric) left, right;
  var(numeric) top,  bottom;
  var(numeric) midx, midy;

  var(picture) pict;
  var(string) className;
  var(numeric) expectwidth, expectheight;

  var(numeric) laidout, drawn;

  $.laidout := 0;
  $.drawn := 0;

  $.left  = xpart $.nw = xpart $.sw;
  $.right = xpart $.ne = xpart $.se;

  $.top    = ypart $.ne = ypart $.nw;
  $.bottom = ypart $.se = ypart $.sw;

  $.w = .5[$.nw,$.sw];
  $.s = .5[$.sw,$.se];
  $.e = .5[$.ne,$.se];
  $.n = .5[$.ne,$.nw];

  $.c = .5[$.nw, $.se];

  $.width  = $.right - $.left;
  $.height = $.top - $.bottom;

  $.midx = xpart($.c);
  $.midy = ypart($.c);

  xpart $.dim = $.width;
  ypart $.dim = $.height;

  $.className := "Object";
enddef;

def objectBox(text obj)=
  obj.nw -- obj.ne -- obj.se -- obj.sw -- cycle
enddef;

vardef objectBorder(suffix @#)=
  save methodName;
  string methodName;
  methodName := @#className & "_border";
  metauml_log "objectBorder: invoking " & methodName & " arg=" & str @#;

  scantokens (methodName).@#
enddef;

vardef Object_toString(text obj)=
  save ret; string ret;
  ret := "Generic object";
  ret
enddef;

vardef toString(suffix @#)=
  scantokens (@#className & "_toString").@#
enddef;

vardef layoutObject(suffix @#)=
  save methodName;
  string methodName;
  methodName := @#className & "_layout";
  metauml_log "layoutObject: invoking " & methodName & " arg=" & str @#;

  scantokens (methodName).@#;
enddef;

vardef drawObject(suffix @#)=
  save methodName;
  string methodName;
  methodName := @#className & "_draw";
  metauml_log "drawObject: invoking " & methodName & " arg=" & str @#;

  scantokens (methodName).@#;
enddef;

vardef drawObjectShade(suffix @#)=
  fill objectBorder(@#) shifted
       (@#.info.iShade.shift, -@#.info.iShade.shift) withcolor @#.info.iShade.background;
enddef;

vardef objectEnsurePositioning@#=
    if unknown (xpart @#nw):
    metauml_log "*** WARNING: DEFAULTING OBJECT'S (" & (str @#) & ") x TO 0";
    xpart @#nw = 0;
  fi;
  if unknown (ypart @#nw):
    metauml_log "*** WARNING: DEFAULTING OBJECT'S (" & (str @#) & ") y TO 0";
    ypart @#nw = 0;
  fi;
enddef;

vardef drawObjectAt(suffix @#)(text eq)=
  eq;
  drawObject(@#);
enddef;

vardef layoutObjects(text objects)=
  metauml_log "layoutObjects: begin";
  forsuffixes o = objects:
    if (str o) <> "":
      layoutObject(o);
    fi;
  endfor;
  metauml_log "layoutObjects: end";
enddef;

vardef expectObject(suffix @#)=
  save methodName;
  string methodName;
  methodName := @#className & "_Expect";
  metauml_log "objectBorder: invoking " & methodName & " arg=" & str @#;

  scantokens (methodName).@#
enddef;
vardef expectObjects(text objects)=
  metauml_log "expectObjects: begin";
  forsuffixes o = objects:
    if (str o) <> "":
      expectObject(o);
    fi;
  endfor;
  metauml_log "expectObjects: end";
enddef;

vardef maxExpectSizeOfObjects(text __objects)=
  save __ms;
  pair __ms;
  __ms := (0,0);
  forsuffixes __meso = __objects:
    if (str __meso) <> "":
      __ms := (max(xpart __ms, __meso.info.expectwidth),
               max(ypart __ms, __meso.info.expectheight));
    fi;
  endfor;
  __ms
enddef;

vardef extentToSameWidth(text objects)=
  save __msize, __incw;
  pair __msize;
  numeric __incw;
  expectObjects(objects);
  __msize := maxExpectSizeOfObjects(objects);
  forsuffixes o = objects:
    if (str o) <> "":
      __incw := (xpart __msize - o.info.expectwidth) / 2;
      o.info.left := o.info.left + __incw;
      o.info.right := o.info.right + __incw;
    fi;
  endfor;
enddef;

vardef extentToSameHeight(text objects)=
  save __msize__,__inch;
  pair __msize__;
  numeric __inch;
  expectObjects(objects);
  __msize__ := maxExpectSizeOfObjects(objects);
  forsuffixes o = objects:
    if (str o) <> "":
      __inch := (ypart __msize__ - o.info.expectheight) / 2;
      o.info.top := o.info.top + __inch;
      o.info.bottom := o.info.bottom + __inch;
    fi;
  endfor;
enddef;

vardef drawObjects(text objects)=
  % This needs to be done first in order to allow for equations which define
  % relative positioning to be appropiately solved. Otherwise, for example,
  % object0 may be positioned somewhere by default, and object1 also, leading
  % to inconsitent equations. Inconsistency would have been caused by the fact that the
  % positioning equations become meaningful only after object layout is performed
  % --- but that would have been too late, since the positioning would have been
  % done already to inappropriate values.
  %
  layoutObjects(objects);
  
  forsuffixes o = objects:
    if (str o) <> "":
      drawObject(o);
    fi;
  endfor;
enddef;

%%
%% Joins the given pictures according to the equation given
%% by the pictureDoJoin macro. Note: the pictureDoJoin macro
%% can be conveniently set by calling setPicutureJoin macro.
%%
%% Usage example:
%% joinObjects (p, q, r);
%%
def joinObjects(text pictures)=
  metauml_log "joinObjects: call started.";

  save _index;
  _index := 0;
  forsuffixes p=pictures:
    exitif (str p) = "";
    if _index=0:
      metauml_log "  joinObjects: calling join for first object.";
      metauml_log _index;
      metauml_log p;
      objectDoJoinFirst(p)(_index);
    else:
      metauml_log "  joinObjects: calling join for next object.";
      metauml_log _index;
      metauml_log p;
      objectDoJoin(previousPic, p)(_index);
    fi;

    _index := _index + 1;
    def previousPic=p enddef;
  endfor;
  
  metauml_log "joinObjects: call ended."
enddef;

%%
%% Sets the macro pictureDoJoin, which is used by joinObjects to join
%% one picture into another.
%%
%% The pictureDoJoin macro has two arguments: pa and pb.
%% pa represents the first picture and pb the second picture.
%% The second picture is positioned relatively to pa as specified
%% by the given equation.
%%
%% Usage examples:
%%
%% % place the second picture at the bottom of the first
%% setPictureJoin(pa.sw = pb.nw);
%%
%% % place the second picture at the right of the first
%% setPictureJoin(pa.ne = pb.nw);
%%
def setObjectJoin(text eq)=
  def objectDoJoin(suffix pa, pb)(expr index)=eq; enddef;
  def objectDoJoinFirst(suffix pa)(expr index)= metauml_log "    objectDoJoinFirst: NOP"; enddef;
enddef;

def setObjectJoinFirst(text eq)=
  def objectDoJoinFirst(suffix pa)(expr index)=eq; enddef;
enddef;

%%
%% A shortcut for setting the join equation and actually performing the join.
% 
def joinObjectsEq(text objects)(text eq)=
    setObjectJoin(eq);
    joinObjects(objects);
enddef;


%%
%% Joins the pictures and draws them. A shorthand for
%% the corresponding two macro invocations.
%%
def joinDrawObjects(text pictures)=
  joinObjects(pictures);
  drawObjects(pictures);
enddef;
