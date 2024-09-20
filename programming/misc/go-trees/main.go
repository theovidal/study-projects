package main

import (
	"fmt"
	"math"
)

func main() {
	test := Expr{
		Op: Plus,
		Left: &Expr{
			Op:    Multiply,
			Left:  &Expr{Value: 5},
			Right: &Expr{Value: 3},
		},
		Right: &Expr{
			Function: "cos",
			Left:     &Expr{Value: math.Pi},
		},
	}

	fmt.Printf("%.0f", test.Eval())
	fmt.Printf("%s", test.String(0))
}
