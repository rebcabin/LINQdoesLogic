(* ::Package:: *)

(* :Title: Logic Programming *)

(* :Author: Roman E. Maeder *)

(* :Summary:
  This package provides a subset of Prolog in Mathematica.
*)

(* :Context: MathProg`LogicProgramming` *)

(* :Package Version: 2.0 *)

(* :Copyright: Copyright 1993, Roman E. Maeder.

   Permission is granted to distribute verbatim copies of this package
   together with any of your packages that use it, provided the following
   acknowledgement is printed in a standard place:
 
	"LogicProgramming.m is distributed with permission by Roman E. Maeder."
  
   The newest release of this file is available through MathSource.
*)

(* :History:
   Version 2.0 for The Mathematica Programmer, Vol. 2, August 1995.
   Version 1.0 for the Mathematica Journal, October 1993.
*)

(* :Keywords: 
  Logic Programming, Prolog, Query Evaluation, Backtracking 
*)

(* :Source: 
    Maeder, Roman E.. 1993. Logic Programming I.
        The Mathematica Journal, 4(1).
*)

(* :Mathematica Version: 3.0 *)

(* :Requirement: Unify.m *)
(* :Requirement: Lisp.m *)

(* :Limitation: Prolog-style I/O is not provided. *)
(* :Limitation: Prolog predicates functor, arg, are not provided. *)


BeginPackage["MathProg`LogicProgramming`", "MathProg`Lisp`"]

(* control commands *)

Assert::usage = "Assert[lhs, clauses...] enters a fact or rule into the database."
Asserta::usage = "Asserta[lhs, clauses...] enters a fact or rule
	into the database (at the beginning)."
Assertz::usage = "Assertz[lhs, clauses...] enters a fact or rule
	into the database (at the end)."
Retract::usage = "Retract[ lhs, rhs... ] removes the first matching rule
	from the database."

Query::usage = "Query[goals...] returns variable bindings
	that satisfy the goals."
QueryAll::uage = "QueryAll[goals...] prints all satisfying bindings."
Again::usage = "Again[] tries to re-satisfy the last query."

prolog::usage = "prolog starts a Prolog-style dialogue."

Spy::usage = "Spy[sym] turns on tracing for rules attached to sym."
NoSpy::usage = "NoSpy[sym] turns off tracing for sym. NoSpy[] turns off
	tracing for all symbols."

traceLevel::usage = "traceLevel is the current trace level.
	0 disables all tracing, 2 shows details."

LogicValues::usage = "LogicValues[symbol] is the list of logic rules
	attached to symbol."
rule::usage = "rule[lhs, rhs] is a logic rule. rule[lhs] is a logic fact."

(* logic predicates *)

true::usage  = "true always succeeds."
fail::usage  = "fail fails always."
false::usage = "false fails always."
cut::usage   = "cut succeeds but prevents backtracking."
repeat::usage = "repeat succeeds and can be redone always."

and::usage = "and[goals] succeeds if the goals succeed in sequence."
or::usage = "and[goals] succeeds if one of the goals succeeds."
not::usage = "not[goal] succeeds if goal fails."

Equal::usage = Equal::usage <>
	" lhs == rhs succeeds if lhs and rhs can be unified."
Unequal::usage = Unequal::usage <>
	" lhs == rhs succeeds if lhs and rhs cannot be unified."

print::usage = "print[expr...] prints the expr and succeeds."
input::usage = "input[v_, (prompt)] unifies v with an expression read."
name::usage = "name[v_, l_] succeeds if l is the list
	of character codes of the symbol v."
var::usage = "var[v_] succeeds if v is an uninstantiated variable."
nonvar::usage = "var[v_] succeeds if v is not an uninstantiated variable."
ground::usage = "ground[e_] succeeds if e contains no uninstantiated variables."
integer::usage = "integer[v_] succeeds if v is an integer."
atomic::usage = "atomic[v_] succeeds if v is an atom."
atom::usage = "atom[v_] succeeds is v is an atom other than a number."
is::usage = "is[eqlist] succeeds if the equations can be solved."

assert::usage = "assert[r_] succeeds if rule r was entered into database."
asserta::usage = "asserta[r_] succeeds if rule r was entered
	into database (at the beginning)."
