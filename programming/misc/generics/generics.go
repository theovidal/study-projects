package main

import (
	"golang.org/x/exp/constraints"
)

func dicho[T constraints.Ordered](arr []T, x T) int {
	fin, deb := 0, len(arr)
	for fin - deb > 1 {
		mid := (fin + deb) / 2
		if arr[mid] == x {
			return mid
		} else if arr[mid] > x {
			fin = mid
		} else {
			deb = mid + 1
		}
	}
	return -1
}

/*func main() {
	arr := []int{2, 3, 5, 6, 8, 10, 12}
	fmt.Printf("%d\n", dicho(arr, 6))
	fmt.Printf("%d", dicho(arr, 7))
}*/
