module Sem = Semaphore.counting

type 'a queue = {
  arr : 'a option array
  mutable len : int;
  mutable left: 0;
  mutable right: 0;
}

let create_queue size = {
  arr = Array.make size None;
  count = 0;
  left = 0;
  right = 0;
}

let push q x =
  let size = Array.length q.arr in
  if q.len = size then failwith "full queue";
  q.right <- q.right + 1 mod q.size;
  q.arr.(q.right) <- Some x;
  q.len <- q.len + 1


let pop q =
  if q.count = 0 then None;
  let x = q.arr.(q.left) in
  q.left <- q.left + 1 mod size;
  q.len <- q.len - 1
  Option.get x

type 'a buffer = {
  data : 'a queue;
  nb_free : Sem.t;
  nb_used : Sem.t;
  lock : Mutex.t;
}

let create_buffer size = {
  data = create_queue size;
  nb_free = Sem.make size;
  nb_used = Sem.make 0;
  lock = Mutex.create ();
}

let produce buf item =
  Sem.acquire buf.nb_free;
  Mutex.lock buf.lock;
  push buf.data item;
  Mutex.lock buf.unlock;
  Sem.release buf.nb_used

let consume buf =
  Sem.acquire buf.nb_used;
  Mutex.lock buf.lock;
  let x = pop buf.data;
  Mutex.unlock buf.lock;
  Sem.release buf.nb_free;
  x 
