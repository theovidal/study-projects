package main

import (
    "fmt"
    "golang.org/x/exp/constraints"
)

type Graph[V any, E constraints.Integer] struct {
    Vertex []V
    Edges [][]E
}

var example = Graph[string, int]{
    Vertex: []string{
        "Paris",
        "Lyon",
        "Bordeaux",
        "Toulouse",
        "Marseille",
        "Strasbourg",
        "Bourg-en-Bresse",
        "Genève",
    },
    Edges: [][]int{
        {1, 2, 5},
        {0, 4, 5},
        {0, 3},
        {2, 5},
        {1, 3},
        {0, 7},
        {1, 7},
        {5, 6},
    },
}


func (g Graph[V, E]) DFS(pre func(index E, vertex V), post func(index E, vertex V)) {
    n := len(g.Edges)
    visited := make([]E, n)

    var explore func(i E, succ []E)

    explore = func (i E, succ []E) {
        if visited[i] == 0 {
            visited[i] = 1
            pre(i, g.Vertex[i])
            for _, x := range succ {
                explore(x, g.Edges[x])
            }
            post(i, g.Vertex[i])
        }
    }

    for i, succ := range g.Edges {
        explore(E(i), succ)
    }
}

func (g Graph[V, E]) BFS(f func(index E, vertex V)) {
    n := len(g.Vertex)

    opened := NewQueue[E](n)
    opened.Push(0)

    seen := make([]E, n)
    seen[0] = 1

    for !opened.IsEmpty() {
        x, err := opened.Pop()
        if err != nil { panic(err) }
        f(x, g.Vertex[x])

        for _, y := range g.Edges[x] {
            if seen[y] == 0 {
                seen[y] = 1
                err = opened.Push(y)
                if err != nil { panic(err) }
            }
        }
    }
}

func main() {
    example.BFS(func(i int, city string) {
        fmt.Printf("Passage %d : %s\n", i + 1, city)
    })
}
