% Copyright 2005 2015 Ovidiu Gheorghies
% Licensed under the Apache License, Version 2.0.

if known _util_positioning_mp:
  expandafter endinput
fi;
_util_positioning_mp:=1;

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

%% Gives a point which is below the given @point with the given @value.
%%
def below(expr point, value) =
    (point - (0, value))
enddef;

%% Gives a point which is above the given @point with the given @value.
%%
def above(expr point, value) =
    (point + (0, value))
enddef;

%% Gives a point which is at the right of the given @point with the given @value.
%%
def atright(expr point, value) =
    (point + (value, 0))
enddef;

%% Gives a point which is at the left of the given @point with the given @value.
%%
def atleft(expr point, value) =
    (point - (value, 0))
enddef;

%% Positions the given objects so that they:
%% * have their tops aligned
%% * the distance between the objects is @distance
%% * the center of gravity of the objects (taken on the top line) is at @middlePoint
%%
%%                         @distance
%%              |---------------------------|
%%              |                           |
%%              |          @middlePoint     |
%%    __________|_____________._____________|____________ the same top
%%      [objectA]             |             [objectB]
%%
vardef centered_align_top(suffix objectA, objectB)(expr distance, middlePoint)=
    metauml_log middlePoint;
    objectA.top = objectB.top;
    objectB.left - objectA.right = distance;
    middlePoint = .5[objectB.nw, objectA.ne];
enddef;

%% Deprecated, kept for backward compatibility (align is misspelled).
%%
vardef centered_allign_top(suffix objectA, objectB)(expr distance, middlePoint)=
    metauml_log middlePoint;
    objectA.top = objectB.top;
    objectB.left - objectA.right = distance;
    middlePoint = .5[objectB.nw, objectA.ne];
enddef;

%% theString means here not a sequence of characters but
%% the horizontal or vertical line on which objects are placed.
%% For example, if theString is top, then the objects are
%% "hanging" on a horizontal line, like freshly washed 
%% clothes on a string.

vardef align(suffix theString, extremityNew, extremityOld)
                    (text distanceBetweenObjects)(expr sign)(text objects)=
    string objectsAsString__;
    objectsAsString__ := enumToString(objects)("");
    
    metauml_log "Aligning '" & objectsAsString__ & "' at " & str theString;
    metauml_log sign;
     
    if (objectsAsString__ = ""):
        metauml_log "Nothing to do, bailing out.";
    else:
        string previousObject__;
        previousObject__ := "";
        objectIndex__ := 0;
        
        forsuffixes obj = objects:
            metauml_log "object: " & str obj;
            if objectIndex__ = 0:
                objectIndex__ := objectIndex__ + 1;
                previousObject__ := str obj;
            else:
                objectIndex__ := objectIndex__ + 1;
                
                metauml_log str theString;
                metauml_log str extremityOld;
                metauml_log str extremityNew;
                metauml_log distanceBetweenObjects;
                
                string eqA__, eqB__;
                eqA__ := previousObject__ & "." & str theString & " = " & str obj & "." & str theString;
                
                if (sign = "+"):
                    eqB__ := previousObject__ & "." & str extremityOld & " + " & (str distanceBetweenObjects) & " = " & str obj & "." & str extremityNew;
                    %eqB__ := previousObject__ & "." & str extremityOld & " + distanceBetweenObjects = " & str obj & "." & str extremityNew;
                else:
                    eqB__ := previousObject__ & "." & str extremityOld & " - " & (str distanceBetweenObjects) & " = " & str obj & "." & str extremityNew;
                fi;
                
                metauml_log eqA__, eqB__;
                scantokens eqA__;
                scantokens eqB__;

                previousObject__ := str obj;
            fi;
        endfor;
    fi;
enddef;

vardef leftToRight@#(text distanceBetweenObjects)(text objects)=
    if str @# = "":
        metauml_log "String is empty, aligning to midy";
        align(midy, left, right)(distanceBetweenObjects)("+")(objects);
    else:
        align(@#,   left, right)(distanceBetweenObjects)("+")(objects);
    fi;
enddef;

vardef rightToLeft@#(text distanceBetweenObjects)(text objects)=
    if str @# = "":
        metauml_log "String is empty, aligning to midy";
        align(midy, right, left)(distanceBetweenObjects)("-")(objects);
    else:
        align(@#,   right, left)(distanceBetweenObjects)("-")(objects);
    fi;
enddef;

vardef topToBottom@#(text distanceBetweenObjects)(text objects)=
    if str @# = "":
        metauml_log "String is empty, aligning to midx";
        align(midx, top, bottom)(distanceBetweenObjects)("-")(objects);
    else:
        align(@#,   top, bottom)(distanceBetweenObjects)("-")(objects);
    fi;
enddef;

vardef bottomToTop@#(text distanceBetweenObjects)(text objects)=
    if str @# = "":
        metauml_log "String is empty, aligning to midx";
        align(midx, bottom, top)(distanceBetweenObjects)("+")(objects);
    else:
        align(@#,   bottom, top)(distanceBetweenObjects)("+")(objects);
    fi;
enddef;

%%
%% Defines an equation which sets the given prefix to be equal for all the given objects.
%% For example:
%%
%% same.top(a, b, c);
%%
%% is equivalent to 
%% a.top = b.top = c.top;
%%
vardef same@#(text objects)=
    metauml_log "begin macro: same@#(text objects)=";

    string equation__, property__;
    equation__ := "";
    property__ := str @#;

    objectIndex__ := 0;
    forsuffixes obj = objects:
            metauml_log "object: " & str obj;

            if objectIndex__ = 0:
                objectIndex__ := objectIndex__ + 1;
                equation__ := equation__ & str obj & "." & property__;
            else:
                objectIndex__ := objectIndex__ + 1;
                equation__ := equation__ & "=" & str obj & "." & property__;
            fi;
    endfor;

    equation__ := equation__ & ";";

    metauml_log "Equation is: '" & equation__ & "'";

    if objectIndex__ <= 1:
        metauml_log "One or no objects, nothing to do!";
    else:
        scantokens equation__;
    fi;
enddef;

%% this macro is NOT usable (yet)
vardef leftToRightCentered@#(expr distanceBetweenObjects, middlePoint)(text objects)=
    string objectsAsString__;
    objectsAsString__ := enumToString(objects)("");

    if (objectsAsString__ = ""):
        metauml_log "Nothing to do, bailing out.";
    else:
        metauml_log "ASDFGHJ";
        leftToRight@#(distanceBetweenObjects)(objects);
    
        string firstObject__, lastObject__;
        objectIndex__ := 0;
        forsuffixes obj = objects:
            if objectIndex__ = 0:
                objectIndex__ := objectIndex__ + 1;
                firstObject__ := str obj;
            else:
                objectIndex__ := objectIndex__ + 1;
                lastObject__ := str obj;
            fi;
        endfor;
        
        metauml_log "___";
        .5[authA.nw,authB.ne] = middlePoint;
        metauml_log "___";
        
        string eqCenter__;
        eqCenter__ := ".5[" & firstObject__ & ".nw," & lastObject__ & ".ne] = middlePoint";
        
        metauml_log eqCenter__;
        metauml_log middlePoint;
        
        metauml_log "XXX";
        scantokens eqCenter__;
        metauml_log "XXX";
    fi;
enddef;
