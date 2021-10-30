package main

import (
	"fmt"
	"gonum.org/v1/plot"
)

func main() {
	// Questions 2 et 3
	data := euler(0.0, 7.0, 0.0, 500, rc)
	p := plot.New()
	plotScatter(p, data, "t", "u", blue, false)
	save(p, "Avec 500 points", "q2-3/500-points.png")

	data = euler(0.0, 7.0, 0.0, 200, rc)
	p = plot.New()
	plotScatter(p, data, "t", "u", blue, false)
	save(p, "Avec 200 points", "q2-3/200-points.png")

	p = plot.New()
	plotFunction(p, uHand, 0.0, 7.0, 0.0, 1.0)
	save(p, "Résolution exacte", "q2-3/resol-exacte.png")

	// Question 4, 5 et 6
	rcValues := []float64{0.001, 0.005, 0.01, 0.02, 0.05, 0.1}
	for _, rc := range rcValues {
		p = plot.New()
		data = euler(0.0, 0.2, 0.0, 2500, makeRCT(rc))
		crenels := crenelPoints(40)
		plotScatter(p, data, "", "", blue, true)
		plotScatter(p, crenels, "Temps (s)", "Tension (V)", orange, true)
		save(p, fmt.Sprintf("Créneaux pour RC = %.3f s", rc), fmt.Sprintf("q4-5-6/creneaux-%.3f.png", rc))
	}
}