assertz::usage = "assertz[r_] succeeds if rule r was entered
	into database (at the end)."
retract::usage = "retract[r...] succeeds if a rule matching r was
	removed from the database."

run::usage = "run[cmd] evaluates the Mathematica expression cmd and
	succeeds if no messages were produced. run[cmd, res] succeeds
	if the result of cmd is res."
trace::usage = "trace always succeeds and turns on full tracing."
notrace::usage = "notrace always succeeds and turns off full tracing."

(* misc *)

Yes::usage = "Yes indicates a successful query without variables."
No::usage = "No indicates an unsuccessful query."

Logic::nohead = "No predicate found as head of `1`."

Begin["`Private`"]

Needs["MathProg`Unify`"]

dispatch[rule[lhs_, ___]] := predicate[lhs]
predicate[h_Symbol] := h
predicate[h_Symbol[___]] := h
predicate[e_] := (Message[Logic::nohead, e]; Null) (* no predicate *)

makeRule[lhs_] := rule[lhs] /. pattern2Var
makeRule[lhs_, True] := makeRule[lhs]
makeRule[lhs_, rhs_] := rule[lhs, rhs] /. pattern2Var
makeRule[lhs_, rhs__] := makeRule[lhs, And[rhs]]

rename[r_rule] := UniqueVars[r]

Format[rule[lhs_]] := lhs /. var2Pattern
Format[r:rule[_, _]] := Infix[ r /. var2Pattern, " :- " ]

LogicValues[_Symbol] := {} (* for symbols without rules yet *)

(* output variables (disregarding anonymous ones) *)

