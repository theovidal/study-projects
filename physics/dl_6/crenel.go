package main

import (
	"math"

	"gonum.org/v1/plot/plotter"
)

const (
	f = 50
	M = 0.5
	T = 0.02
	A = 1

	Min = M - A
	Max = M + A
)

func crenelPoints(n int) (data plotter.XYs) {
	data = append(data, plotter.XY{X: 0, Y: Max})

	for i := 1; i < n; i++ {
		y := Max
		if i % 4 >= 2 {
			y = Min
		}
		data = append(data, plotter.XY{
			X: math.Ceil(float64(i) / 2.0) * T / 2.0,
			Y: y, 
		})
	}

	return
}

func crenel(t float64) float64 {
	ref := math.Remainder(t, T)
	if ref > 0 {
		return M + A
	} else {
		return M - A
	}
}