package main

import (
	"fmt"

	"gonum.org/v1/plot"
)

func main() {
	// Questions 2 et 3
	p := plot.New()
	data := euler(0.0, 7.0, 0.0, 500, rc)
	plotScatter(p, data, "Temps (s)", "Tension (V)", orange, false)
	plotFunction(p, uHand, 0.0, 7.0, 0.0, 1.0)
	save(p, "Validation de la méthode d'Euler", "q2-3/euler.png")

	p = plot.New()
	data = euler(0.0, 7.0, 0.0, 350, rc)
	plotScatter(p, data, "Temps (s)", "Tension (V)", orange, false)
	plotFunction(p, uHand, 0.0, 7.0, 0.0, 1.0)
	save(p, "Résolution numérique - Avec 350 points", "q2-3/350-points.png")

	p = plot.New()
	data = euler(0.0, 7.0, 0.0, 100, rc)
	plotScatter(p, data, "Temps (s)", "Tension (V)", orange, false)
	plotFunction(p, uHand, 0.0, 7.0, 0.0, 1.0)
	save(p, "Résolution numérique - Avec 100 points", "q2-3/100-points.png")

	// Question 4, 5 et 6
	rcValues := []float64{0.001, 0.005, 0.01, 0.02, 0.05, 0.1}
	for _, rc := range rcValues {
		p = plot.New()
		data = euler(0.0, 0.2, 0.0, 2500, makeRCT(rc))
		crenels := crenelPoints(40)
		plotScatter(p, data, "", "", blue, true)
		plotScatter(p, crenels, "Temps (s)", "Tension (V)", orange, true)
		save(p, fmt.Sprintf("Signal créneau avec τ = %.3f s", rc), fmt.Sprintf("q4-5-6/creneaux-%.3f.png", rc))
	}

	fmt.Println("✅ All figures generated in q2-3 and q4-5-6 folders.")
}
