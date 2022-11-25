type ('key, 'prio) t

val create : unit -> ('key, 'prio) t

val length : ('key, 'prio) t -> int

(* membership test *)
val mem : ('key, 'prio) t -> 'key -> bool

val get_min : ('key, 'prio) t -> ('key * 'prio) option

(* Only valid if the key is not present in the heap *)
val insert : ('key, 'prio) t -> ('key * 'prio) -> unit

(* Only valid if the key is already present in the heap, *)
(* and if the new priority is less than the old one *)
val decrease_priority : ('key, 'prio) t -> ('key * 'prio) -> unit

(* Valid whether or not the key is already in the heap *)
(* If it is already there, the new priority must be less *)
(* than the old one. *)
val insert_or_decrease : ('key, 'prio) t -> ('key * 'prio) -> unit

val extract_min : ('key, 'prio) t -> ('key * 'prio) option
