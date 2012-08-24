(* :Title: Unification *)

(* :Authors: Stephan Zahner, Roman E. Maeder *)

(* :Summary:
  A simple unificator for Mathematica. Includes support for LogicProgramming.m
*)

(* :Context: MathProg`Unify` *)

(* :Package Version: 2.0 *)

(* :Copyright: Copyright 1993, Roman E. Maeder.

   Permission is granted to use and distribute this file for any purpose
   except for inclusion in commercial software or program collections.
   This copyright notice must remain intact.
  
   The newest release of this file is available through MathSource.
*)

(* :History:
   Version 2.0 for The Mathematica Programmer, Vol. 2, August 1995.
   Version 1.1 for the Mathematica Journal, October 1992.
   Version 1.0 Diploma Thesis, ETH Zurich, Spring 1993.
*)

(* :Keywords: 
  Unification, Pattern Matching 
*)

(* :Mathematica Version: 3.0 *)

(* :Limitation: Does not support AC unification, nor any sequence pattern
   objects. *)
(* :Limitation: The occur check is not implemented. *)


BeginPackage["MathProg`Unify`"];


Var::usage = "Var[x] denotes a variable with name x. Var[x, ...] is used
	for unique instances."

Unify::usage = "Unify[a_, b_] unifies two terms without an occur-check.
	Unify is not an AC-Unifier. x_ denotes a variable.
	The result is a list of rules or $Failed."

Unify0::usage "Unify0 is an internal version of Unify."

pattern2Var::usage = "pattern2Var is a rule converting
	x_ to Var[x] and _ to Var[$, n]. The inverse of var2Pattern"

var2Pattern::usage = "var2Pattern is a rule converting Var[x] to x_.
	It is the inverse of pattern2Var"
var2Symbol::usage = "var2Symbol is a rule converting Var[x] to x."

variables::usage = "variables[e] is the list of all internal variables."
bindingsFor::usage = "bindingsFor[bind, varlist] selects only those bindings
	for variables in varlist and discards others."

UniqueVars::usage = "UniqueVars[expr] make all variables in expr unique."
closure::usage = "closure[bindings] computes the transitive closure of
	the bindings. closure[b1, b2] applies only second set to the first."

$::usage = "$ is the symbol used for anonymous variables."

Begin["`Private`"];

(* definitions of auxiliary functions *)

makerules[$Failed, _, _] = $Failed;
makerules[old_, {}, _] := old
makerules[old_, {fx_, rx___}, {fy_, ry___}] := 
addrule[
        Unify0[fx, fy], 
        old, 
        {rx}, 
        {ry}
       ]
       
addrule[$Failed, _, _, _] = $Failed;
addrule[new_, {}, {}, _] := new
addrule[new_, {}, l1_, l2_] := 
makerules[
          new, 
          l1 /. new, 
          l2 /. new
         ]
addrule[{}, old_, l1_, l2_] := makerules[old, l1, l2]
addrule[new_, old_, {}, _] := Flatten[{old /. new, new}]
addrule[new_, old_, l1_, l2_] := 
makerules[
          Flatten[{old /. new, new}],
          l1 /. new, 
          l2 /. new
         ]

(* definitions of exported functions *)

SetAttributes[Unify0, Orderless]
Unify0[x_, x_] = {};
Unify0[x_, y_Var] := {y -> x}
Unify0[(hx__)[x__], (hy__)[y__]] := 
makerules[
          makerules[{}, {hx}, {hy}], 
          {x},
          {y}
         ] /; Length[{x}] == Length[{y}] 

Unify0[_, _] = $Failed;

Unify[x_, y_] := Unify0[ x /. pattern2Var, y /. pattern2Var ] /. var2Symbol

anon=0 (* counter for unique values *)

pattern2Var = {Verbatim[Pattern][x_, Verbatim[_]] :> Var[x],
               Verbatim[_] :> Var[$, anon++] };

variables[expr_] := Union[ Cases[expr, Var[__], -2] ]

bindingsFor[bindings_, varlist_] :=
    Select[bindings, MemberQ[varlist, First[#]]&]

varcount = 0

UniqueVars[expr_] :=
    With[{id = varcount++}, expr /. Var[x__] :> Var[x, id] ]

closure[bindings_] := # /. (l_ -> r_) :> (l -> (r //. bindings))& /@ bindings

(* apply only second set to first one *)
closure[b1_, b2_] := Join[ # /. (l_ -> r_) :> (l -> (r //. b2))& /@ b1, b2]

var2Pattern = { Var[$, ___] :> _, Var[x_Symbol, ___] :> Pattern @@ {x, _} }

var2Symbol = { Var[x_, ___] :> x }

Format[Var[x_, sub__]] := Subscripted[x[sub]]
Format[Var[x_]] := Pattern @@ {x, _}

End[]

Protect[ Var, Unify, Unify0,
         pattern2Var,  var2Pattern, var2Symbol,
         variables, bindingsFor, UniqueVars, closure
       ]

EndPackage[]
