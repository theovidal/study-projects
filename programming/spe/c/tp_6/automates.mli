type afd

type nfa

type 'a regex


val lire_automate : in_channel -> afd

val ecrire_automate : out_channel -> afd -> unit

val ecrire_graphviz : out_channel -> afd -> unit

val parse : string -> int regex

val glushkov : int regex -> nfa

val powerset : nfa -> afd
