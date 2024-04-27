package main

import (
	"math"

	"gonum.org/v1/plot/plotter"
)

const (
	E = 1.0
	RC = 1.0
)

func uHand(t float64) float64 {
	return E * (1 - math.Exp(-t/RC))
}

func makeRCT(rc float64) func(float64, float64) float64 {
	return func(y, t float64) float64 {
		return (crenel(t) - y)/rc
	}
}

func rc(y, _ float64) float64 {
	return (E - y)/RC
}

func euler(a, b, y0 float64, n int, f func(y, t float64) float64) (data plotter.XYs) {
	h := (b - a) / float64(n)
	data = append(data, plotter.XY{
		X: 0,
		Y: y0,
	})

    for i := 1; i < n; i++ {
		data = append(data, plotter.XY{
			X: a + float64(i)*h,
			Y: data[i-1].Y + h * f(data[i-1].Y, data[i-1].X),
		})
	}

	return
}