outVars[expr_] := Select[ variables[expr], FreeQ[#, $]& ]

(* statics *)

`tracing

(* enter a rule into database *)

Assert[ lhs_, rhs___ ]  := insertRule[ makeRule[lhs, rhs], Append ]
Asserta[ lhs_, rhs___ ] := insertRule[ makeRule[lhs, rhs], Prepend ]

insertRule[r_, op_] :=
    With[{h = dispatch[r]},
        If[ h === Null, Return[$Failed] ];
        LogicValues[h] ^= op[ LogicValues[h], r ];
    ]

Assertz = Assert

Retract[ args__ ] :=
    Module[{res},
        res = RemoveOne[ makeRule[args] ];
        If[ res === $Failed, res, Null ]
    ]

RemoveOne[ r_rule ] :=
    Module[{h = dispatch[r], lv, i},
        lv = LogicValues[h];
        For[ i = 1, i <= Length[lv], i++,
            bind = Unify0[ lv[[i]], r ];
            If[ bind === $Failed, Continue[] ];
            LogicValues[h] ^= Drop[lv, {i}];
            Return[bind]
        ];
        $Failed
    ]

(* logic evaluator qeval[goal, state] *)
(* return value is either {bindings, state}, {$Failed, finalState} or $Cut *)

`initialState (* special state the first call of goal *)
`finalState   (* special state if no more backtracking is possible *)
`$Cut	      (* cut encountered, treated mostly like failure *)

noBindings = {}
yes = {noBindings, finalState} (* non-redoable success *)
no = {$Failed, finalState}
nocut = $Cut

bindings[{bind_, _}] := bind
state[{_, state_}] := state
bindings[$Cut] = $Failed
state[$Cut] = finalState

failedQ[res_] := bindings[res] === $Failed
cutQ[$Cut] := True
cutQ[_] = False

finalState/: qeval[ _, finalState ] := no (* speedup, but be careful! *)

qeval[ True, initialState ] := yes
qeval[ False,initialState ] := no
fail/: qeval[ fail, initialState ] := no  (* cannot equate to False *)
true/: qeval[ true, initialState ] := yes (* cannot equate to True  *)

protected = Unprotect[And, Or, Not, Equal, Unequal]

(* And: state is triplet
   {result of first clause, instance of rest, rest state} *)

And/: qeval[ and:And[g1_, goals__], initialState ] :=
    Module[{res},
        res = qeval[g1, initialState]; (* call first one to initialize things *)
        If[ failedQ[res], Return[res] ]; (* failure *)
        qeval[ and, {res, And[goals] //. bindings[res], initialState} ]
    ]

And/: qeval[ And[g1_, goals__], {res10_, rest0_, stater0_} ] :=
    Module[{res1 = res10, rest = rest0, stater = stater0, res, binds},
        While[ True,
            res = qeval[ rest, stater ];
            If[ !failedQ[res],
                binds = closure[bindings[res1], bindings[res]];
                Return[{binds, {res1, rest, state[res]}}];
            ];
            If[ cutQ[res], Return[res] ]; (* no backtracking in this case *)
            (* try first one again *)
            res1 = qeval[g1, state[res1]];
            If[ failedQ[res1], Return[res1] ];
            stater = initialState; (* reset for next attempt *)
            rest = And[goals] //. bindings[res1] (* instantiate *)
        ];
    ]

(* Or: state is  pair {firststate, nextstate} *)

Or/: qeval[ or_Or, initialState ] :=
    qeval[ or, {initialState, initialState} ]

Or/: qeval[ Or[g1_, goals__], {state1_, stater_} ] :=
    Module[{res},
        (* try first clause *)
        res = qeval[g1, state1];
        If[ !failedQ[res],
            Return[{bindings[res], {state[res], initialState}}] ];
        If[ cutQ[res], Return[res] ]; (* no alternatives in this case *)
        (* try rest of them *)
        res = qeval[ Or[goals], stater ];
        If[ failedQ[res], Return[res] ];
        {bindings[res], {finalState, state[res]}} (* don't try first one again *)
    ]

(* Not: state is unused *)

Not/: qeval[Not[g_], initialState ] :=
    If[ failedQ[ qeval[g, initialState] ], yes, no ]

(* equation solving: state is list of remaining solutions *)
(* a solution is already a list of rules! *)

is/: qeval[ t:is[ eq_ ] , initialState ] :=
        qeval[ t, Solve[ eq, variables[eq] ] ]

is/: qeval[ _is , {} ] := no (* no more solutions *)
is/: qeval[ _is , sols_List ] := {First[sols], Rest[sols]}

(* I/O *)

input/: qeval[ input[ v_, prompt_:"? " ], initialState ] :=
    Module[{in},
        in = Input[prompt] /. pattern2Var;
        If[ in === EndOfFile,
            no,
            { Unify0[v, in], initialState } (* can be redone *)
        ]
    ]

print/: qeval[ print[args___], initialState ] := ( Print[args]; yes )

(* equality is unification *)

Equal/: qeval[ e1_ == e2_, initialState ] :=
    Module[{u},
        u = Unify0[e1, e2];
        If[ u === $Failed, no, {u, finalState} ]
        
    ]

(* unequality: non-unification (necessary because of !a==b --> a != b) *)

Unequal/: qeval[ e1_ != e2_, initialState ] :=
        If[ Unify0[e1, e2] === $Failed, yes, no ]

(* name: break atom into characters *)

list2Nest[nil] := {}
list2Nest[c_cons] := {car[c], list2Nest[cdr[c]]}
list2List[l_] := Flatten[list2Nest[l]]
listQ[nil] = True      (* this atom is also a list *)
listQ[l_cons] := listQ[cdr[l]]
listQ[_] = False

name/: qeval[ name[sym_Symbol, l_], initialState ] :=
    Module[{charcodes = ToCharacterCode[ToString[sym]], bind},
        bind = Unify0[list @@ charcodes, l];
        If[ bind === $Failed, no, {bind, finalState} ]
    ]

name/: qeval[ name[v_, l_?listQ], initialState ] :=
    Module[{chars = list2List[l]},
        sym = FromCharacterCode[chars];
        If[ Head[sym] =!= String , Return[no] ];
        sym = ToExpression[sym];
        If[ Head[sym] =!= Symbol , Return[no] ];
        bind = Unify0[v, sym];
        If[ bind === $Failed, no, {bind, finalState} ]
    ]

(* var: if argument is uninstantiated variable *)

var/: qeval[ var[v_Var], initialState ] := yes
var/: qeval[ var[_], _ ] := no

(* ground: no variables *)

ground/: qeval[ ground[expr_], initialState ] :=
    If[ variables[expr] === {}, yes, no ]

(* =.., functor, arg *)

(* assert *)

assert/: qeval[ assert[r___], initialState ] :=
        If[ insertRule[makeRule[r], Append] === $Failed, no, yes ]

asserta/: qeval[ asserta[r___], initialState ] :=
        If[ insertRule[makeRule[r], Prepend] === $Failed, no, yes ]

retract/: qeval[ retract[args___], initialState ] :=
    Module[{r = makeRule[args], bind},
        bind = RemoveOne[r];
        If[ bind === $Failed, no, {bind, initialState} ]
    ]

(* cut *)

cut/: qeval[ cut, initialState ] := {noBindings, cutState} (* success *)
cut/: qeval[ cut, cutState ]     := nocut                  (* fail/cut *)

(* run: evaluate Mathematica expression *)

SetAttributes[run, HoldFirst]

run/: qeval[ run[cmd_], initialState ] :=
    Module[{ret},
        ret = Check[cmd, $Failed];
        If[ ret === $Failed, no, yes ]
    ]

run/: qeval[ run[cmd_, res_], initialState ] :=
    Module[{ret},
        ret = cmd; (* eval it here *)
        {Unify0[ret, res], finalState}
    ]


(* apply rules: state is triplet {rest of rules, instance of first rule, its state} *)

qeval[ expr_, initialState ] :=
    With[{rules = LogicValues[predicate[expr]]},
        If[ Length[rules] == 0, Return[no] ];
        qeval[ expr, {Rest[rules], rename[First[rules]], initialState} ]
    ]

qeval[ expr_, {rules0_, inst0_, rstate0_} ] :=
    Module[{rules = rules0, inst = inst0, rstate = rstate0, res},
        traceGoal[expr];
        While[True,
            res = tryRule[ expr, inst, rstate ];
            If[ !failedQ[res],
                traceGoalYes[expr, bindings[res]];
                Return[{bindings[res], {rules, inst, state[res]}}] ];
            If[ cutQ[res], traceGoalNo[expr, res];
                           Return[no] ]; (* use and discard cut *)
            (* else try next rule *)
            If[ Length[rules] == 0, Break[] ]; (* no more *)
            inst = rename[First[rules]];
            rstate = initialState;
            rules = Rest[rules];
        ];
        traceGoalNo[expr, no];
        no
    ]

(* closed world *)

(* rebcabin 23 Aug 2012: The following line is reordered in recent versions of Mathematica *)
(* and will come before the meaty rules above.  Most queries will get a bogus  *)
(* "no".  It seems that commenting this out suffices to fix the problem. *)
(* qeval[ _, initialState ] := no *)
qeval[ g_, s_ ] := Message[Head[g]::sprd, g, s]

General::sprd = "qeval error: Goal `1` redo attempted without prior init, state is `2`."


(* try a rule: state is {lhs unifier, instance of rhs, state of rhs qeval} *)

finalState/: tryRule[ _, _, finalState ] := no

(* for facts *)

tryRule[ expr_, r:rule[lhs_], initialState ] :=
    Module[{bind, inst, res},
        bind = Unify0[ expr, lhs ];         (* unify lhs *)
        If[ bind === $Failed, Return[no] ]; (* does not unify *)
        bind = closure[bind];
        traceCall[r, True, initialState];
        traceReturn[r, bind];
        {bind, finalState}
    ]

(* for rules proper *)

tryRule[ expr_, r:rule[lhs_, rhs_], initialState ] :=
    Module[{bind, res},
        bind = Unify0[ expr, lhs ];         (* unify lhs *)
        If[ bind === $Failed, Return[no] ]; (* does not unify *)
        tryRule[ expr, r, {bind, rhs //. bind, initialState} ]
    ]

tryRule[ expr_, r_rule, {bind_, inst_, stater_} ] :=
    Module[{res, outbind},
        traceCall[r, inst, stater];
        res = qeval[ inst, stater ]; (* recursion *)
        If[ failedQ[res], traceFail[r]; Return[res] ];
        outbind = closure[bind, bindings[res]];
        traceReturn[r, outbind];
        {outbind, {bind, inst, state[res]}}
    ]

(* trace *)
traceLevel = 1
`traceIndent = 0

traceGoal[expr_] /; traceLevel > 0 && tracing[predicate[expr]] := (
    traceIndent++;
    Print[ spaces[traceIndent], "Goal is ", expr /. var2Pattern ];
    )

traceGoalYes[expr_, bind_] /; traceLevel > 0 && tracing[predicate[expr]] := (
    Print[ spaces[traceIndent], "Yes, with ",
           bindingsFor[bind,  outVars[expr]] /. var2Symbol ];
    traceIndent--;
    )

traceGoalNo[expr_, res_] /; traceLevel > 0 && tracing[predicate[expr]] := (
    Print[ spaces[traceIndent], If[cutQ[res], "No (cut).", "No."] ];
    traceIndent--;
    )

traceCall[r_, new_, s_] /; traceLevel > 1 &&  tracing[dispatch[r]] := (
    traceIndent++;
    Print[ spaces[traceIndent], 
           If[s===initialState, ">call: ", ">redo: "],
           r ];
    If[ new =!= True,
        Print[ spaces[traceIndent], "+new goal: ", new ];
    ]
    )

traceReturn[r_, bind_] /; traceLevel > 1 && tracing[dispatch[r]] := (
    Print[ spaces[traceIndent], "<ret:  ", bind ];
    traceIndent--;
    )

traceFail[r_] /; traceLevel > 1 && tracing[dispatch[r]] := (
    Print[ spaces[traceIndent], "<failed" ];
    traceIndent--;
    )

spyPoints = {};

Spy[ h_Symbol ] :=
    (h/: tracing[h] = True; spyPoints = Union[spyPoints, {h}]; )
NoSpy[ h_Symbol ] :=
    (h/: tracing[h] =. ;spyPoints = Complement[spyPoints, {h}]; )

NoSpy[] := (NoSpy /@ spyPoints;)

tracing[_] := False

spaces[n_] := Nest[# <> " "&, "", 2n]

trace/: qeval[ trace, initialState ] := (tracing[_] := True; yes)
notrace/: qeval[ notrace, initialState ] := (tracing[_] := False; yes)


(* queries user level *)

`redoExpr
`redoState

reset := (
    redoState = finalState;
    traceIndent = 0;
    tracing[_] := False;
    )

Query[ goal_ ] :=
    Module[{g = goal /. pattern2Var},
        reset;
        {redoExpr, redoState} = {g, initialState};
        Again[]
    ]

Query[ goals___ ] := Query[ And[goals] ] (* several goals possible *)

QueryAll[ goal___ ] :=
    Module[{res},
        res = Query[ goal ];
        While[ res =!= No, Print[res]; res = Again[] ];
    ]

Again[] :=
    Module[{res, outbind},
        res = qeval[ redoExpr, redoState ];
        redoState = state[res];
        If[ failedQ[res],
            No
          , 
            outbind = bindingsFor[ bindings[res], outVars[redoExpr] ];
            If[ outbind === noBindings, Yes, outbind /. var2Symbol ]
        ]
    ]


(* more predefined predicates *)

Assert[ nonvar[x_], !var[x_] ]

Assert[ repeat ]
Assert[ repeat, repeat ]

and = And
or = Or
not = Not
assertz = assert
false = fail

(* implemented in terms of Mathematica predicates *)

integer[e_] := IntegerQ[e]
atomic[e_] := AtomQ[e]
atom[e_] := atomic[e] && !NumberQ[e]

(* main loop Prolog-style *)

prompt = "?- "
nl := Print[""]
again := " ?"

prolog :=
    Module[{query},
        While[True,
            query = Input[prompt];
            If[ query === EndOfFile, Break[] ];
            res = Query[ query ];
            WriteString[ $Output, res ];
            While[ res =!= No,
                cont = InputString[again];
                If[ cont =!= ";", Break[] ];
                res = Again[];
                WriteString[ $Output, res ];
            ];
            If[ res === No,  nl ];
            nl;
        ];
    ]

Protect[ Evaluate[protected] ]

End[]

Protect[Evaluate[$Context <> "*"]]
Unprotect[ traceLevel ]

EndPackage[]
