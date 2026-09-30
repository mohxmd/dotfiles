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
    property var barValues: []
    property double divisor: 1024
    property bool staticDivisor: false
    property bool showLabels: false
    property var peakValues: [0, 0];

    onConfigChanged: requestPaint()
    onBarValuesChanged: requestPaint()

    QtObject {
        id: data
        property bool showPeaks: plasmoid.configuration.showPeaks ? !staticDivisor : false
        property bool usePeaks: plasmoid.configuration.usePeaks
        property var lineHeight: showPeaks ? Qt.application.font.pixelSize : 0
        property var maxHeight: showLabels ? height - (2 * lineHeight) : height
    }
    onPaint: {
        var yLoc;
        var gradient;
        var ctx;
        var xLocStart;
        var xLocEnd;
        var barColor;
        var pwidth;
        var pw;
        var peakDiv = [0, ""];

        function drawBar(index) {
            if (index === 0) {
                xLocStart = 0;
                xLocEnd = Math.ceil(width / 2);
            } else {
                xLocStart = Math.ceil(width / 2);
                xLocEnd = width;
            }
            yLoc = height - Math.round((data.maxHeight * (barValues[index + 1] / divisor)));
            if (!isNaN(yLoc)) {
                if (yLoc < 0)
                    yLoc = 0;
                barColor = config[index];
                gradient = ctx.createLinearGradient(xLocStart, 0, xLocEnd, 0);
                gradient.addColorStop(0, Qt.lighter(barColor));
                gradient.addColorStop(.67, barColor);
                gradient.addColorStop(1, barColor);
                ctx.fillStyle = gradient;
                ctx.strokeStyle = barColor;
                ctx.beginPath();
                ctx.moveTo(Math.ceil(xLocEnd), height);
                ctx.lineTo(Math.ceil(xLocEnd), yLoc);
                ctx.lineTo(xLocStart, yLoc);
                ctx.lineTo(xLocStart, height);
                ctx.fill();
            }
        }
        if (!data.usePeaks) {
            peakValues[0] = peakValues[0] * .9;
            peakValues[1] = peakValues[1] * .9;
        }
        if (barValues[1] > peakValues[0]) {
            peakValues[0] = barValues[1];
        }
        if (barValues[2] > peakValues[1]) {
            peakValues[1] = barValues[2];
        }
        pwidth = Math.ceil(width);
        ctx = getContext("2d");
        ctx.clearRect(0, 0, pwidth, height);
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
        drawBar(0);
        drawBar(1);
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
            ctx.textAlign = "left";
            ctx.textBaseline = "bottom";
            ctx.fillStyle = Kirigami.Theme.textColor;
            ctx.fillText(barValues[0], 0, height);
            ctx.restore();
        }
    }
}
