# Vision Test

This program displays a standard shape, or _optotype_, (e.g. [Snell E][1]))
in various orientations and sampling a given range of sizes. An interface
is provided to the human to enter their perception, which is recorded along
with chosen values to be post-processed into a visual acuity measure.

[1]: https://en.wikipedia.org/wiki/Snellen_chart
	"Snellen chart - Wikipedia, the free encyclopedia"

On a typical computer screen (about 125 dpi), aiming for at least 10 pixels
per arc minute to reach a decent precision, means almost 7 m between eye
and screen. To accommodate such a setup, the input interface is not tied to
the display, but rather is an embedded HTTP server, so it can be used e.g.
with a smartphone.
