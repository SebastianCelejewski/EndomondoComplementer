Endomondo Complementer
=====================

Complements broken Endomondo tracks using time interpolation. Use it when your GPS device (usually a smartphone) dies or restarts during a workout, and you end up with two or more fragments of your workout.

To complement and merge your workout you will need:
- Downloaded fragments of your workout exported from your GPS device in GPX format (lat, lon, and time data).
- Manually created fragments of your workout (lat, lon, without time data).

Usage:

1. Create 'input' directory and put abovementioned GPX tracks there.

2. Run ruby bin/run.rb

3. You should find merged GPX track in 'output' directory

How to create missing fragments of your workout?
I use "Create a route" function in Endomondo and export route to GPX.
