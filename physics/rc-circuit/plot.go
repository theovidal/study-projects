package main

import (
	"image"
	"image/color"
	"image/png"
	gofont "golang.org/x/image/font"
	"io/fs"
	"os"

	"gonum.org/v1/plot"
	"gonum.org/v1/plot/plotter"
	"gonum.org/v1/plot/vg/draw"
	"gonum.org/v1/plot/vg/vgimg"
	"gonum.org/v1/plot/font"
)

var (
	orange = color.RGBA{R: 244, G: 122, B: 16, A: 255}
	blue = color.RGBA{R: 31, G: 133, B: 222, A: 255}
)

const (
	dpi = 350

	titleSize = 33.0
	axisSize = 22.0
	dotSize = 2.6
)

func plotFunction(p *plot.Plot, f func(float64) float64, xMin, xMax, yMin, yMax float64) {
	plotFunc := plotter.NewFunction(f)
	plotFunc.Color = blue

	p.Add(plotFunc)
	p.X.Min = xMin
	p.X.Max = xMax
	p.Y.Min = yMin
	p.Y.Max = yMax
}


func plotScatter(p *plot.Plot, data plotter.XYs, xLabel, yLabel string, style color.Color, line bool) {
	p.X.Label.Text = xLabel
	p.Y.Label.Text = yLabel
	p.Add(plotter.NewGrid())

	if line {
		line, err := plotter.NewLine(data)
		if err != nil {
			panic(err)
		}
		line.LineStyle.Color = style
		p.Add(line)
	} else {
		scatter, err := plotter.NewScatter(data)
		if err != nil {
			panic(err)
		}
		scatter.GlyphStyle.Color = style
		scatter.GlyphStyle.Shape = draw.CircleGlyph{}
		scatter.GlyphStyle.Radius = dotSize
		p.Add(scatter)
	}
}

func save(p *plot.Plot, title string, path string) {
	p.Title.Text = title

	file, err := os.OpenFile(path, 0666, fs.ModePerm)
	if err != nil {
		file, err = os.Create(path)
		if err != nil { panic(err) }
	}

	img := image.NewRGBA(image.Rect(0, 0, 3*dpi, 3*dpi))
	canvas := vgimg.NewWith(vgimg.UseImage(img))
	p.X.Label.TextStyle.Font.Size = font.Points(axisSize)
	p.Y.Label.TextStyle.Font.Size = font.Points(axisSize)
	p.Title.TextStyle.Font.Size = font.Points(titleSize)
	p.Title.TextStyle.Font.Weight = gofont.WeightBold
	p.Draw(draw.New(canvas))

	png.Encode(file, canvas.Image())
	file.Close()
}