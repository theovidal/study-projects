package main

import "strconv"

type TokenType int

const (
	PO TokenType = iota
	PF
	OP
	Value
	Function
)

type Token struct {
	Type  TokenType
	Value string
}

func TokensToTree(tokens []Token) (expr Expr, count int) {
	count = 0

	tree := Expr{}
	var last *Expr

	for count != len(tokens) {
		current := tokens[count]
		child := Expr{}
		if current.Type == PF {
			return
		}
		if current.Type == PO {
			child, count = TokensToTree(tokens[count:])
		} else if current.Type == Value {
			var err error
			child.Value, err = strconv.ParseFloat(current.Value, 64)
			if err != nil {
				panic("Invalid conversion of " + current.Value)
			}
		} else if current.Type == OP {
			switch current.Value {
			case "*", "/":
				op := Multiply

				break

			case "+", "-":
				var op Operator
				if current.Value == "+" {
					op = Plus
				} else {
					op = Minus
				}
				last = &child
				tree = Expr{
					Op:   op,
					Left: last,
				}
				break
			}
			child.Operator
		} else if current.Type == Function {

		}

		if tree.Left == nil {
			tree.Left = &child
		} else {
			tree.Right = &child
		}
		count++
	}

	return tree, count
}

func ListTokens(input string) {

}
