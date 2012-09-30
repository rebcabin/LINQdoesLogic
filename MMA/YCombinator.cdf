(* Content-type: application/vnd.wolfram.cdf.text *)

(*** Wolfram CDF File ***)
(* http://www.wolfram.com/cdf *)

(* CreatedBy='Mathematica 8.0' *)

(*************************************************************************)
(*                                                                       *)
(*  The Mathematica License under which this file was created prohibits  *)
(*  restricting third parties in receipt of this file from republishing  *)
(*  or redistributing it by any means, including but not limited to      *)
(*  rights management or terms of use, without the express consent of    *)
(*  Wolfram Research, Inc.                                               *)
(*                                                                       *)
(*************************************************************************)

(*CacheID: 234*)
(* Internal cache information:
NotebookFileLineBreakTest
NotebookFileLineBreakTest
NotebookDataPosition[       835,         17]
NotebookDataLength[     17217,        593]
NotebookOptionsPosition[     15659,        524]
NotebookOutlinePosition[     16163,        544]
CellTagsIndexPosition[     16120,        541]
WindowFrame->Normal*)

(* Beginning of Notebook Content *)
Notebook[{

Cell[CellGroupData[{
Cell["\<\
Remotable Recursion from Scratch\
\>", "Title"],

Cell["\<\
Brian Beckman
30 Sept 2012\
\>", "Subtitle"],

Cell["\<\
Consider the following definition of factorial using self-application for \
recursion. This is adequate; we can stop here if all you care about is a \
programming pattern for remotable recursive functions, but there are several \
worthwhile improvements below.\
\>", "Text"],

Cell[CellGroupData[{

Cell[BoxData[
 RowBox[{
  RowBox[{
   RowBox[{"(", 
    RowBox[{
     StyleBox["f",
      Background->RGBColor[1, 1, 0]], "\[Function]", 
     RowBox[{"n", "\[Function]", 
      RowBox[{"If", "[", 
       RowBox[{
        RowBox[{"n", "\[Equal]", "0"}], ",", "1", ",", 
        RowBox[{"n", " ", 
         RowBox[{
          StyleBox[
           RowBox[{"f", "[", "f", "]"}],
           Background->RGBColor[1, 1, 0]], "[", 
          RowBox[{"n", "-", "1"}], "]"}]}]}], "]"}]}]}], ")"}], "[", 
   "\[IndentingNewLine]", 
   RowBox[{
    StyleBox["f",
     Background->RGBColor[1, 1, 0]], "\[Function]", 
    RowBox[{"n", "\[Function]", 
     RowBox[{"If", "[", 
      RowBox[{
       RowBox[{"n", "\[Equal]", "0"}], ",", "1", ",", 
       RowBox[{"n", " ", 
        RowBox[{
         StyleBox[
          RowBox[{"f", "[", "f", "]"}],
          Background->RGBColor[1, 1, 0]], "[", 
         RowBox[{"n", "-", "1"}], "]"}]}]}], "]"}]}]}], "]"}], "@", 
  "6"}]], "Input"],

Cell[BoxData["720"], "Output"]
}, Open  ]],

Cell[TextData[{
 "Let's calculate how this works. Let ",
 StyleBox["F", "Input"],
 " stand for ",
 StyleBox["f\[Function]n\[Function]If[n\[Equal]0,1,n f[f][n-1]]", "Input"],
 ". Applying functions from the outside-in, in one step we get"
}], "Text"],

Cell[TextData[StyleBox["(n\[Function]If[n==0,1,n F[F][n-1])@6", "Input"]], \
"Text"],

Cell[TextData[{
 "which reduces in the next step to ",
 StyleBox["If[6==0,1,6*F[F][5]]", "Input"],
 ", then to ",
 StyleBox["6*F[F][5]", "Input"],
 " or ",
 StyleBox["6*F[F]@5", "Input"],
 ", leaving us with a multiplication, one term of which is back where we \
started, just with a new numerical argument. This process will repeat, \
building the multiplication expression, until eventually ",
 StyleBox["n==0", "Input"],
 " evaluates to ",
 StyleBox["True", "Input"],
 " and we get a ",
 StyleBox["1", "Input"],
 " instead of another ",
 StyleBox["F[F]", "Input"],
 ". At that time, the multiplications will rattle out."
}], "Text"],

Cell[CellGroupData[{

Cell["\<\
Three Improvements: Two Abstractions and One Model\
\>", "Subsection"],

Cell[TextData[{
 "Let's make a combinator (a function of a function) that can convert any \
function into a function that receives its self application as its first \
argument. In other words, let's abstract out the self application ",
 StyleBox["f[f]", "Input"],
 " that appears inside the subject code -- the code that does the particular \
work of computing the factorial in our example -- and perform the self \
application generally, outside the subject code. Then we can abstract the \
subject code itself into a parameter of the desired, general combinator."
}], "Text"]
}, Open  ]],

Cell[CellGroupData[{

Cell["\<\
Abstract the Internal Self-Application\
\>", "Subsection"],

Cell[TextData[{
 "It's straightforward to pull ",
 StyleBox["f[f]", "Input"],
 " into a parameter ",
 StyleBox["k", "Input"],
 " and then apply the resulting abstraction to ",
 StyleBox["f[f]", "Input"],
 ", but it spins:"
}], "Text"],

Cell[CellGroupData[{

Cell[BoxData[
 RowBox[{
  RowBox[{
   RowBox[{"(", 
    RowBox[{"f", "\[Function]", 
     RowBox[{
      RowBox[{"(", 
       RowBox[{
        StyleBox["k",
         Background->RGBColor[1, 1, 0]], "\[Function]", 
        RowBox[{"n", "\[Function]", 
         RowBox[{"If", "[", 
          RowBox[{
           RowBox[{"n", "\[Equal]", "0"}], ",", "1", ",", 
           RowBox[{"n", " ", 
            RowBox[{
             StyleBox["k",
              Background->RGBColor[1, 1, 0]], "[", 
             RowBox[{"n", "-", "1"}], "]"}]}]}], "]"}]}]}], ")"}], "[", 
      StyleBox[
       RowBox[{"f", "[", "f", "]"}],
       Background->RGBColor[1, 1, 0]], "]"}]}], ")"}], "[", 
   "\[IndentingNewLine]", 
   RowBox[{"f", "\[Function]", 
    RowBox[{
     RowBox[{"(", 
      RowBox[{
       StyleBox["k",
        Background->RGBColor[1, 1, 0]], "\[Function]", 
       RowBox[{"n", "\[Function]", 
        RowBox[{"If", "[", 
         RowBox[{
          RowBox[{"n", "\[Equal]", "0"}], ",", "1", ",", 
          RowBox[{"n", " ", 
           RowBox[{
            StyleBox["k",
             Background->RGBColor[1, 1, 0]], "[", 
            RowBox[{"n", "-", "1"}], "]"}]}]}], "]"}]}]}], ")"}], "[", 
     StyleBox[
      RowBox[{"f", "[", "f", "]"}],
      Background->RGBColor[1, 1, 0]], "]"}]}], "]"}], "@", "6"}]], "Input"],

Cell[BoxData[
 RowBox[{
  StyleBox[
   RowBox[{"$RecursionLimit", "::", "reclim"}], "MessageName"], 
  RowBox[{
  ":", " "}], "\<\"Recursion depth of \[NoBreak]\\!\\(256\\)\[NoBreak] \
exceeded. \\!\\(\\*ButtonBox[\\\"\[RightSkeleton]\\\", \
ButtonStyle->\\\"Link\\\", ButtonFrame->None, \
ButtonData:>\\\"paclet:ref/message/$RecursionLimit/reclim\\\", ButtonNote -> \
\\\"$RecursionLimit::reclim\\\"]\\)\"\>"}]], "Message", "MSG"],

Cell[BoxData[
 RowBox[{
  StyleBox[
   RowBox[{"$RecursionLimit", "::", "reclim"}], "MessageName"], 
  RowBox[{
  ":", " "}], "\<\"Recursion depth of \[NoBreak]\\!\\(256\\)\[NoBreak] \
exceeded. \\!\\(\\*ButtonBox[\\\"\[RightSkeleton]\\\", \
ButtonStyle->\\\"Link\\\", ButtonFrame->None, \
ButtonData:>\\\"paclet:ref/message/$RecursionLimit/reclim\\\", ButtonNote -> \
\\\"$RecursionLimit::reclim\\\"]\\)\"\>"}]], "Message", "MSG"],

Cell[BoxData["720"], "Output"]
}, Open  ]],

Cell[TextData[{
 "Why? As before, let's calculate how this works. Let ",
 StyleBox["F", "Input"],
 " stand for ",
 StyleBox["f\[Function](k\[Function]n\[Function]If[n\[Equal]0,1,n \
k[n-1]])[f[f]]", "Input"],
 ". Applying functions from the outside-in, in one step, we get"
}], "Text"],

Cell[TextData[StyleBox["(k\[Function]n\[Function]If[n==0,1,n k[n-1]])[F[F]]", \
"Input"]], "Text"],

Cell[TextData[{
 "In the next step, we evaluate ",
 StyleBox["F[F]", "Input"],
 " in preparation for substituting its value for ",
 StyleBox["k", "Input"],
 ", but that's too early. We need to do the test inside the ",
 StyleBox["If", "Input"],
 " before we evaluate the self-application ",
 StyleBox["F[F]", "Input"],
 ". Every recursive function will have some kind of test and bottom case \
wherein it does not recurse, so this need is general. "
}], "Text"],

Cell[TextData[{
 "We can delay the evaluation of the self application ",
 StyleBox["F[F]", "Input"],
 " by making the actual argument of the function-of-",
 StyleBox["k", "Input"],
 " ",
 StyleBox["n\[Function]f[f][n]", "Input"],
 " instead of ",
 StyleBox["f[f]", "Input"],
 ". These two expressions always have the same value when applied to an \
argument, they just evaluate the self application ",
 StyleBox["f[f]", "Input"],
 " at different times. In the first case, ",
 StyleBox["f[f]", "Input"],
 " gets evaluated when ",
 StyleBox["n\[Function]f[f][n]", "Input"],
 " is applied to an argument. In the second case, ",
 StyleBox["f[f]", "Input"],
 " gets evaluated immediately when its seen."
}], "Text"],

Cell["\<\
We note in passing that in lazy languages like Haskell, this step is \
automatic because evaluation of all expressions is always delayed.\
\>", "Text"],

Cell[TextData[{
 "But here, we just rewrite the above with ",
 StyleBox["n\[Function]f[f][n]", "Input"],
 " in place of ",
 StyleBox["f[f]", "Input"],
 "."
}], "Text"],

Cell[CellGroupData[{

Cell[BoxData[
 RowBox[{
  RowBox[{
   RowBox[{"(", 
    RowBox[{"f", "\[Function]", 
     RowBox[{"n", "\[Function]", 
      RowBox[{"If", "[", 
       RowBox[{
        RowBox[{"n", "\[Equal]", "0"}], ",", "1", ",", 
        RowBox[{"n", " ", 
         RowBox[{
          RowBox[{"(", 
           StyleBox[
            RowBox[{"n", "\[Function]", 
             RowBox[{
              RowBox[{"f", "[", "f", "]"}], "[", "n", "]"}]}],
            Background->RGBColor[1, 1, 0]], ")"}], "[", 
          RowBox[{"n", "-", "1"}], "]"}]}]}], "]"}]}]}], ")"}], "[", 
   "\[IndentingNewLine]", 
   RowBox[{"f", "\[Function]", 
    RowBox[{"n", "\[Function]", 
     RowBox[{"If", "[", 
      RowBox[{
       RowBox[{"n", "\[Equal]", "0"}], ",", "1", ",", 
       RowBox[{"n", " ", 
        RowBox[{
         RowBox[{"(", 
          StyleBox[
           RowBox[{"n", "\[Function]", 
            RowBox[{
             RowBox[{"f", "[", "f", "]"}], "[", "n", "]"}]}],
           Background->RGBColor[1, 1, 0]], ")"}], "[", 
         RowBox[{"n", "-", "1"}], "]"}]}]}], "]"}]}]}], "]"}], "@", 
  "6"}]], "Input"],

Cell[BoxData["720"], "Output"]
}, Open  ]],

Cell[TextData[{
 "Abstract ",
 StyleBox["n\[Function]f[f][n]", "Input"],
 " into a parameter ",
 StyleBox["k", "Input"],
 " of a new lambda:"
}], "Text"],

Cell[CellGroupData[{

Cell[BoxData[
 RowBox[{
  RowBox[{
   RowBox[{"(", 
    RowBox[{"f", "\[Function]", 
     RowBox[{
      RowBox[{"(", 
       RowBox[{
        StyleBox["k",
         Background->RGBColor[1, 1, 0]], "\[Function]", 
        RowBox[{"n", "\[Function]", 
         RowBox[{"If", "[", 
          RowBox[{
           RowBox[{"n", "\[Equal]", "0"}], ",", "1", ",", 
           RowBox[{"n", " ", 
            RowBox[{
             StyleBox["k",
              Background->RGBColor[1, 1, 0]], "[", 
             RowBox[{"n", "-", "1"}], "]"}]}]}], "]"}]}]}], ")"}], "[", 
      "\[IndentingNewLine]", 
      StyleBox[
       RowBox[{"n", "\[Function]", 
        RowBox[{
         RowBox[{"f", "[", "f", "]"}], "[", "n", "]"}]}],
       Background->RGBColor[1, 1, 0]], "]"}]}], ")"}], "[", 
   RowBox[{"f", "\[Function]", 
    RowBox[{
     RowBox[{"(", 
      RowBox[{
       StyleBox["k",
        Background->RGBColor[1, 1, 0]], "\[Function]", 
       RowBox[{"n", "\[Function]", 
        RowBox[{"If", "[", 
         RowBox[{
          RowBox[{"n", "\[Equal]", "0"}], ",", "1", ",", 
          RowBox[{"n", " ", 
           RowBox[{
            StyleBox["k",
             Background->RGBColor[1, 1, 0]], "[", 
            RowBox[{"n", "-", "1"}], "]"}]}]}], "]"}]}]}], ")"}], "[", 
     "\[IndentingNewLine]", 
     StyleBox[
      RowBox[{"n", "\[Function]", 
       RowBox[{
        RowBox[{"f", "[", "f", "]"}], "[", "n", "]"}]}],
      Background->RGBColor[1, 1, 0]], "]"}]}], "]"}], "@", "6"}]], "Input"],

Cell[BoxData["720"], "Output"]
}, Open  ]]
}, Open  ]],

Cell[CellGroupData[{

Cell["Abstract the Subject Code", "Subsection"],

Cell[TextData[{
 "The abstraction on ",
 StyleBox["k", "Input"],
 " now completely and minimally captures the subject code: ",
 StyleBox["s = k\[Function]n\[Function]If[n\[Equal]0,1,n k[n-1]]", "Input"],
 ". Haul that out and we're just about done, except for one cosmetic step."
}], "Text"],

Cell[CellGroupData[{

Cell[BoxData[
 RowBox[{
  RowBox[{
   RowBox[{"(", 
    RowBox[{
     StyleBox["s",
      Background->RGBColor[1, 1, 0]], "\[Function]", 
     RowBox[{
      RowBox[{"(", 
       RowBox[{"f", "\[Function]", 
        RowBox[{
         StyleBox["s",
          Background->RGBColor[1, 1, 0]], "[", 
         RowBox[{"n", "\[Function]", 
          RowBox[{
           RowBox[{"f", "[", "f", "]"}], "[", "n", "]"}]}], "]"}]}], ")"}], 
      "[", 
      RowBox[{"f", "\[Function]", 
       RowBox[{
        StyleBox["s",
         Background->RGBColor[1, 1, 0]], "[", 
        RowBox[{"n", "\[Function]", 
         RowBox[{
          RowBox[{"f", "[", "f", "]"}], "[", "n", "]"}]}], "]"}]}], "]"}]}], 
    ")"}], "[", "\[IndentingNewLine]", 
   StyleBox[
    RowBox[{"k", "\[Function]", 
     RowBox[{"n", "\[Function]", 
      RowBox[{"If", "[", 
       RowBox[{
        RowBox[{"n", "\[Equal]", "0"}], ",", "1", ",", 
        RowBox[{"n", " ", 
         RowBox[{
          StyleBox["k",
           Background->RGBColor[1, 1, 0]], "[", 
          RowBox[{"n", "-", "1"}], "]"}]}]}], "]"}]}]}],
    Background->RGBColor[1, 1, 0]], "]"}], "@", "6"}]], "Input"],

Cell[BoxData["720"], "Output"]
}, Open  ]]
}, Open  ]],

Cell[CellGroupData[{

Cell["\<\
Model the External Self-Application\
\>", "Subsection"],

Cell["\<\
This is a convenience step that minimizes repetition.\
\>", "Text"],

Cell[CellGroupData[{

Cell[BoxData[
 RowBox[{
  RowBox[{
   RowBox[{"(", 
    RowBox[{"s", "\[Function]", 
     RowBox[{
      RowBox[{"(", 
       StyleBox[
        RowBox[{"g", "\[Function]", 
         RowBox[{"g", "@", "g"}]}],
        Background->RGBColor[1, 1, 0]], ")"}], "[", 
      RowBox[{"f", "\[Function]", 
       RowBox[{"s", "[", 
        RowBox[{"n", "\[Function]", 
         RowBox[{
          RowBox[{"f", "[", "f", "]"}], "[", "n", "]"}]}], "]"}]}], "]"}]}], 
    ")"}], "[", "\[IndentingNewLine]", 
   RowBox[{"k", "\[Function]", 
    RowBox[{"n", "\[Function]", 
     RowBox[{"If", "[", 
      RowBox[{
       RowBox[{"n", "\[Equal]", "0"}], ",", "1", ",", 
       RowBox[{"n", " ", 
        RowBox[{
         StyleBox["k",
          Background->RGBColor[1, 1, 0]], "[", 
         RowBox[{"n", "-", "1"}], "]"}]}]}], "]"}]}]}], "]"}], "@", 
  "6"}]], "Input"],

Cell[BoxData["720"], "Output"]
}, Open  ]],

Cell["\<\
We can now apply the outer combinator to a different famous recursive \
function as subject code:\
\>", "Text"],

Cell[CellGroupData[{

Cell[BoxData[
 RowBox[{
  RowBox[{
   RowBox[{"(", 
    StyleBox[
     RowBox[{"s", "\[Function]", 
      RowBox[{
       RowBox[{"(", 
        StyleBox[
         RowBox[{"g", "\[Function]", 
          RowBox[{"g", "@", "g"}]}],
         Background->RGBColor[1, 1, 0]], ")"}], "[", 
       RowBox[{"f", "\[Function]", 
        RowBox[{"s", "[", 
         RowBox[{"n", "\[Function]", 
          RowBox[{
           RowBox[{"f", "[", "f", "]"}], "[", "n", "]"}]}], "]"}]}], "]"}]}],
     Background->RGBColor[1, 1, 0]], ")"}], "[", "\[IndentingNewLine]", 
   RowBox[{"k", "\[Function]", 
    RowBox[{"n", "\[Function]", 
     RowBox[{"If", "[", 
      RowBox[{
       RowBox[{"n", "<", "2"}], ",", "1", ",", 
       RowBox[{
        RowBox[{"k", "[", 
         RowBox[{"n", "-", "2"}], "]"}], "+", 
        RowBox[{
         StyleBox["k",
          Background->RGBColor[1, 1, 0]], "[", 
         RowBox[{"n", "-", "1"}], "]"}]}]}], "]"}]}]}], "]"}], "@", 
  "6"}]], "Input"],

Cell[BoxData["13"], "Output"]
}, Open  ]]
}, Open  ]]
}, Open  ]]
},
WindowSize->{720, 852},
WindowMargins->{{0, Automatic}, {4, Automatic}},
PrintingCopies->1,
PrintingPageRange->{Automatic, Automatic},
Magnification->1.5,
FrontEndVersion->"8.0 for Mac OS X x86 (32-bit, 64-bit Kernel) (July 22, \
2012)",
StyleDefinitions->FrontEnd`FileName[{"Creative"}, "NaturalColor.nb", 
  CharacterEncoding -> "UTF-8"]
]
(* End of Notebook Content *)

(* Internal cache information *)
(*CellTagsOutline
CellTagsIndex->{}
*)
(*CellTagsIndex
CellTagsIndex->{}
*)
(*NotebookFileOutline
Notebook[{
Cell[CellGroupData[{
Cell[1257, 32, 57, 2, 152, "Title"],
Cell[1317, 36, 54, 3, 54, "Subtitle"],
Cell[1374, 41, 284, 5, 107, "Text"],
Cell[CellGroupData[{
Cell[1683, 50, 970, 31, 79, "Input"],
Cell[2656, 83, 30, 0, 55, "Output"]
}, Open  ]],
Cell[2701, 86, 249, 6, 84, "Text"],
Cell[2953, 94, 84, 1, 39, "Text"],
Cell[3040, 97, 635, 18, 152, "Text"],
Cell[CellGroupData[{
Cell[3700, 119, 80, 2, 51, "Subsection"],
Cell[3783, 123, 577, 9, 197, "Text"]
}, Open  ]],
Cell[CellGroupData[{
Cell[4397, 137, 68, 2, 51, "Subsection"],
Cell[4468, 141, 234, 8, 62, "Text"],
Cell[CellGroupData[{
Cell[4727, 153, 1322, 40, 102, "Input"],
Cell[6052, 195, 431, 9, 32, "Message"],
Cell[6486, 206, 431, 9, 32, "Message"],
Cell[6920, 217, 30, 0, 55, "Output"]
}, Open  ]],
Cell[6965, 220, 285, 7, 84, "Text"],
Cell[7253, 229, 98, 1, 39, "Text"],
Cell[7354, 232, 461, 11, 129, "Text"],
Cell[7818, 245, 710, 19, 174, "Text"],
Cell[8531, 266, 161, 3, 62, "Text"],
Cell[8695, 271, 167, 6, 62, "Text"],
Cell[CellGroupData[{
Cell[8887, 281, 1099, 33, 102, "Input"],
Cell[9989, 316, 30, 0, 55, "Output"]
}, Open  ]],
Cell[10034, 319, 153, 6, 39, "Text"],
Cell[CellGroupData[{
Cell[10212, 329, 1500, 45, 125, "Input"],
Cell[11715, 376, 30, 0, 55, "Output"]
}, Open  ]]
}, Open  ]],
Cell[CellGroupData[{
Cell[11794, 382, 47, 0, 51, "Subsection"],
Cell[11844, 384, 291, 6, 84, "Text"],
Cell[CellGroupData[{
Cell[12160, 394, 1152, 36, 102, "Input"],
Cell[13315, 432, 30, 0, 55, "Output"]
}, Open  ]]
}, Open  ]],
Cell[CellGroupData[{
Cell[13394, 438, 65, 2, 51, "Subsection"],
Cell[13462, 442, 77, 2, 39, "Text"],
Cell[CellGroupData[{
Cell[13564, 448, 857, 27, 79, "Input"],
Cell[14424, 477, 30, 0, 55, "Output"]
}, Open  ]],
Cell[14469, 480, 121, 3, 62, "Text"],
Cell[CellGroupData[{
Cell[14615, 487, 972, 30, 79, "Input"],
Cell[15590, 519, 29, 0, 55, "Output"]
}, Open  ]]
}, Open  ]]
}, Open  ]]
}
]
*)

(* End of internal cache information *)

(* NotebookSignature hwDMnqtIH3tFpAgaN7tTxIBD *)
