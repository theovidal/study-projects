package main

import "errors"

type Queue[T any] struct {
	data []T
	start int
	end int
	capacity int
}

func NewQueue[T any](capacity int) Queue[T] {
	return Queue[T] {
		data: make([]T, capacity),
		start: 0,
		end: 0,
		capacity: capacity,
	}
}

func (q Queue[T]) IsEmpty() bool {
	return q.start == q.end
}

func (q *Queue[T]) Push(x T) (err error) {
	if q.end == q.capacity {
		return errors.New("maximum capacity reached")
	}

	q.data[q.end] = x
	q.end = (q.end + 1) % (q.capacity - 1)

	return
}

func (q *Queue[T]) Seek() (x T, err error) {
	if q.start == q.end {
		err =errors.New("nothing to seek")
	} else {
		x = q.data[q.start]
	}
	return
}

func (q *Queue[T]) Pop() (x T, err error) {
	if q.start == q.end {
		return x, errors.New("nothing to pop")
	}
	x = q.data[q.start]
	q.start = (q.start + 1) % (q.capacity - 1)

	return
}
