type 'a t

val create : unit -> 'a t
val get : 'a t -> int -> 'a
val set : 'a t -> int -> 'a -> unit
val pop : 'a t -> 'a
val push : 'a t -> 'a -> unit
val length : 'a t -> int
