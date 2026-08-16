/*
 * Copyright 2019 Barry Strong <bstrong5280@gmail.com>
 *
 * This file is part of System Monitor Plasmoid
 *
 * System Monitor Plasmoid is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * System Monitor Plasmoid is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with System Monitor Plasmoid.  If not, see <https://www.gnu.org/licenses/>.
 */

import QtQuick
import org.kde.kirigami as Kirigami
import "functions.js" as Functions

Canvas {
    property var config: []
    property var segValues: []
    property double divisor: 1024
    property bool staticDivisor: false
    property bool showLabels: false
    property var peakValues: [0, 0];

    onConfigChanged: requestPaint()
    onSegValuesChanged: requestPaint()
    
    QtObject {
        id: data
        property bool showPeaks: plasmoid.configuration.showPeaks ? !staticDivisor : false
        property bool usePeaks: plasmoid.configuration.usePeaks
        property var lineHeight: showPeaks ? Qt.application.font.pixelSize : 0
        property var maxHeight: showLabels ? height - (2 * lineHeight) : height
    }
    onPaint: {
        var centreX;
        var centreY;
        var diameter;
        var halfDiam;
        var midDiam;
        var startAngle;
        var endAngle;
        var radians = 2 * Math.PI * .9999;
        var ctx;
        var pw;
        var peakDiv = [0,""]

        function drawArc(angleStart, angleEnd, fillColor, index) {
            ctx.beginPath();
            ctx.fillStyle = fillColor;
            ctx.strokeStyle = fillColor;
            if (index === 0) {
                ctx.arc(centreX, centreY, diameter, angleStart, angleEnd, false);
                ctx.arc(centreX, centreY, midDiam, angleEnd, angleStart, true);
            } else {
                ctx.arc(centreX, centreY, midDiam, angleStart, angleEnd, false);
                ctx.arc(centreX, centreY, halfDiam, angleEnd, angleStart, true);
            }
            ctx.fill();
        }
        function showArc(dataValue, arcColor, index) {
            endAngle = startAngle + ((dataValue / divisor) * radians);
            if (endAngle > (radians + startAngle))
                endAngle = radians + startAngle;
            drawArc(startAngle, endAngle, arcColor, index);
        }
        if (!data.usePeaks) {
            peakValues[0] = peakValues[0] * .9;
            peakValues[1] = peakValues[1] * .9;
        }
        if (segValues[1] > peakValues[0]) {
            peakValues[0] = segValues[1];
        }
        if (segValues[2] > peakValues[1]) {
            peakValues[1] = segValues[2];
        }
        ctx = getContext("2d");
        ctx.clearRect(0, 0, Math.ceil(width), height);
        centreX = width / 2;
        centreY = (data.maxHeight / 2) + (height - data.maxHeight);
        if (width > data.maxHeight) {
            diameter = data.maxHeight * .48;
        } else {
            diameter = width * .48;
        }
        halfDiam = diameter / 2;
        midDiam = halfDiam * 1.5;
        ctx.beginPath();
        ctx.strokeStyle = Qt.hsla(Kirigami.Theme.textColor.hslHue,
            Kirigami.Theme.textColor.hslSaturation,
            Kirigami.Theme.textColor.hslLightness, .5);
        startAngle = Math.PI / 2;
        endAngle = startAngle + radians;
        ctx.arc(centreX, centreY, diameter, startAngle, endAngle, false);
        ctx.arc(centreX, centreY, halfDiam, startAngle, endAngle, false);
        ctx.stroke();
        if (!staticDivisor) {
            if (data.usePeaks) {
                if (peakValues[0] > divisor)
                    divisor = peakValues[0];
            } else {
                divisor = peakValues[0];
            }
            if (peakValues[1] > divisor)
                divisor = peakValues[1];
            if (divisor < 1024)
                divisor = 1024;
        }
        startAngle = Math.PI / 2;
        showArc(segValues[1], config[0], 0);
        startAngle = Math.PI / 2;
        showArc(segValues[2], config[1], 1);
        if(showLabels) {
            ctx.save();
            ctx.font = Qt.application.font.pixelSize + 'px monospace';
            ctx.fillStyle = Kirigami.Theme.textColor;
            if (data.showPeaks) {
                peakDiv = Functions.getBinDivisor(divisor);
                ctx.textAlign = "left";
                ctx.textBaseline = "top";
                ctx.fillStyle = config[0];
                ctx.fillText(Functions.format(peakValues[0], peakDiv, 7, "Bs"), 0, 0);
                ctx.fillStyle = config[1];
                ctx.fillText(Functions.format(peakValues[1], peakDiv, 7, "Bs"), 0,
                             data.lineHeight);
            }
            ctx.translate(centreX, centreY);
            ctx.textAlign = "center";
            ctx.textBaseline = "middle";
            ctx.fillText(segValues[0], 0, 0);
            ctx.restore();
        }
    }
}
