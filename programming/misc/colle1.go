package main

/*
	On considère une matrice d'entiers M de taille n*p, et l'on souhaite résoudre le problème suivant :
	- choisir exactement un élément sur chaque ligne de la matrice ;
	- de manière à ce que la somme de ces élements soit maximale ;
	- tout en restant inférieure ou égale à un seuil fixé.
*/

import "fmt"

func constrained_maximization(matrix [][]int, limit int) int {
	return max_loop(matrix, 0, 0, limit)
}

func max_loop(matrix [][]int, line, sum, limit int) int {
	max_sum := -1
	for i := 0; i < len(matrix[line]); i++ {
		new_sum := matrix[line][i] + sum
		if new_sum > limit {
			continue
		}
		if line != len(matrix)-1 {
			new_sum = max_loop(matrix, line+1, matrix[line][i]+sum, limit)
		}
		if new_sum > max_sum {
			max_sum = new_sum
		}
	}
	return max_sum
}

func main() {
	matrix := [][]int{
		{4, 8, 1, 9, 0, 1},
		{9, 0, 1, 0, 0, 1},
		{1, 0, 2, 4, 5, 1},
		{0, 0, 1, 2, 2, 4},
	}
	fmt.Println(max_loop(matrix, 0, 0, 18))
}
