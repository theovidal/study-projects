package main

import (
	"fmt"
	"math"
	"strconv"
)

type Operator struct {
	Value string
	Apply func(x, y float64) float64
}

var (
	Plus     = Operator{"+", func(x, y float64) float64 { return x + y }}
	Minus    = Operator{"-", func(x, y float64) float64 { return x - y }}
	Multiply = Operator{"*", func(x, y float64) float64 { return x * y }}
)

var functions = map[string]func(x float64) float64{
	"cos":  math.Cos,
	"sin":  math.Sin,
	"sqrt": math.Sqrt,
	"exp":  math.Exp,
	"ln":   math.Log,
}

var prettyFormats = map[float64]string{
	math.Pi: "π",
	math.E:  "e",
}

func ApplyFunction(f string, x float64) float64 {
	return functions[f](x)
}

type Expr struct {
	Value    float64
	Op       Operator
	Function string
	Left     *Expr
	Right    *Expr
}

func (e *Expr) Eval() float64 {
	if e.Left == nil && e.Right == nil {
		return e.Value
	}
	if e.Right == nil {
		return ApplyFunction(e.Function, e.Left.Eval())
	}
	return e.Op.Apply(e.Left.Eval(), e.Right.Eval())
}

func (e *Expr) String(precision int) string {
	if e.Left == nil && e.Right == nil {
		if val, found := prettyFormats[e.Value]; found {
			return val
		} else {
			format := "%." + strconv.Itoa(precision) + "f"
			return fmt.Sprintf(format, e.Value)
		}
	}
	if e.Right == nil {
		return fmt.Sprintf("%s(%s)", e.Function, e.Left.String(precision))
	}

	return fmt.Sprintf("(%s %s %s)", e.Left.String(precision), e.Op.Value, e.Right.String(precision))
}
