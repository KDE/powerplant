// SPDX-License-Identifier: LGPL-3.0
// SPDX-FileCopyrightText: 2012 Jérémie Astori <jeremie@astori.fr>
import QtQuick 2.15

Item {
    property list<InterpolationStop> stops

    function getColorAt(value) {
        var lowerStop, upperStop;

        for(var i = 0; i < stops.length; ++i) {
            if(value === stops[i].position) // value matches with a precise InterpolationStop position, no need to compute a color
                return stops[i].color;

            if(value - stops[i].position >= 0) {
                if(lowerStop === undefined || stops[i].position > lowerStop.position)
                    lowerStop = stops[i];
            }
            else {
                if(upperStop === undefined || stops[i].position < upperStop.position)
                    upperStop = stops[i];
            }
        }

        if(upperStop === undefined) // value is above the highest position
            return lowerStop.color;

        if(lowerStop === undefined) // value is below the lowest position
            return upperStop.color;

        var x = (value - lowerStop.position) / (upperStop.position - lowerStop.position); // The ratio between the 2 surrounding InterpolationStops.
        var upperRgb = rgb(lowerStop.color);
        var lowerRgb = rgb(upperStop.color);

        return Qt.rgba(
             upperRgb.r * (1 - x) + lowerRgb.r * x,
             upperRgb.g * (1 - x) + lowerRgb.g * x,
             upperRgb.b * (1 - x) + lowerRgb.b * x
        );
    }

    function rgb(color) {
        return {
            'r': parseInt(color.toString().substr(1, 2), 16) / 255,
            'g': parseInt(color.toString().substr(3, 2), 16) / 255,
            'b': parseInt(color.toString().substr(5, 2), 16) / 255
        };
    }
}
