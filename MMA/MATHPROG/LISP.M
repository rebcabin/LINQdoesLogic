(* :Title: Lisp in Mathematica *)

(* :Author: Roman E. Maeder *)

(* :Summary:
  Defines the data type of a Lisp list.
*)

(* :Context: MathProg`Lisp` *)

(* :Package Version: 2.0 *)

(* :Copyright: Copyright 1994, Roman E. Maeder.

   Permission is granted to use and distribute this file for any purpose
   except for inclusion in commercial software or program collections.
   This copyright notice must remain intact.
*)

(* :History:
   Version 2.0 for The Mathematica Programmer, Vol. 2, August 1995.
   Version 1.0 for the Mathematica Journal, June 1992.
*)

(* :Keywords: 
  Lisp, car, cdr, cons
*)

(* :Source: 
    Maeder, Roman E. 1992. Abstract Data Types.
        The Mathematica Journal, 2(3).
*)

(* Warning: sets $RecursionLimit to Infinity. *)

(* :Mathematica Version: 3.0 *)

BeginPackage["MathProg`Lisp`"]

cons::usage = "cons[a, b] gives the dotted pair (a .b)."
car::usage = "car[pair] gives the first element of pair."
cdr::usage = "cdr[pair] gives the second element of pair."
list::usage = "list[e1, e2,..., en] gives the Lisp list (e1 e2 ... en)."

nil::usage = "nil is the empty Lisp list."

pairQ::usage = "pairQ[e] is true, if e is a dotted pair."
atomQ::usage = "atomQ[e] is true, if e is an atom."
nullQ::usage = "nullQ[l] is true, if l is the empty list."

Begin["`Private`"]

$RecursionLimit = Infinity (* necessary for long lists *)

(* constructors *)

list[] = nil
list[e_, r___] := cons[e, list[r]]

(* selectors *)

car[cons[e_, l_]] := e
cdr[cons[e_, l_]] := l

(* predicates *)

atomQ[_?AtomQ] = True  (* leave undefined otherwise *)
atomQ[_cons] = False
pairQ[e_] := !atomQ[e]
nullQ[nil] = True
nullQ[_cons] = False

(* output formats *)

listToNest[nil] := {}
listToNest[c_cons] := {car[c], listToNest[cdr[c]]}
listToList[l_] := Flatten[listToNest[l]]

listQ[nil] = True      (* this atom is also a list *)
listQ[l_cons] := listQ[cdr[l]]
listQ[_] = False

Format[nil] = "()"
Format[l_cons?listQ] := SequenceForm["(", Infix[listToList[l], " "], ")"]
Format[l_cons] := SequenceForm["(", Infix[l, " . "], ")"]

(* fix Infix problem for functions with one argument *)

protected = Unprotect[Infix]
Infix[_[e_], h_:Null] := e
Protect[Evaluate[protected]]

End[]

Protect[ car, cdr, cons, pairQ, atomQ, nullQ, list ]

EndPackage[]
