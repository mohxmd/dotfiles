/*
 * Copyright 2015  Martin Kotelnik <clearmartin@seznam.cz>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http: //www.gnu.org/licenses/>.
 */
import QtQuick 2.15
import org.kde.plasma.components 3.0 as PlasmaComponents
import "../code/icons.js" as IconTools
import "../code/unit-utils.js" as UnitUtils
import org.kde.kirigami as Kirigami

Item {
    property string temperature
    property string iconName
    property bool hidden
    property int partOfDay
    property double pixelFontSize
    
    onPixelFontSizeChanged: {
        if (pixelFontSize > 0) {
            temperatureText.font.pixelSize = pixelFontSize
            temperatureIcon.font.pixelSize = pixelFontSize
        }
    }

    // Rectangle {
    //     id: testRect
    //     width: parent.width
    //     height: parent.height
    //     anchors.top: parent.top
    //     anchors.left: parent.left
    //     anchors.right: parent.right
    //     // width: parent.width
    //     // height: parent.height
    //     // width: precType === 1 ? precipitationLabelLeft.width * 1.8 : precipitationLabelLeft.width + 5
    //     // height: precType === 1 ? precipitationLabelLeft.height : precipitationLabelLeft.height - 1 //2 // labelHeight / 1.8
    //     // color: white
    //     // z: -1
    //     // anchors.leftMargin: -2
    //     // anchors.bottomMargin: -2
    //     // anchors.bottomMargin: -2
    // }
    
    Text {
        id: temperatureText
        font.pixelSize: defaultFontPixelSize
        text: UnitUtils.getTemperatureNumberExt(temperature, temperatureType)
        // Math.round(temperature) + '[]' + temperatureType
        visible: ! hidden
        width: parent.width / 2
        horizontalAlignment: Text.AlignHCenter //Text.AlignRight
        color: Kirigami.Theme.textColor
        anchors.left: parent.left

    }
    Text {
        anchors.left: temperatureText.right
        id: temperatureIcon
        font.family: 'weathericons'
        font.pixelSize: defaultFontPixelSize
        text: (iconName > 0) ? IconTools.getIconCode(iconName, currentPlace.providerId, partOfDay) : '\uf07b'
        visible: ! hidden
        width: parent.width / 2
        horizontalAlignment: Text.AlignHCenter //Text.AlignHCenter
        // anchors.rightMargin: 8 //parent.width / 4
        color: Kirigami.Theme.textColor
        anchors.right: parent.right
    }
}
