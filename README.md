# VL.Overworld

A course in spatial thinking for vvvv gamma, geometry first, maps second. It has no nodes of its own; it installs the libraries that do and adds patches that use them together:

* Tutorials in seven chapters, one question each: from a shape becoming data, to your data on the earth, projections, spatial indexes, fields, networks and data too big for memory
* Explanations that prove one fact on screen each
* Prompts: unordered projects to pick from, such as live earthquakes, the height under your cursor or a town that grows

Anything that fetches from the internet starts with its switch off. It assumes you can already wire a basic vvvv patch; if not, start with [VL.TheBigBang](https://github.com/chkw-rks/VL.TheBigBang).

For use with vvvv, the visual live-programming environment for .NET: http://vvvv.org

## Getting started
- Not on nuget.org yet. Once it is, install as [described here](https://thegraybook.vvvv.org/reference/hde/managing-nugets.html) via commandline:

    `nuget install VL.Overworld -pre`

- The course is in the [Help Browser](https://thegraybook.vvvv.org/reference/hde/findinghelp.html). Start with *Tutorial 1.1 Your cursor is now data*.

## Related packages
- [VL.NetTopologySuite](https://github.com/rednotfound/VL.NetTopologySuite): geometry, installed with this pack
- [VL.NetTopologySuite.GeoJSON](https://github.com/rednotfound/VL.NetTopologySuite.GeoJSON): read and write GeoJSON, installed with this pack
- [VL.Mapsui](https://github.com/rednotfound/VL.Mapsui): draw a real map, installed with this pack

## Contributing
- Report issues on [GitHub](https://github.com/rednotfound/VL.Overworld/issues)
- How the course is built and verified, and why it is in this order: [the guide](https://github.com/rednotfound/VL.Overworld/blob/main/docs/GUIDE.md)
- When making a pull-request, please make sure to read the general [guidelines on contributing to vvvv libraries](https://thegraybook.vvvv.org/reference/extending/contributing.html)

## Credits
The patches teach [VL.NetTopologySuite](https://github.com/rednotfound/VL.NetTopologySuite), [VL.NetTopologySuite.GeoJSON](https://github.com/rednotfound/VL.NetTopologySuite.GeoJSON) and [VL.Mapsui](https://github.com/rednotfound/VL.Mapsui). Sample data and tile services keep their own terms: see [THIRD-PARTY-NOTICES](https://github.com/rednotfound/VL.Overworld/blob/main/THIRD-PARTY-NOTICES.md).

## License
MIT for the patches, as declared in the package metadata.
